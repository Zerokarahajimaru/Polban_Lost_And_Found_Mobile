import 'dart:async';
import 'package:core_module/core_module.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class LoginController extends ChangeNotifier {
  final NetworkService _networkService;

  LoginController({NetworkService? networkService})
      : _networkService = networkService ?? NetworkService();

  NotifierState _state = NotifierState.initial;
  String _message = '';
  UserModel? _loggedInUser;

  NotifierState get state => _state;
  String get message => _message;
  UserModel? get loggedInUser => _loggedInUser;

  Future<bool> login(String email, String password) async {
    _setState(NotifierState.loading, 'Logging in...');
    try {
      final response = await _networkService.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final userData = response.data['user'] as Map<String, dynamic>;
        _loggedInUser = UserModel.fromMap(userData);
        _setState(NotifierState.loaded, 'Login successful!');
        return true;
      } else {
        _setState(NotifierState.error, 'Email atau password salah.');
        return false;
      }
    } on TimeoutException {
      _setState(NotifierState.error, 'Waktu koneksi habis. Periksa internet Anda.');
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        _setState(NotifierState.error, 'Email atau password salah.');
      } else {
        final errorMessage = e.response?.data['message'] as String? ?? 'Gagal terhubung ke server.';
        _setState(NotifierState.error, errorMessage);
      }
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