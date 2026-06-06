import 'dart:io';
import 'package:core_module/core_module.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ReportController extends ChangeNotifier {
  final _reportRepository = ReportRepository();

  List<ReportModel> _reports = [];
  List<ReportModel> _myReports = []; // Dedicated list for personal reports
  String _message = '';
  bool _isLoading = false;
  bool _lastOperationFailed = false;

  List<ReportModel> get reports => _reports;
  List<ReportModel> get myReports => _myReports;
  String get message => _message;
  bool get isLoading => _isLoading;
  bool get lastOperationFailed => _lastOperationFailed;

  void clearData() {
    _reports = [];
    _myReports = [];
    _message = '';
    notifyListeners();
  }

  void clearMessage() {
    _message = '';
  }

  /// Fetches ALL reports for the public feed.
  Future<void> getReports() async {
    _isLoading = true;
    notifyListeners();

    try {
      final newReports = await _reportRepository.getReports();
      _reports = newReports;
      _lastOperationFailed = false;
    } catch (e) {
      _message = e.toString();
      _lastOperationFailed = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches reports filtered by [userId] for the "My Reports" page.
  Future<void> getMyReports(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await _reportRepository.getReports(userId: userId);
      _myReports = results;
      _lastOperationFailed = false;
    } catch (e) {
      _message = e.toString();
      _lastOperationFailed = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> finalizeReport({
    required Map<String, dynamic> reportData,
    File? imageFile,
    String? existingId,
    String? userId,
  }) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final dataWithUser = {...reportData, if (userId != null) 'userId': userId};
      
      if (existingId != null && existingId.startsWith('draft_')) {
        if (imageFile == null) throw Exception("Gambar wajib untuk finalisasi draft.");
        try {
          await _reportRepository.postReportOnline(reportData: dataWithUser, imageFile: imageFile);
          _message = 'Laporan berhasil dikirim!';
          _lastOperationFailed = false;
        } on DioException catch (e) {
          if (_isNetworkError(e)) {
            await _reportRepository.queueCreateForSync(reportData: dataWithUser, localImagePath: imageFile.path);
            _message = 'Koneksi Gagal. Laporan disimpan untuk sinkronisasi otomatis.';
            _lastOperationFailed = false;
          } else {
            rethrow;
          }
        }
        await _reportRepository.deleteReport(existingId, 'draft');

      } else if (existingId != null && existingId.startsWith('pending_')) {
        await _reportRepository.queueUpdateForSync(id: existingId, reportData: dataWithUser, localImagePath: imageFile?.path);
        _message = 'Perubahan disimpan di antrian untuk sinkronisasi.';
        _lastOperationFailed = false;

      } else if (existingId != null) {
        await _reportRepository.updateReportOnline(id: existingId, reportData: dataWithUser, imageFile: imageFile);
        _message = 'Laporan berhasil diperbarui!';
        _lastOperationFailed = false;

      } else {
        if (imageFile == null) throw Exception("Gambar wajib untuk laporan baru.");
        try {
          await _reportRepository.postReportOnline(reportData: dataWithUser, imageFile: imageFile);
          _message = 'Laporan berhasil dikirim!';
          _lastOperationFailed = false;
        } on DioException catch (e) {
          if (_isNetworkError(e)) {
            // [QA] Auto-save as draft on network failure for NEW reports
            await _reportRepository.saveAsDraft(
              reportData: dataWithUser,
              localImagePath: imageFile.path,
            );
            _message = 'Koneksi Bermasalah. Laporan otomatis disimpan sebagai Draft.';
            _lastOperationFailed = false; // Set to false because we handled it by saving as draft
          } else {
            rethrow;
          }
        }
      }
      
      // Refresh both lists
      await getReports();
      if (userId != null) await getMyReports(userId);
      
    } on DioException catch (e) {
      _message = 'Gagal: ${e.response?.data?['message'] ?? e.message}';
      _lastOperationFailed = true;
    } catch (e) {
      _message = 'Terjadi error: $e';
      _lastOperationFailed = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveAsDraft({
    required Map<String, dynamic> reportData,
    String? localImagePath,
    String? existingId,
    String? userId,
  }) async {
    try {
      final dataWithUser = {...reportData, if (userId != null) 'userId': userId};
      await _reportRepository.saveAsDraft(
        reportData: dataWithUser,
        localImagePath: localImagePath,
        existingId: existingId,
      );
      _message = 'Draft berhasil disimpan.';
      _lastOperationFailed = false;
      if (userId != null) await getMyReports(userId);
    } catch (e) {
      _message = 'Gagal menyimpan draft: $e';
      _lastOperationFailed = true;
      notifyListeners();
    }
  }
  
  Future<void> refreshFromCache() async {
    _reports = await _reportRepository.loadFromCacheOnly();
    notifyListeners();
  }

  Future<void> deleteReport(String id, String status, {String? userId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _reportRepository.deleteReport(id, status);
      _message = 'Laporan berhasil dihapus.';
      _lastOperationFailed = false;
      await getReports();
      if (userId != null) await getMyReports(userId);
    } catch (e) {
      _message = 'Gagal menghapus laporan: $e';
      _lastOperationFailed = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
           e.type == DioExceptionType.connectionTimeout ||
           e.type == DioExceptionType.unknown;
  }
}
