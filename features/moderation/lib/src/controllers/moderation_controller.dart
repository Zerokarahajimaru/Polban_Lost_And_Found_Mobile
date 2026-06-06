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

  Future<void> submitReport({
    required String postId,
    required String postTitle,
    required String reportReason,
    required String uploaderName,
    String? postImageUrl,
    required String reporterName,
    required String reporterNim,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.submitReport(
        postId: postId,
        postTitle: postTitle,
        reportReason: reportReason,
        uploaderName: uploaderName,
        postImageUrl: postImageUrl,
        reporterName: reporterName,
        reporterNim: reporterNim,
      );
      _message = 'Laporan berhasil dikirimkan.';
      _lastOperationFailed = false;
    } catch (e) {
      _message = e.toString().contains("sudah melaporkan") 
          ? "Anda sudah melaporkan postingan ini sebelumnya." 
          : 'Gagal mengirimkan laporan. Coba lagi.';
      _lastOperationFailed = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkIfUserReported(String postId, String nim) async {
    try {
      // In a real app, we might have a specific endpoint for this.
      // For now, we search in the existing reports list.
      final list = await _repository.fetchReports();
      return list.any((r) => r.id.contains(postId) && r.reporters.any((rep) => rep.nim == nim));
    } catch (e) {
      return false;
    }
  }
}
