import 'package:backend/src/models/report.dart';
import 'package:backend/src/services/mongodb_service.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ReportController {
  ReportController(this.dbService);

  final MongodbService dbService;

  Future<List<Map<String, dynamic>>> getAllReports() async {
    final reports = await dbService.db.collection('reports').find().toList();
    return reports;
  }

  Future<Map<String, dynamic>> createReport(ReportModel report) async {
    final result =
        await dbService.db.collection('reports').insertOne(report.toMap());
    return result.document!;
  }

  void updateReport(dynamic reportData) {
    debugPrint("Fungsi updateReport dipanggil sementara (UI Test)");
  }
}