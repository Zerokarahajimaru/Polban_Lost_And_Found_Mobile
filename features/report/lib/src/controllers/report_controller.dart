import 'dart:io';

import 'package:core_module/core_module.dart' hide ReportModel;
import 'package:flutter/material.dart';
import 'package:report/src/models/report_model.dart';
import 'package:report/src/repositories/report_repository.dart';

/// Enum to represent the different states of the controller.
enum NotifierState { initial, loading, loaded, error }

/// The controller for the report feature.
class ReportController extends ChangeNotifier {
  final _reportRepository = ReportRepository();

  // Private state properties
  NotifierState _state = NotifierState.initial;
  List<ReportModel> _reports = [];
  String _message = '';

  // Public getters for the UI to read the state
  NotifierState get state => _state;
  List<ReportModel> get reports => _reports;
  String get message => _message;

  /// Fetches the list of reports, which also triggers a sync attempt.
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

  /// Creates a new report by queuing it for synchronization.
  /// Returns `true` if queuing is successful, `false` otherwise.
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
    _message = 'Menyimpan laporan ke antrian...';
    notifyListeners();

    try {
      final reportData = {
        'title': title,
        'description': description,
        'location': location,
        'contact': contact,
        'category': category,
        'reward': reward,
        'status': status,
      };

      await _reportRepository.queueReportForSync(
        reportData: reportData,
        localImagePath: imageFile.path,
      );

      _message = 'Laporan berhasil disimpan & akan disinkronisasi.';
      _setState(NotifierState.loaded);
      return true; // Signal success for navigation
    } catch (e) {
      _message = 'Gagal menyimpan laporan lokal: $e';
      _setState(NotifierState.error);
      return false; // Signal failure
    }
  }

  // Helper function to update state and notify listeners.
  void _setState(NotifierState newState) {
    _state = newState;
    notifyListeners();
  }
}