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
}
