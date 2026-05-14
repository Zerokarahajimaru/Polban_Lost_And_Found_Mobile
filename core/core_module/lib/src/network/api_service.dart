import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  Dio get dio => _dio;

  ApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl:
                'http://192.168.1.14:8082', // Updated to the actual running server port
            connectTimeout:
                const Duration(seconds: 10), // Biar gak nunggu selamanya
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
}
