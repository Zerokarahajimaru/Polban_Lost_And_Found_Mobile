import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';
import '../models/admin_stat_model.dart';

class AdminStatController extends ChangeNotifier {
  AdminStatModel? _statsData;
  bool _isLoading = false;
  String? _errorMessage;

  AdminStatModel? get statsData => _statsData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchAdminStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Memanggil fungsi dio yang sudah kita tambahkan di ApiService kemarin
      final response = await ApiService.instance.getAdminStats();

      if (response != null && response.data != null) {
        // Mengonversi data JSON dari Dio menjadi AdminStatModel
        _statsData = AdminStatModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        _errorMessage = 'Gagal mengambil data statistik dari server';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan jaringan: $e';
    } finally {
      _isLoading = false;
      notifyListeners(); // Memperbarui tampilan UI Flutter
    }
  }
}