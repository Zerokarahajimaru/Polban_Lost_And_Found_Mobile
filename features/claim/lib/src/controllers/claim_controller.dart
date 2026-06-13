import 'package:flutter/foundation.dart';
import 'package:core_module/core_module.dart';

class ClaimController extends ChangeNotifier {
  final _repository = ClaimRepository();

  List<ClaimModel> _claims = [];
  bool _isLoading = false;
  String _message = '';

  List<ClaimModel> get claims => _claims;
  bool get isLoading => _isLoading;
  String get message => _message;

  void clearData() {
    _claims = [];
    _message = '';
    notifyListeners();
  }

  Future<void> loadClaims() async {
    _isLoading = true;
    notifyListeners();

    try {
      _claims = await _repository.fetchClaims();
    } catch (e) {
      _message = 'Gagal memuat antrean klaim.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> finalizeVerification(String claimId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.verifyClaim(claimId, 'verify');
      _message = 'Verifikasi berhasil diselesaikan.';
      await loadClaims();
      return true;
    } catch (e) {
      _message = 'Gagal menyelesaikan verifikasi.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
