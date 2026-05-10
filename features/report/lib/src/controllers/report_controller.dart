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
  }) async {
    try {
      if (existingId != null && (existingId.startsWith('pending_') || existingId.startsWith('draft_'))) {
        await _reportRepository.queueUpdateForSync(id: existingId, reportData: reportData, localImagePath: imageFile?.path);
        _message = 'Perubahan disimpan di antrian untuk sinkronisasi.';
      } else if (existingId != null) {
        await _reportRepository.updateReportOnline(id: existingId, reportData: reportData, imageFile: imageFile);
        _message = 'Laporan berhasil diperbarui!';
      } else {
        if (imageFile == null) throw Exception("Gambar wajib untuk laporan baru.");
        await _reportRepository.postReportOnline(reportData: reportData, imageFile: imageFile);
        _message = 'Laporan berhasil dikirim!';
      }
      _lastOperationFailed = false;
    } on DioException catch (e) {
      _lastOperationFailed = true;
      if (_isNetworkError(e)) {
        _message = 'Koneksi Gagal. Laporan disimpan untuk sinkronisasi.';
        if (existingId != null) {
          await _reportRepository.queueUpdateForSync(id: existingId, reportData: reportData, localImagePath: imageFile?.path);
        } else {
          await _reportRepository.queueCreateForSync(reportData: reportData, localImagePath: imageFile!.path);
        }
      } else {
        _message = 'Gagal: ${e.message}';
      }
    } catch (e) {
      _message = 'Terjadi error: $e';
      _lastOperationFailed = true;
    } finally {
      notifyListeners();
    }
  }

  Future<void> saveAsDraft({
    required Map<String, dynamic> reportData,
    String? localImagePath,
    String? existingId,
  }) async {
    try {
      // Fire-and-forget the repository call to ensure no blocking.
      _reportRepository.saveAsDraft(
        reportData: reportData, 
        localImagePath: localImagePath, 
        existingId: existingId
      );
      _message = 'Laporan berhasil disimpan sebagai draft.';
      _lastOperationFailed = false;
    } catch (e) {
      _message = 'Gagal menyimpan draft: $e';
      _lastOperationFailed = true;
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteReport(String id, String status) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _reportRepository.deleteReport(id, status);
      _message = 'Laporan berhasil dihapus.';
      _lastOperationFailed = false;
    } catch (e) {
      _message = 'Gagal menghapus laporan: $e';
      _lastOperationFailed = true;
    } finally {
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