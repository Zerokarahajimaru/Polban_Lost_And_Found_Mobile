import 'package:dio/dio.dart';

class ApiService {
  ApiService._privateConstructor() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:8080',
      ),
    );
  }

  static final ApiService _instance = ApiService._privateConstructor();

  static ApiService get instance => _instance;

  late final Dio _dio;

  Dio get dio => _dio;


  Future<Response?> getAdminStats() async {
    try {
      final response = await _dio.get('/stats/admin_stats');
      if (response.statusCode == 200) {
        return response;
      }
      return null;
    } catch (e) {
      print('Error ApiService Admin Stats: $e');
      return null;
    }
  }
}