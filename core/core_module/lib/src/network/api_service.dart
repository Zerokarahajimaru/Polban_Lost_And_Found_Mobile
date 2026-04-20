import 'package:dio/dio.dart';

class ApiService {
 final Dio _dio; 

ApiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'http://192.168.1.10:3000/api', // Ganti sama IP Laptop/Server kamu
            connectTimeout: const Duration(seconds: 10), // Biar gak nunggu selamanya
            receiveTimeout: const Duration(seconds: 10),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
}
