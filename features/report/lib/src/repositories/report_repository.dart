import 'package:core_module/core_module.dart';
import 'package:dio/dio.dart';
import 'package:features_report/src/services/image_upload_service.dart';
import 'package:hive/hive.dart';

class ReportRepository {
  ReportRepository(this._apiService, this._hiveService, this._imageUploadService);

  final ApiService _apiService;
  final HiveService _hiveService;
  final ImageUploadService _imageUploadService;
  late Box<ReportModel> _reportBox;

  Future<void> init() async {
    await _hiveService.init();
    _reportBox = await _hiveService.openBox<ReportModel>('reports');
  }

  Future<List<ReportModel>> getAllReports() async {
    // Try to fetch from API
    try {
      final response = await _apiService.dio.get('/reports');
      final List<dynamic> data = response.data as List<dynamic>;
      final reports = data.map((e) => ReportModel.fromMap(e as Map<String, dynamic>)).toList();

      // Cache reports
      await _reportBox.clear();
      await _reportBox.addAll(reports);
      return reports;
    } catch (e) {
      // If API call fails, return cached reports
      return _reportBox.values.toList();
    }
  }

  Future<ReportModel> createReport(ReportModel report, List<File> images) async {
    // Upload images to Firebase Storage
    final imageUrls = await _imageUploadService.uploadImages(images, report.id ?? 'new_report');

    // Create a new report with image URLs
    final newReport = ReportModel(
      id: report.id,
      userId: report.userId,
      namaBarang: report.namaBarang,
      kategoriBarang: report.kategoriBarang,
      statusPostingan: report.statusPostingan,
      deskripsiBarang: report.deskripsiBarang,
      lokasiKehilangan: report.lokasiKehilangan,
      warnaBarang: report.warnaBarang,
      kontak: report.kontak,
      reportCount: report.reportCount,
      lastActivityAt: report.lastActivityAt,
      createdAt: report.createdAt,
      updatedAt: report.updatedAt,
      isSynced: false, // Mark as not synced initially
      images: imageUrls,
      bounty: report.bounty,
    );

    // Send to API
    try {
      final response = await _apiService.dio.post('/reports', data: newReport.toMap());
      final createdReport = ReportModel.fromMap(response.data as Map<String, dynamic>);

      // Update local cache
      await _reportBox.put(createdReport.id, createdReport.copyWith(isSynced: true));
      return createdReport;
    } catch (e) {
      // If API call fails, save locally
      await _reportBox.put(newReport.id, newReport);
      return newReport;
    }
  }
}

extension ReportModelCopyWith on ReportModel {
  ReportModel copyWith({
    String? id,
    String? userId,
    String? namaBarang,
    String? kategoriBarang,
    String? statusPostingan,
    String? deskripsiBarang,
    String? lokasiKehilangan,
    String? warnaBarang,
    String? kontak,
    int? reportCount,
    DateTime? lastActivityAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    List<String>? images,
    BountyModel? bounty,
  }) {
    return ReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      namaBarang: namaBarang ?? this.namaBarang,
      kategoriBarang: kategoriBarang ?? this.kategoriBarang,
      statusPostingan: statusPostingan ?? this.statusPostingan,
      deskripsiBarang: deskripsiBarang ?? this.deskripsiBarang,
      lokasiKehilangan: lokasiKehilangan ?? this.lokasiKehilangan,
      warnaBarang: warnaBarang ?? this.warnaBarang,
      kontak: kontak ?? this.kontak,
      reportCount: reportCount ?? this.reportCount,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      images: images ?? this.images,
      bounty: bounty ?? this.bounty,
    );
  }
}