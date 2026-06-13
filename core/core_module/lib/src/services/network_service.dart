import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// A centralized network service for handling HTTP requests using Dio.
///
/// This class follows the Singleton pattern to provide a single,
/// configurable instance of Dio throughout the app.
class NetworkService {
  // Private constructor
  NetworkService._();

  // The single, static instance of this class.
  static final NetworkService _instance = NetworkService._();

  /// The factory constructor that returns the singleton instance.
  factory NetworkService() => _instance;

  late final Dio _dio;

  /// Initializes the [NetworkService] with a base URL.
  void init({required String baseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add logging interceptor for debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (o) => debugPrint(o.toString()),
        ),
      );
    }
  }

  /// Provides access to the configured Dio instance.
  Dio get dio {
    // Ensure that init() has been called before using the dio instance.
    try {
      return _dio;
    } catch (_) {
      throw Exception(
        'NetworkService has not been initialized. Please call init() in your main.dart',
      );
    }
  }
}