import 'dart:io';

import 'package:core_module/core_module.dart' hide ReportModel;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:report/src/models/report_model.dart';
import 'package:report/src/repositories/report_repository.dart';

/// Enum to represent the different states of the controller.
enum NotifierState { initial, loading, loaded, error }

/// The controller for the report feature.
///
/// This class orchestrates the business logic for fetching and creating reports.
/// It uses [ChangeNotifier] to notify the UI about state changes.
class ReportController extends ChangeNotifier {
  final _reportRepository = ReportRepository();
  final _cloudinaryService = CloudinaryService();
  final _imagePicker = ImagePicker();

  // Private state properties
  NotifierState _state = NotifierState.initial;
  List<ReportModel> _reports = [];
  String _message = '';

  // Public getters for the UI to read the state
  NotifierState get state => _state;
  List<ReportModel> get reports => _reports;
  String get message => _message;

  /// Fetches the list of reports from the repository.
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

  /// The full flow for creating a new report.
  /// The image file is passed in from the UI.
  Future<void> createReport({
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
    try {
      // 1. Upload image to Cloudinary (image is already picked by UI)
      _message = 'Mengunggah gambar...';
      notifyListeners();
      final imageUrl = await _cloudinaryService.uploadImage(imageFile);

      // 2. Post report data (with image URL) to the repository
      _message = 'Mengirim laporan...';
      notifyListeners();
      final postData = {
        'title': title,
        'description': '$description\n\nKontak: $contact',
        'imageUrl': imageUrl,
        'location': location,
        'category': category,
        'reward': reward,
        'status': status,
      };
      await _reportRepository.postReport(postData: postData);

      // 3. Refresh the list to show the newly created report
      _message = 'Laporan berhasil dibuat!';
      await getReports(); // This will set the final state to 'loaded'
    } on OfflinePostException catch (e) {
      _message = e.toString();
      _setState(NotifierState.error);
    } catch (e) {
      _message = e.toString();
      _setState(NotifierState.error);
    }
  }

  // Helper function to update state and notify listeners.
  void _setState(NotifierState newState) {
    _state = newState;
    notifyListeners();
  }
}