import 'dart:async';
import 'package:core_module/core_module.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login/src/controllers/register_controller.dart';
import 'package:mockito/mockito.dart';
import 'login_test.mocks.dart';

void main() {
  group('GROUP A — RegisterController.register()', () {
    late MockDio mockDio;
    late RegisterController controller;

    setUp(() {
      mockDio = MockDio();
      controller = RegisterController(
        networkService: _FakeNetworkService(mockDio),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test(
      'WB-R-01: statusCode 201 → state=loaded, message="Registration successful!", return true',
      () async {
        when(mockDio.post<dynamic>(
          '/register',
          data: anyNamed('data'),
        )).thenAnswer((_) async => Response(
              data: {
                'message': 'Registration successful!',
                'user': {
                  'id': 'usr_002',
                  'name': 'Doni',
                  'email': 'doni@polban.ac.id',
                  'role': 'user',
                },
              },
              statusCode: 201,
              requestOptions: RequestOptions(path: '/register'),
            ));

        final result = await controller.register(
          name: 'Doni',
          email: 'doni@polban.ac.id',
          password: 'password',
        );

        expect(result, isTrue);
        expect(controller.state, equals(NotifierState.loaded));
        expect(controller.message, equals('Registration successful!'));
      },
    );

    test(
      'WB-R-02: TimeoutException → state=error, return false',
      () async {
        when(mockDio.post<dynamic>(
          '/register',
          data: anyNamed('data'),
        )).thenThrow(TimeoutException('Connection timeout'));

        final result = await controller.register(
          name: 'Doni',
          email: 'doni@polban.ac.id',
          password: 'password',
        );

        expect(result, isFalse);
        expect(controller.state, equals(NotifierState.error));
        expect(
          controller.message,
          equals('Waktu koneksi habis. Periksa internet Anda.'),
        );
      },
    );

    test(
      'WB-R-03: DioException error → state=error, return false',
      () async {
        when(mockDio.post<dynamic>(
          '/register',
          data: anyNamed('data'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/register'),
          response: Response(
            statusCode: 400,
            data: {'message': 'Email is already registered.'},
            requestOptions: RequestOptions(path: '/register'),
          ),
          type: DioExceptionType.badResponse,
        ));

        final result = await controller.register(
          name: 'Doni',
          email: 'doni@polban.ac.id',
          password: 'password',
        );

        expect(result, isFalse);
        expect(controller.state, equals(NotifierState.error));
        expect(controller.message, equals('Email is already registered.'));
      },
    );

    test(
      'WB-R-04: Exception tak terduga → state=error, return false',
      () async {
        when(mockDio.post<dynamic>(
          '/register',
          data: anyNamed('data'),
        )).thenThrow(Exception('Unexpected error'));

        final result = await controller.register(
          name: 'Doni',
          email: 'doni@polban.ac.id',
          password: 'password',
        );

        expect(result, isFalse);
        expect(controller.state, equals(NotifierState.error));
        expect(controller.message, contains('Terjadi kesalahan'));
      },
    );

    test(
      'WB-R-05: statusCode non-201 → state=error, return false',
      () async {
        when(mockDio.post<dynamic>(
          '/register',
          data: anyNamed('data'),
        )).thenAnswer((_) async => Response(
              data: <String, dynamic>{},
              statusCode: 200,
              requestOptions: RequestOptions(path: '/register'),
            ));

        final result = await controller.register(
          name: 'Doni',
          email: 'doni@polban.ac.id',
          password: 'password',
        );

        expect(result, isFalse);
        expect(controller.state, equals(NotifierState.error));
        expect(controller.message, equals('Pendaftaran gagal.'));
      },
    );
  });
}

class _FakeNetworkService extends Fake implements NetworkService {
  final Dio _mockDio;

  _FakeNetworkService(this._mockDio);

  @override
  Dio get dio => _mockDio;

  @override
  void init({required String baseUrl}) {}
}
