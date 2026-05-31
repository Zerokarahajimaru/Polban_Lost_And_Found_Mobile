import 'package:mongo_dart/mongo_dart.dart';
import '../models/claim.dart';
import '../services/mongodb_service.dart';

class ClaimRepository {
  Future<List<Claim>> getAllClaims() async {
    final db = await MongodbService.db;
    final collection = db.collection('claims');
    final data = await collection.find().toList();
    return data.map((map) => Claim.fromMap(map)).toList();
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
  Future<void> verifyAndRejectOthers(String verifiedClaimId, String reportId) async {
    final db = await MongodbService.db;
    final collection = db.collection('claims');
    
    // 1. Mark target claim as verified
    await collection.updateOne(
      where.id(ObjectId.fromHexString(verifiedClaimId)),
      modify.set('status', 'verified'),
    );

    // 2. Mark all other pending claims for the same report as rejected
    // We filter by reportId AND ensure they are still 'pending' to avoid overwriting previously rejected/verified ones
    await collection.updateMany(
      where.eq('reportId', reportId).and(where.ne('_id', ObjectId.fromHexString(verifiedClaimId))),
      modify.set('status', 'rejected'),
    );
  }

  Future<void> deleteClaim(String id) async {
    final db = await MongodbService.db;
    final collection = db.collection('claims');
    await collection.deleteOne(where.id(ObjectId.fromHexString(id)));
  }
}
