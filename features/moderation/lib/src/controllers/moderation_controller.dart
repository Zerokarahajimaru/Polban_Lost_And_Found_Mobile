import 'package:flutter/foundation.dart';
import '../models/moderation_report.dart';
import '../repositories/moderation_repository.dart';

class ModerationController extends ChangeNotifier {
  final _repository = ModerationRepository();

  List<ModerationReport> _reports = [];
  bool _isLoading = false;
  String _message = '';
  bool _lastOperationFailed = false;

  List<ModerationReport> get reports => _reports;
  bool get isLoading => _isLoading;
  String get message => _message;
  bool get lastOperationFailed => _lastOperationFailed;

  List<ModerationReport> get pendingReports =>
      _reports.where((r) => r.status == ModerationStatus.pending).toList();

  void clearMessage() {
    _message = '';
  }


  Future<void> loadReports() async {
    _isLoading = true;
    notifyListeners();

    try {
      _reports = await _repository.fetchReports();
      _lastOperationFailed = false;
    } catch (e) {
      _message = 'Gagal memuat laporan moderasi.';
      _lastOperationFailed = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> takedownReport(String reportId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.takedown(reportId);

      _reports.removeWhere((r) => r.id == reportId);
      _message = 'Postingan berhasil ditakedown.';
      _lastOperationFailed = false;
    } catch (e) {
      _message = 'Gagal melakukan takedown. Coba lagi.';
      _lastOperationFailed = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> ignoreReport(String reportId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.ignore(reportId);

      _reports.removeWhere((r) => r.id == reportId);
      _message = 'Laporan diabaikan.';
      _lastOperationFailed = false;
    } catch (e) {
      _message = 'Gagal mengabaikan laporan. Coba lagi.';
      _lastOperationFailed = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}