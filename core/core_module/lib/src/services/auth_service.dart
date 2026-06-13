import 'package:core_module/core_module.dart';

class AuthService {
  final _networkService = NetworkService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _networkService.dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      // Handle different kinds of errors, e.g., network, 401, etc.
      rethrow;
    }
  }
}
