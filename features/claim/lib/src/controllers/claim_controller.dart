import 'package:flutter/material.dart';
import '../models/claim_model.dart';
import '../repositories/claim_repository.dart';

/// Enum untuk melacak status pengiriman data
enum ClaimState { initial, loading, success, error }

class ClaimController extends ChangeNotifier {
  final ClaimRepository _repository;

  ClaimController({required ClaimRepository repository}) : _repository = repository;

  ClaimState _state = ClaimState.initial;
  String _errorMessage = '';

  // --- Getters ---
  ClaimState get state => _state;
  String get errorMessage => _errorMessage;

  /// Fungsi Utama: Mengirim klaim ke server
  Future<bool> sendClaim(ClaimModel claim) async {
    _state = ClaimState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final isSuccess = await _repository.submitClaim(claim);

      if (isSuccess) {
        _state = ClaimState.success;
        notifyListeners();
        return true;
      } else {
        _state = ClaimState.error;
        _errorMessage = 'Gagal mengirim pengajuan klaim. Silakan coba lagi.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _state = ClaimState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Reset state jika user ingin mengulang pengisian form
  void resetState() {
    _state = ClaimState.initial;
    _errorMessage = '';
    notifyListeners();
  }
}