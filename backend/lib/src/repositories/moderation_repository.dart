import 'package:mongo_dart/mongo_dart.dart';
import '../models/moderation_report.dart';
import '../services/mongodb_service.dart';
import '../models/notification.dart';
import '../repositories/notification_repository.dart';

class ModerationRepository {
  final _notifRepo = NotificationRepository();

  Future<List<ModerationReportModel>> getAllReports() async {
    final db = await MongodbService.db;
    final col = db.collection('moderation_reports');
    final results = await col.find(where.sortBy('reportedAt', descending: true)).toList();
    return results.map((doc) {
      return ModerationReportModel.fromMap(doc);
    }).toList();
  }

  Future<List<ModerationReportModel>> getPendingReports() async {
    final db = await MongodbService.db;
    final col = db.collection('moderation_reports');
    final results =
        await col.find(where.eq('status', 'pending').sortBy('reportedAt', descending: true)).toList();
    return results.map((doc) {
      return ModerationReportModel.fromMap(doc);
    }).toList();
  }

  Future<ModerationReportModel?> getByPostId(String postId) async {
    final db = await MongodbService.db;
    final col = db.collection('moderation_reports');
    final doc = await col.findOne(where.eq('postId', postId));
    if (doc == null) return null;
    return ModerationReportModel.fromMap(doc);
  }

  Future<ModerationReportModel?> getById(String id) async {
    final db = await MongodbService.db;
    final col = db.collection('moderation_reports');
    final doc = await col.findOne(where.id(ObjectId.fromHexString(id)));
    if (doc == null) return null;
    return ModerationReportModel.fromMap(doc);
  }

  /// Submits or updates a moderation report. 
  /// Increments report_count in reports collection.
  /// If count >= 3, marks post as 'under_review'.
  Future<void> submitUserReport({
    required String postId,
    required String postTitle,
    required String uploaderName,
    required String? postImageUrl,
    required String reporterName,
    required String reporterNim,
    required String reason,
  }) async {
    final db = await MongodbService.db;
    final reportsCol = db.collection('reports');
    final modCol = db.collection('moderation_reports');

    // 1. Find the actual post
    final postDoc = await reportsCol.findOne(where.id(ObjectId.fromHexString(postId)));
    if (postDoc == null) throw Exception("Postingan tidak ditemukan.");

    // 2. Check if user already reported this post
    final existingMod = await modCol.findOne(where.eq('postId', postId));
    if (existingMod != null) {
      final reporters = (existingMod['reporters'] as List<dynamic>? ?? []);
      final alreadyReported = reporters.any((r) => r['nim'] == reporterNim);
      if (alreadyReported) {
        throw Exception("Anda sudah melaporkan postingan ini sebelumnya.");
      }
    }

    // 3. Increment report_count in Reports
    await reportsCol.updateOne(
      where.id(ObjectId.fromHexString(postId)),
      modify.inc('report_count', 1).set('last_activity_at', DateTime.now().toIso8601String()),
    );

    // Get updated count
    final updatedPost = await reportsCol.findOne(where.id(ObjectId.fromHexString(postId)));
    final int newCount = (updatedPost?['report_count'] ?? 0) as int;

    // 4. Auto-Takedown (under_review) if count >= 3 (Lowered from 5)
    if (newCount >= 3) {
      final currentStatus = updatedPost?['status_postingan']?.toString() ?? 'lost';
      if (currentStatus != 'resolved' && currentStatus != 'blocked') {
        await reportsCol.updateOne(
          where.id(ObjectId.fromHexString(postId)),
          modify.set('status_postingan', 'under_review'),
        );
        
        // Notify staff
        await _notifRepo.createNotification(NotificationModel(
          userId: 'staff_general', 
          judul: 'Peringatan Moderasi Otomatis',
          pesan: 'Postingan "$postTitle" otomatis diturunkan sementara karena mencapai $newCount laporan. Silakan tinjau.',
          tipeNotif: 'report',
          createdAt: DateTime.now(),
        ));
      }
    }

    // 5. Update or Create Moderation Report entry
    final newReporter = ModerationReporter(name: reporterName, nim: reporterNim, reason: reason);

    if (existingMod != null) {
      await modCol.updateOne(
        where.eq('postId', postId),
        modify.push('reporters', newReporter.toMap()).set('status', 'pending').set('reportedAt', DateTime.now().toIso8601String()),
      );
    } else {
      final newMod = ModerationReportModel(
        postId: postId,
        postTitle: postTitle,
        reportReason: reason, 
        uploaderName: uploaderName,
        postImageUrl: postImageUrl,
        reporters: [newReporter],
        status: 'pending',
        reportedAt: DateTime.now(),
      );
      final data = newMod.toMap();
      data.remove('_id');
      await col.insertOne(data);
    }
  }

  Future<void> takedown(String id) async {
    final db = await MongodbService.db;
    final modCol = db.collection('moderation_reports');
    final reportsCol = db.collection('reports');
    
    final modReport = await getById(id);
    if (modReport == null) return;

    await modCol.updateOne(
      where.id(ObjectId.fromHexString(id)),
      modify.set('status', 'takenDown'),
    );

    await reportsCol.updateOne(
      where.id(ObjectId.fromHexString(modReport.postId)),
      modify.set('status_postingan', 'blocked'),
    );

    final post = await reportsCol.findOne(where.id(ObjectId.fromHexString(modReport.postId)));
    if (post != null) {
      await _notifRepo.createNotification(NotificationModel(
        userId: post['userId'].toString(),
        judul: 'Postingan Dihapus',
        pesan: 'Postingan Anda "${modReport.postTitle}" telah dihapus oleh tim moderasi karena melanggar aturan komunitas.',
        tipeNotif: 'system',
        createdAt: DateTime.now(),
      ));
    }
  }

  Future<void> ignore(String id) async {
    final db = await MongodbService.db;
    final modCol = db.collection('moderation_reports');
    final reportsCol = db.collection('reports');

    final modReport = await getById(id);
    if (modReport == null) return;

    await modCol.updateOne(
      where.id(ObjectId.fromHexString(id)),
      modify.set('status', 'ignored'),
    );

    final post = await reportsCol.findOne(where.id(ObjectId.fromHexString(modReport.postId)));
    if (post != null) {
      final currentStatus = post['status_postingan']?.toString();
      if (currentStatus == 'under_review') {
        await reportsCol.updateOne(
          where.id(ObjectId.fromHexString(modReport.postId)),
          modify.set('status_postingan', 'lost'), 
        );
      }
      
      await reportsCol.updateOne(
        where.id(ObjectId.fromHexString(modReport.postId)),
        modify.set('report_count', 0),
      );
    }
  }
}
