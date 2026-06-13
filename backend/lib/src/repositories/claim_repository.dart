import 'package:mongo_dart/mongo_dart.dart';
import 'package:backend/src/models/claim.dart';
import 'package:backend/src/services/mongodb_service.dart';
import 'package:backend/src/models/notification.dart';
import 'package:backend/src/repositories/notification_repository.dart';

class ClaimRepository {
  final _notifRepo = NotificationRepository();

  Future<List<Claim>> getAllClaims() async {
    final db = await MongodbService.db;
    final collection = db.collection('claims');
    final data = await collection.find().toList();
    return data.map(Claim.fromMap).toList();
  }

  Future<Claim?> getClaimById(String id) async {
    final db = await MongodbService.db;
    final collection = db.collection('claims');
    final data = await collection.findOne(where.id(ObjectId.fromHexString(id)));
    if (data == null) return null;
    return Claim.fromMap(data);
  }

  Future<String> createClaim(Claim claim) async {
    final db = await MongodbService.db;
    final collection = db.collection('claims');
    final id = ObjectId();
    await collection.insertOne({
      '_id': id,
      ...claim.toMap(),
    });

    // Notify technicians about new claim
    await _notifRepo.createNotification(NotificationModel(
      userId: 'staff_general',
      judul: 'Permintaan Klaim Baru',
      pesan: '${claim.claimantName} mengajukan klaim untuk "${claim.reportTitle}".',
      tipeNotif: 'claim',
      createdAt: DateTime.now(),
    ));

    return id.toHexString();
  }

  Future<void> updateClaimStatus(String id, String status) async {
    final db = await MongodbService.db;
    final collection = db.collection('claims');
    await collection.updateOne(
      where.id(ObjectId.fromHexString(id)),
      modify.set('status', status),
    );
  }

  /// Verifies one claim and automatically rejects all other pending claims for the same report.
  /// Also updates the report status to 'resolved' and sends notifications.
  Future<void> verifyAndRejectOthers(String verifiedClaimId, String reportId) async {
    final db = await MongodbService.db;
    final claimsCol = db.collection('claims');
    final reportsCol = db.collection('reports');
    
    // 1. Fetch the verified claim details
    final claimDoc = await claimsCol.findOne(where.id(ObjectId.fromHexString(verifiedClaimId)));
    if (claimDoc == null) return;
    final verifiedClaim = Claim.fromMap(claimDoc);

    // 2. Mark target claim as verified
    await claimsCol.updateOne(
      where.id(ObjectId.fromHexString(verifiedClaimId)),
      modify.set('status', 'verified'),
    );

    // 3. Mark all other pending claims for the same report as rejected
    final otherClaimsDocs = await claimsCol.find(
      where.eq('reportId', reportId).and(where.ne('_id', ObjectId.fromHexString(verifiedClaimId)))
    ).toList();

    await claimsCol.updateMany(
      where.eq('reportId', reportId).and(where.ne('_id', ObjectId.fromHexString(verifiedClaimId))),
      modify.set('status', 'rejected'),
    );

    // 4. Update the Report status to 'resolved'
    final reportDoc = await reportsCol.findOne(where.id(ObjectId.fromHexString(reportId)));
    await reportsCol.updateOne(
      where.id(ObjectId.fromHexString(reportId)),
      modify.set('status_postingan', 'resolved')
            .set('claimantName', verifiedClaim.claimantName)
            .set('claimantId', verifiedClaim.claimantId)
            .set('resolvedAt', DateTime.now().toIso8601String()),
    );

    // 5. Send Notifications
    
    // 5a. Notify Winner
    await _notifRepo.createNotification(NotificationModel(
      userId: verifiedClaim.claimantId,
      judul: 'Klaim Disetujui!',
      pesan: 'Klaim Anda untuk "${verifiedClaim.reportTitle}" telah diverifikasi teknisi. Barang sudah diserahterimakan.',
      tipeNotif: 'claim',
      createdAt: DateTime.now(),
    ));

    // 5b. Notify Losers
    for (final doc in otherClaimsDocs) {
      final loser = Claim.fromMap(doc);
      await _notifRepo.createNotification(NotificationModel(
        userId: loser.claimantId,
        judul: 'Update Klaim',
        pesan: 'Mohon maaf, klaim Anda untuk "${loser.reportTitle}" tidak disetujui karena barang sudah diserahkan kepada pemilik yang sah.',
        tipeNotif: 'claim',
        createdAt: DateTime.now(),
      ));
    }

    // 5c. Notify Post Owner (Uploader)
    if (reportDoc != null) {
      final uploaderId = reportDoc['userId']?.toString();
      if (uploaderId != null && uploaderId != verifiedClaim.claimantId) {
        await _notifRepo.createNotification(NotificationModel(
          userId: uploaderId,
          judul: 'Barang Telah Diserahkan',
          pesan: 'Barang "${verifiedClaim.reportTitle}" Anda telah berhasil diserahkan kepada ${verifiedClaim.claimantName}. Postingan kini telah ditutup.',
          tipeNotif: 'system',
          createdAt: DateTime.now(),
        ));
      }
    }
  }

  Future<void> deleteClaim(String id) async {
    final db = await MongodbService.db;
    final collection = db.collection('claims');
    await collection.deleteOne(where.id(ObjectId.fromHexString(id)));
  }
}
