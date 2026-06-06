import 'package:mongo_dart/mongo_dart.dart';
import '../models/moderation_report.dart';
import '../services/mongodb_service.dart';

class ModerationRepository {
  Future<List<ModerationReportModel>> getAllReports() async {
    final db = await MongodbService.db;
    final col = db.collection('moderation_reports');
    final results = await col.find().toList();
    return results.map((doc) {
      doc['_id'] = (doc['_id'] as ObjectId).toHexString();
      return ModerationReportModel.fromMap(doc);
    }).toList();
  }

  Future<List<ModerationReportModel>> getPendingReports() async {
    final db = await MongodbService.db;
    final col = db.collection('moderation_reports');
    final results =
        await col.find(where.eq('status', 'pending')).toList();
    return results.map((doc) {
      doc['_id'] = (doc['_id'] as ObjectId).toHexString();
      return ModerationReportModel.fromMap(doc);
    }).toList();
  }

  Future<ModerationReportModel?> getById(String id) async {
    final db = await MongodbService.db;
    final col = db.collection('moderation_reports');
    final doc = await col.findOne(where.id(ObjectId.fromHexString(id)));
    if (doc == null) return null;
    doc['_id'] = (doc['_id'] as ObjectId).toHexString();
    return ModerationReportModel.fromMap(doc);
  }

  Future<String> createReport(ModerationReportModel report) async {
    final db = await MongodbService.db;
    final col = db.collection('moderation_reports');
    final data = report.toMap();
    data.remove('_id');
    final result = await col.insertOne(data);
    return (result.id as ObjectId).toHexString();
  }

  Future<void> updateStatus(String id, String status) async {
    final db = await MongodbService.db;
    final col = db.collection('moderation_reports');
    await col.updateOne(
      where.id(ObjectId.fromHexString(id)),
      modify.set('status', status),
    );
  }

  Future<void> takedown(String id) async {
    final db = await MongodbService.db;
    
    // 1. Get the moderation report to find the postId
    final modReport = await getById(id);
    if (modReport == null) return;

    // 2. Update moderation report status
    await updateStatus(id, 'takenDown');

    // 3. EFFECT: Mark the actual report as 'blocked' or 'deleted'
    final reportsCol = db.collection('reports');
    await reportsCol.updateOne(
      where.id(ObjectId.fromHexString(modReport.postId)),
      modify.set('status_postingan', 'blocked'),
    );
  }

  Future<void> ignore(String id) async {
    await updateStatus(id, 'ignored');
  }
}
