import 'dart:io';
import 'package:core_module/core_module.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:report/src/repositories/report_repository.dart';

class ReportController extends ChangeNotifier {
  final _reportRepository = ReportRepository();

  List<ReportModel> _reports = [];
  String _message = '';
  bool _isLoading = false;
  bool _lastOperationFailed = false;

  List<ReportModel> get reports => _reports;
  String get message => _message;
  bool get isLoading => _isLoading;
  bool get lastOperationFailed => _lastOperationFailed;

  void clearMessage() {
    _message = '';
  }

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
            _message = 'Koneksi Gagal. Laporan disimpan untuk sinkronisasi.';
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
        await _reportRepository.postReportOnline(reportData: dataWithUser, imageFile: imageFile);
        _message = 'Laporan berhasil dikirim!';
        _lastOperationFailed = false;
      }
      
      // Refresh to update Home and History
      await getReports();
      
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
      await getReports();
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

  Future<void> deleteReport(String id, String status) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _reportRepository.deleteReport(id, status);
      _message = 'Laporan berhasil dihapus.';
      _lastOperationFailed = false;
      await getReports();
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
