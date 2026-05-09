import 'dart:io';

import 'package:core_module/core_module.dart' hide ReportModel;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:report/src/models/report_model.dart';
import 'package:report/src/repositories/report_repository.dart';

enum NotifierState { initial, loading, loaded, error }

class ReportController extends ChangeNotifier {
  final _reportRepository = ReportRepository();

  NotifierState _state = NotifierState.initial;
  List<ReportModel> _reports = [];
  String _message = '';

  NotifierState get state => _state;
  List<ReportModel> get reports => _reports;
  String get message => _message;

  Future<void> getReports() async {
    _setState(NotifierState.loading);
    try {
      _reports = await _reportRepository.getReports();
      _setState(NotifierState.loaded);
    } catch (e) {
      _message = e.toString();
      _setState(NotifierState.error);
    }
  }

  Future<bool> createReport({
    required String title,
    required String description,
    required String location,
    required String contact,
    required String category,
    required File imageFile,
    String? reward,
    String status = 'lost',
  }) async {
    _setState(NotifierState.loading);
    _message = 'Mengirim laporan...';
    notifyListeners();

    final reportData = {
      'title': title, 'description': description, 'location': location,
      'contact': contact, 'category': category, 'reward': reward, 'status': status,
    };

    try {
      await _reportRepository.postReportOnline(reportData: reportData, imageFile: imageFile);
      _message = 'Laporan berhasil terkirim!';
      _setState(NotifierState.loaded);
      return true;
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        await _reportRepository.queueCreateForSync(reportData: reportData, localImagePath: imageFile.path);
        _message = 'Koneksi Gagal. Laporan disimpan untuk sinkronisasi.';
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

  Future<bool> updateReport({
    required String id,
    required String title,
    required String description,
    required String location,
    required String contact,
    required String category,
    String? reward,
    String status = 'lost',
    File? imageFile, // Image is optional on update
  }) async {
    _setState(NotifierState.loading);
    _message = 'Memperbarui laporan...';
    notifyListeners();

    final reportData = {
      'title': title, 'description': description, 'location': location,
      'contact': contact, 'category': category, 'reward': reward, 'status': status,
    };

    try {
      await _reportRepository.updateReportOnline(id: id, reportData: reportData, imageFile: imageFile);
      _message = 'Laporan berhasil diperbarui!';
      _setState(NotifierState.loaded);
      return true;
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        await _reportRepository.queueUpdateForSync(id: id, reportData: reportData, localImagePath: imageFile?.path);
        _message = 'Koneksi Gagal. Perubahan disimpan untuk sinkronisasi.';
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

  Future<void> deleteReport(String id) async {
    await _reportRepository.deletePendingReport(id);
    // Refresh the list after deleting
    await getReports();
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