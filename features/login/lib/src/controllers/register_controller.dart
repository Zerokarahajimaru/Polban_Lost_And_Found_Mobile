import 'dart:async';
import 'package:core_module/core_module.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class RegisterController extends ChangeNotifier {
  final NetworkService _networkService;

  RegisterController({NetworkService? networkService})
      : _networkService = networkService ?? NetworkService();

  NotifierState _state = NotifierState.initial;
  String _message = '';

  NotifierState get state => _state;
  String get message => _message;

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setState(NotifierState.loading, 'Registering...');
    try {
      final response = await _networkService.dio.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 201) {
        _setState(NotifierState.loaded, 'Registration successful!');
        return true;
      } else {
        _setState(NotifierState.error, 'Pendaftaran gagal.');
        return false;
      }
    } on TimeoutException {
      _setState(NotifierState.error, 'Waktu koneksi habis. Periksa internet Anda.');
      return false;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] as String? ?? 'Gagal terhubung ke server.';
      _setState(NotifierState.error, errorMessage);
      return false;
    } catch (e) {
      _setState(NotifierState.error, 'Terjadi kesalahan: $e');
      return false;
    }
  }

  void _setState(NotifierState state, String message) {
    _state = state;
    _message = message;
    notifyListeners();
  }
}
