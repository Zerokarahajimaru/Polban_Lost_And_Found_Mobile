import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl:
              // Ganti dengan IP Laptop/Server
              'http://192.168.1.10:3000/api',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

  // Fungsi sakti untuk GET data (Ambil data)
  Future<Response> getRequest(String endpoint) async {
    try {
      return await _dio.get(endpoint);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Fungsi sakti untuk POST data (Kirim data)
  Future<Response> postRequest(String endpoint, dynamic data) async {
    try {
      return await _dio.post(endpoint, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling sederhana biar gak crash
  String _handleError(DioException e) {
    return e.response?.data['message'] ?? "terdapat masalah koneksi!";
  }
}
