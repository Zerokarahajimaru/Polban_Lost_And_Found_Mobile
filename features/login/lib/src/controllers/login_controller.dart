import 'dart:async';
import 'package:core_module/core_module.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class LoginController extends ChangeNotifier {
  final NetworkService _networkService = NetworkService();

  NotifierState _state = NotifierState.initial;
  String _message = '';
  UserModel? _loggedInUser;

  NotifierState get state => _state;
  String get message => _message;
  UserModel? get loggedInUser => _loggedInUser;

  static const _mockAccounts = [
    {
      'email': 'teknisi@polban.ac.id',
      'password': 'teknisi123',
      'user': {
        'id': 'mock-teknisi-001',
        'name': 'Teknisi JTK',
        'email': 'teknisi@polban.ac.id',
        'role': 'teknisi',
      },
    },
    {
      'email': 'user@polban.ac.id',
      'password': 'user123',
      'user': {
        'id': 'mock-user-001',
        'name': 'Mahasiswa Polban',
        'email': 'user@polban.ac.id',
        'role': 'user',
      },
    },
  ];

  Future<bool> login(String email, String password) async {
    _setState(NotifierState.loading, 'Logging in...');

    try {
      final response = await _networkService.dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final userData = response.data['user'] as Map<String, dynamic>;

        _loggedInUser = UserModel.fromMap(userData);

        _setState(
          NotifierState.loaded,
          'Login berhasil!',
        );

        return true;
      } else {
        _setState(
          NotifierState.error,
          'Email atau password salah.',
        );

        return false;
      }
    } on DioException catch (_) {
      final mockMatch = _mockAccounts.where(
        (a) =>
            a['email'] == email &&
            a['password'] == password,
      );

      if (mockMatch.isNotEmpty) {
        await Future.delayed(
          const Duration(milliseconds: 500),
        );

        _loggedInUser = UserModel.fromMap(
          mockMatch.first['user']
              as Map<String, dynamic>,
        );

        _setState(
          NotifierState.loaded,
          'Login mock berhasil!',
        );

        return true;
      }

      _setState(
        NotifierState.error,
        'Gagal terhubung ke server.',
      );

      return false;
    } on TimeoutException {
      _setState(
        NotifierState.error,
        'Waktu koneksi habis.',
      );

      return false;
    } catch (e) {
      _setState(
        NotifierState.error,
        'Terjadi kesalahan: $e',
      );

      return false;
    }
  }

  void _setState(
    NotifierState state,
    String message,
  ) {
    _state = state;
    _message = message;
    notifyListeners();
  }
}