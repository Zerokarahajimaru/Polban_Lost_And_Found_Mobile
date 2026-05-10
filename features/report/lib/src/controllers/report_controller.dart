import 'dart:io';
import 'package:core_module/core_module.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:report/src/repositories/report_repository.dart';

class ReportController extends ChangeNotifier {
  final _reportRepository = ReportRepository();

  NotifierState _state = NotifierState.initial;
  List<ReportModel> _reports = [];
  String _message = '';

  NotifierState get state => _state;
  List<ReportModel> get reports => _reports;
  String get message => _message;

  /// The definitive fix for the UI freeze bug.
  /// This method now avoids setting a synchronous loading state if data already exists.
  /// It fetches new data in the background and only notifies listeners upon completion
  /// or error, preventing a UI rebuild from racing with navigation animations.
  Future<void> getReports() async {
    // Only show a loading spinner if there's no data to display.
    if (_reports.isEmpty) {
      _setState(NotifierState.loading);
    }

    try {
      // Fetch new data in the background.
      final newReports = await _reportRepository.getReports();
      _reports = newReports;
      _message = ''; // Clear previous messages
      _setState(NotifierState.loaded); // Notify UI to rebuild with new data.
    } catch (e) {
      _message = e.toString();
      _setState(NotifierState.error); // Notify UI about the error.
    }
  }

  Future<bool> finalizeReport({
    required Map<String, dynamic> reportData,
    File? imageFile,
    String? existingId,
  }) async {
    _setState(NotifierState.loading);
    _message = 'Finalisasi laporan...';
    notifyListeners();

    try {
      if (existingId != null && (existingId.startsWith('pending_') || existingId.startsWith('draft_'))) {
         try {
          await _reportRepository.queueUpdateForSync(id: existingId, reportData: reportData, localImagePath: imageFile?.path);
          _message = 'Perubahan disimpan di antrian untuk sinkronisasi.';
          _setState(NotifierState.loaded);
          return true;
        } catch(e) {
          _message = 'Gagal menyimpan perubahan draft: $e';
          _setState(NotifierState.error);
          return false;
        }
      }

      if (existingId != null) {
        await _reportRepository.updateReportOnline(id: existingId, reportData: reportData, imageFile: imageFile);
        _message = 'Laporan berhasil diperbarui!';
      } else {
        if (imageFile == null) throw Exception("Gambar wajib untuk laporan baru.");
        await _reportRepository.postReportOnline(reportData: reportData, imageFile: imageFile);
        _message = 'Laporan berhasil dikirim!';
      }
      _setState(NotifierState.loaded);
      return true;
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        _message = 'Koneksi Gagal. Laporan disimpan untuk sinkronisasi.';
        if (existingId != null) {
          await _reportRepository.queueUpdateForSync(id: existingId, reportData: reportData, localImagePath: imageFile?.path);
        } else {
          await _reportRepository.queueCreateForSync(reportData: reportData, localImagePath: imageFile!.path);
        }
        _setState(NotifierState.loaded);
        return true;
      }
      _message = 'Gagal: ${e.message}';
      _setState(NotifierState.error);
      return false;
    } catch (e) {
      _message = 'Terjadi error: $e';
      _setState(NotifierState.error);
      return false;
    }
  }

  Future<bool> saveAsDraft({
    required Map<String, dynamic> reportData,
    String? localImagePath,
    String? existingId,
  }) async {
    _setState(NotifierState.loading);
    _message = 'Menyimpan sebagai draft...';
    notifyListeners();
    try {
      await _reportRepository.saveAsDraft(reportData: reportData, localImagePath: localImagePath, existingId: existingId);
      _message = 'Laporan berhasil disimpan sebagai draft.';
      _setState(NotifierState.loaded);
      return true;
    } catch (e) {
      _message = 'Gagal menyimpan draft: $e';
      _setState(NotifierState.error);
      return false;
    }
  }

  Future<bool> deleteReport(String id, String status) async {
    _setState(NotifierState.loading);
    _message = 'Menghapus laporan...';
    notifyListeners();
    try {
      await _reportRepository.deleteReport(id, status);
      _message = 'Laporan berhasil dihapus.';
      _setState(NotifierState.loaded);
      return true;
    } catch (e) {
      _message = 'Gagal menghapus laporan: $e';
      _setState(NotifierState.error);
      return false;
    }
  }

  bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
           e.type == DioExceptionType.connectionTimeout ||
           e.type == DioExceptionType.unknown;
  }

  void _setState(NotifierState newState) {
    _state = newState;
    notifyListeners();
  }
}