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

  Future<bool> login(String email, String password) async {
    _setState(NotifierState.loading, 'Logging in...');
    try {
      final response = await _networkService.dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final userData = response.data['user'] as Map<String, dynamic>;
        _loggedInUser = UserModel.fromMap(userData);
        _setState(NotifierState.loaded, 'Login successful!');
        return true;
      } else {
        _setState(NotifierState.error, 'An unknown error occurred.');
        return false;
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['message'] as String? ?? e.message ?? 'Login failed';
      _setState(NotifierState.error, errorMessage);
      return false;
    } catch (e) {
      _setState(NotifierState.error, 'An unexpected error occurred: $e');
      return false;
    }
  }

  void _setState(NotifierState state, String message) {
    _state = state;
    _message = message;
    notifyListeners();
  }
}