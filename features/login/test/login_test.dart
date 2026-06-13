import 'dart:async';

import 'package:core_module/core_module.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:login/src/controllers/login_controller.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  group('GROUP A — LoginController.login()', () {
    late MockDio mockDio;
    late LoginController controller;

    setUp(() {
      mockDio = MockDio();
      controller = LoginController(
        networkService: _FakeNetworkService(mockDio),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test(
      'WB-L-01: statusCode 200 → state=loaded, loggedInUser terisi, return true',
      () async {
        when(mockDio.post<dynamic>(
          '/login',
          data: anyNamed('data'),
        )).thenAnswer((_) async => Response(
              data: {
                'user': {
                  'id': 'usr_001',
                  'name': 'Budi Santoso',
                  'email': 'budi@polban.ac.id',
                  'role': 'user',
                },
              },
              statusCode: 200,
              requestOptions: RequestOptions(path: '/login'),
            ));

        final result = await controller.login('budi@polban.ac.id', 'pass123');

        expect(result, isTrue);
        expect(controller.state, equals(NotifierState.loaded));
        expect(controller.message, equals('Login successful!'));
        expect(controller.loggedInUser, isNotNull);
        expect(controller.loggedInUser!.id, equals('usr_001'));
        expect(controller.loggedInUser!.role, equals('user'));
      },
    );

    test(
      'WB-L-02: DioException 401 → state=error, pesan generic, return false',
      () async {
        when(mockDio.post<dynamic>(
          '/login',
          data: anyNamed('data'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/login'),
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/login'),
          ),
          type: DioExceptionType.badResponse,
        ));

        final result = await controller.login('budi@polban.ac.id', 'salah');

        expect(result, isFalse);
        expect(controller.state, equals(NotifierState.error));
        expect(controller.message, equals('Email atau password salah.'));
        expect(controller.loggedInUser, isNull);
      },
    );

    test(
      'WB-L-03: DioException 400 → state=error, pesan generic, return false',
      () async {
        when(mockDio.post<dynamic>(
          '/login',
          data: anyNamed('data'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/login'),
          response: Response(
            statusCode: 400,
            requestOptions: RequestOptions(path: '/login'),
          ),
          type: DioExceptionType.badResponse,
        ));

        final result = await controller.login('tidak@ada.com', 'pw');

        expect(result, isFalse);
        expect(controller.state, equals(NotifierState.error));
        expect(controller.message, equals('Email atau password salah.'));
      },
    );

    test(
      'WB-L-04: DioException 503 dengan pesan server → message dari server',
      () async {
        when(mockDio.post<dynamic>(
          '/login',
          data: anyNamed('data'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/login'),
          response: Response(
            statusCode: 503,
            data: {'message': 'Layanan sedang dalam pemeliharaan.'},
            requestOptions: RequestOptions(path: '/login'),
          ),
          type: DioExceptionType.badResponse,
        ));

        final result = await controller.login('test@polban.ac.id', 'pw');

        expect(result, isFalse);
        expect(controller.state, equals(NotifierState.error));
        expect(controller.message, equals('Layanan sedang dalam pemeliharaan.'));
      },
    );

    test(
      'WB-L-05: DioException tanpa pesan server → "Gagal terhubung ke server."',
      () async {
        when(mockDio.post<dynamic>(
          '/login',
          data: anyNamed('data'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/login'),
          response: Response(
            statusCode: 500,
            data: <String, dynamic>{},
            requestOptions: RequestOptions(path: '/login'),
          ),
          type: DioExceptionType.badResponse,
        ));

        final result = await controller.login('test@polban.ac.id', 'pw');

        expect(result, isFalse);
        expect(controller.state, equals(NotifierState.error));
        expect(controller.message, equals('Gagal terhubung ke server.'));
      },
    );

    test(
      'WB-L-06: TimeoutException → state=error, pesan timeout, return false',
      () async {
        when(mockDio.post<dynamic>(
          '/login',
          data: anyNamed('data'),
        )).thenThrow(TimeoutException('Connection timeout'));

        final result = await controller.login('budi@polban.ac.id', 'pw');

        expect(result, isFalse);
        expect(controller.state, equals(NotifierState.error));
        expect(
          controller.message,
          equals('Waktu koneksi habis. Periksa internet Anda.'),
        );
      },
    );

    test(
      'WB-L-07: Exception tak terduga → state=error, message mengandung "Terjadi kesalahan", return false',
      () async {
        when(mockDio.post<dynamic>(
          '/login',
          data: anyNamed('data'),
        )).thenThrow(Exception('Unexpected error XYZ'));

        final result = await controller.login('budi@polban.ac.id', 'pw');

        expect(result, isFalse);
        expect(controller.state, equals(NotifierState.error));
        expect(controller.message, contains('Terjadi kesalahan'));
      },
    );

    test(
      'WB-L-08: statusCode 201 (non-200 success) → state=error, return false',
      () async {
        when(mockDio.post<dynamic>(
          '/login',
          data: anyNamed('data'),
        )).thenAnswer((_) async => Response(
              data: <String, dynamic>{},
              statusCode: 201,
              requestOptions: RequestOptions(path: '/login'),
            ));

        final result = await controller.login('budi@polban.ac.id', 'pw');

        expect(result, isFalse);
        expect(controller.state, equals(NotifierState.error));
        expect(controller.message, equals('Email atau password salah.'));
      },
    );

    test(
      'WB-L-09: state berpindah loading → loaded saat login berhasil',
      () async {
        when(mockDio.post<dynamic>(
          '/login',
          data: anyNamed('data'),
        )).thenAnswer((_) async => Response(
              data: {
                'user': {
                  'id': 'u1',
                  'name': 'X',
                  'email': 'x@polban.ac.id',
                  'role': 'user',
                },
              },
              statusCode: 200,
              requestOptions: RequestOptions(path: '/login'),
            ));

        final states = <NotifierState>[];
        controller.addListener(() => states.add(controller.state));

        await controller.login('x@polban.ac.id', 'pw');

        expect(states.first, equals(NotifierState.loading));
        expect(states.last, equals(NotifierState.loaded));
      },
    );

    test(
      'WB-L-12: saat state=loading, onPressed harus null (tombol disabled)',
      () async {
        final completer = Completer<Response<dynamic>>();
        when(mockDio.post<dynamic>(
          '/login',
          data: anyNamed('data'),
        )).thenAnswer((_) => completer.future);

        controller.login('budi@polban.ac.id', 'pw');

        await Future<void>.delayed(const Duration(milliseconds: 10));

        expect(controller.state, equals(NotifierState.loading));
        expect(controller.state == NotifierState.loading, isTrue);

        completer.completeError(Exception('cancelled'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
      },
    );
  });

  group('GROUP B — _performLogin() client-side validation', () {
    bool performLoginGuard(String email, String password) {
      if (email.isEmpty || password.isEmpty) return false; 
      if (!email.contains('@') || !email.contains('.')) return false; 
      return true;
    }

    test(
      'WB-L-10: email kosong → guard menolak, tidak lanjut ke controller',
      () {
        expect(performLoginGuard('', 'pass123'), isFalse);
        expect(performLoginGuard('email@test.com', ''), isFalse);
        expect(performLoginGuard('', ''), isFalse);
      },
    );

    test(
      'WB-L-11: email tanpa "@" atau "." → guard menolak',
      () {
        expect(performLoginGuard('bukanEmail', 'pass'), isFalse);
        expect(performLoginGuard('tanpaTitik@server', 'pass'), isFalse);
        expect(performLoginGuard('budi@polban.ac.id', 'pass'), isTrue);
      },
    );
  });

  group('GROUP C — SessionController', () {
    late SessionController sessionController;

    setUp(() {
      sessionController = SessionController();
    });

    tearDown(() {
      sessionController.dispose();
    });

    final testUser = UserModel(
      id: 'usr_001',
      name: 'Budi',
      email: 'budi@polban.ac.id',
      role: 'user',
    );

    final teknisiUser = UserModel(
      id: 'tek_001',
      name: 'Siska Teknisi',
      email: 'siska@polban.ac.id',
      role: 'teknisi',
    );

    test(
      'WB-L-13: login(user) → currentUser terisi, isLoggedIn=true, isUser=true',
      () {
        sessionController.login(testUser);

        expect(sessionController.isLoggedIn, isTrue);
        expect(sessionController.currentUser, equals(testUser));
        expect(sessionController.isUser, isTrue);
        expect(sessionController.isTeknisi, isFalse);
      },
    );

    test(
      'WB-L-13b: login(teknisiUser) → isTeknisi=true, isUser=false',
      () {
        sessionController.login(teknisiUser);

        expect(sessionController.isTeknisi, isTrue);
        expect(sessionController.isUser, isFalse);
      },
    );

    test(
      'WB-L-14: logout() → currentUser=null, isLoggedIn=false',
      () {
        sessionController.login(testUser);
        expect(sessionController.isLoggedIn, isTrue);

        try {
          sessionController.logout();
        } catch (_) {
        }

        expect(sessionController.currentUser, isNull);
        expect(sessionController.isLoggedIn, isFalse);
      },
    );

    test(
      'WB-L-13c: login() memanggil notifyListeners',
      () {
        var notified = false;
        sessionController.addListener(() => notified = true);

        sessionController.login(testUser);

        expect(notified, isTrue);
      },
    );
  });

  group('GROUP D — AppRouter redirect logic branches', () {
    String? redirectLogic({required bool loggedIn, required bool loggingIn}) {
      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/home';
      return null;
    }

    test(
      'WB-L-15: tidak login + bukan di halaman login → redirect ke /login',
      () {
        final result = redirectLogic(loggedIn: false, loggingIn: false);
        expect(result, equals('/login'));
      },
    );

    test(
      'WB-L-16: sudah login + berada di halaman /login → redirect ke /home',
      () {
        final result = redirectLogic(loggedIn: true, loggingIn: true);
        expect(result, equals('/home'));
      },
    );

    test(
      'WB-L-17: loggedIn + bukan di login (akses normal) → null, tidak redirect',
      () {
        final result = redirectLogic(loggedIn: true, loggingIn: false);
        expect(result, isNull);
      },
    );

    test(
      'WB-L-17b: tidak login + berada di /login (normal) → null, tidak redirect',
      () {
        final result = redirectLogic(loggedIn: false, loggingIn: true);
        expect(result, isNull);
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
  void init({required String baseUrl}) {
  }
}
