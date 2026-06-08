import 'package:core_module/core_module.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:moderation/src/controllers/moderation_controller.dart';
import 'package:moderation/src/models/moderation_report.dart';
import 'package:moderation/src/repositories/moderation_repository.dart';

import 'moderation_test.mocks.dart';

@GenerateMocks([ModerationRepository, Dio])
void main() {
  group('GROUP A — ModerationController.loadReports() (TC-033)', () {
    late MockModerationRepository mockRepo;
    late ModerationController controller;

    final dummyReports = [
      ModerationReport(
        id: 'mod_001',
        postId: 'p_001',
        postTitle: 'Laporan 1',
        reportReason: 'Spam',
        uploaderName: 'Uploader 1',
        reportedAt: DateTime(2025, 6, 1),
        status: ModerationStatus.pending,
        reporters: const [
          ModerationReporter(name: 'Reporter 1', nim: '123', reason: 'Spam')
        ],
      ),
      ModerationReport(
        id: 'mod_002',
        postId: 'p_002',
        postTitle: 'Laporan 2',
        reportReason: 'SARA',
        uploaderName: 'Uploader 2',
        reportedAt: DateTime(2025, 6, 1),
        status: ModerationStatus.ignored,
        reporters: const [
          ModerationReporter(name: 'Reporter 2', nim: '456', reason: 'SARA')
        ],
      ),
    ];

    setUp(() {
      mockRepo = MockModerationRepository();
      controller = ModerationController(repository: mockRepo);
    });

    tearDown(() => controller.dispose());

    test(
      'WB-M-01: fetchReports sukses → reports terisi, pendingReports hanya yang pending, lastOperationFailed=false',
      () async {
        when(mockRepo.fetchReports(status: 'pending'))
            .thenAnswer((_) async => dummyReports.where((r) => r.status == ModerationStatus.pending).toList());

        await controller.loadReports();

        expect(controller.isLoading, isFalse);
        expect(controller.lastOperationFailed, isFalse);
        expect(controller.reports.length, equals(1));
        expect(controller.reports.first.id, equals('mod_001'));
        expect(controller.pendingReports.length, equals(1));
        expect(controller.pendingReports.first.id, equals('mod_001'));
        verify(mockRepo.fetchReports(status: 'pending')).called(1);
      },
    );

    test(
      'WB-M-02: fetchReports error → reports kosong, lastOperationFailed=true, pesan error terisi',
      () async {
        when(mockRepo.fetchReports(status: 'pending'))
            .thenThrow(Exception('Server unreachable'));

        await controller.loadReports();

        expect(controller.isLoading, isFalse);
        expect(controller.lastOperationFailed, isTrue);
        expect(controller.reports, isEmpty);
        expect(controller.message, equals('Gagal memuat laporan moderasi.'));
      },
    );
  });

  group('GROUP B — ModerationController.takedownReport() (TC-034)', () {
    late MockModerationRepository mockRepo;
    late ModerationController controller;

    final initialReports = [
      ModerationReport(
        id: 'mod_001',
        postId: 'p_001',
        postTitle: 'Laporan 1',
        reportReason: 'Spam',
        uploaderName: 'Uploader 1',
        reportedAt: DateTime(2025, 6, 1),
        status: ModerationStatus.pending,
        reporters: const [],
      ),
    ];

    setUp(() {
      mockRepo = MockModerationRepository();
      controller = ModerationController(repository: mockRepo);
    });

    tearDown(() => controller.dispose());

    test(
      'WB-M-03: takedown sukses → report dihapus dari list, message="Postingan berhasil ditakedown."',
      () async {
        when(mockRepo.fetchReports(status: 'pending'))
            .thenAnswer((_) async => List.from(initialReports));
        when(mockRepo.takedown('mod_001')).thenAnswer((_) async {});

        await controller.loadReports();
        expect(controller.reports.length, equals(1));

        await controller.takedownReport('mod_001');

        expect(controller.lastOperationFailed, isFalse);
        expect(controller.reports, isEmpty);
        expect(controller.message, equals('Postingan berhasil ditakedown.'));
        verify(mockRepo.takedown('mod_001')).called(1);
      },
    );

    test(
      'WB-M-04: takedown error → report tidak dihapus dari list, lastOperationFailed=true, pesan error terisi',
      () async {
        when(mockRepo.fetchReports(status: 'pending'))
            .thenAnswer((_) async => List.from(initialReports));
        when(mockRepo.takedown('mod_001')).thenThrow(Exception('Unauthorized action'));

        await controller.loadReports();
        await controller.takedownReport('mod_001');

        expect(controller.lastOperationFailed, isTrue);
        expect(controller.reports.length, equals(1)); 
        expect(controller.message, equals('Gagal melakukan takedown. Coba lagi.'));
      },
    );
  });

  group('GROUP C — ModerationController.ignoreReport()', () {
    late MockModerationRepository mockRepo;
    late ModerationController controller;

    final initialReports = [
      ModerationReport(
        id: 'mod_001',
        postId: 'p_001',
        postTitle: 'Laporan 1',
        reportReason: 'Spam',
        uploaderName: 'Uploader 1',
        reportedAt: DateTime(2025, 6, 1),
        status: ModerationStatus.pending,
        reporters: const [],
      ),
    ];

    setUp(() {
      mockRepo = MockModerationRepository();
      controller = ModerationController(repository: mockRepo);
    });

    tearDown(() => controller.dispose());

    test(
      'WB-M-05: ignore sukses → report dihapus dari list, message="Laporan diabaikan."',
      () async {
        when(mockRepo.fetchReports(status: 'pending'))
            .thenAnswer((_) async => List.from(initialReports));
        when(mockRepo.ignore('mod_001')).thenAnswer((_) async {});

        await controller.loadReports();
        await controller.ignoreReport('mod_001');

        expect(controller.lastOperationFailed, isFalse);
        expect(controller.reports, isEmpty);
        expect(controller.message, equals('Laporan diabaikan.'));
        verify(mockRepo.ignore('mod_001')).called(1);
      },
    );

    test(
      'WB-M-06: ignore error → report tidak dihapus, lastOperationFailed=true, pesan error terisi',
      () async {
        when(mockRepo.fetchReports(status: 'pending'))
            .thenAnswer((_) async => List.from(initialReports));
        when(mockRepo.ignore('mod_001')).thenThrow(Exception('DB error'));

        await controller.loadReports();
        await controller.ignoreReport('mod_001');

        expect(controller.lastOperationFailed, isTrue);
        expect(controller.reports.length, equals(1));
        expect(controller.message, equals('Gagal mengabaikan laporan. Coba lagi.'));
      },
    );
  });

  group('GROUP D — ModerationController.submitReport() (TC-035)', () {
    late MockModerationRepository mockRepo;
    late ModerationController controller;

    setUp(() {
      mockRepo = MockModerationRepository();
      controller = ModerationController(repository: mockRepo);
    });

    tearDown(() => controller.dispose());

    test(
      'WB-M-07: submitReport sukses → message="Laporan berhasil dikirimkan.", lastOperationFailed=false',
      () async {
        when(mockRepo.submitReport(
          postId: anyNamed('postId'),
          postTitle: anyNamed('postTitle'),
          reportReason: anyNamed('reportReason'),
          uploaderName: anyNamed('uploaderName'),
          postImageUrl: anyNamed('postImageUrl'),
          reporterName: anyNamed('reporterName'),
          reporterNim: anyNamed('reporterNim'),
        )).thenAnswer((_) async {});

        await controller.submitReport(
          postId: 'p_100',
          postTitle: 'Barang palsu',
          reportReason: 'Penipuan',
          uploaderName: 'Uploader X',
          reporterName: 'Reporter Y',
          reporterNim: '241511000',
        );

        expect(controller.lastOperationFailed, isFalse);
        expect(controller.message, equals('Laporan berhasil dikirimkan.'));
        verify(mockRepo.submitReport(
          postId: 'p_100',
          postTitle: 'Barang palsu',
          reportReason: 'Penipuan',
          uploaderName: 'Uploader X',
          reporterName: 'Reporter Y',
          reporterNim: '241511000',
          postImageUrl: null,
        )).called(1);
      },
    );

    test(
      'WB-M-08: submitReport DioException "sudah melaporkan" → message="Anda sudah melaporkan postingan ini sebelumnya."',
      () async {
        when(mockRepo.submitReport(
          postId: anyNamed('postId'),
          postTitle: anyNamed('postTitle'),
          reportReason: anyNamed('reportReason'),
          uploaderName: anyNamed('uploaderName'),
          postImageUrl: anyNamed('postImageUrl'),
          reporterName: anyNamed('reporterName'),
          reporterNim: anyNamed('reporterNim'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/moderation'),
          response: Response(
            data: 'User sudah melaporkan postingan ini',
            statusCode: 400,
            requestOptions: RequestOptions(path: '/moderation'),
          ),
          type: DioExceptionType.badResponse,
        ));

        await controller.submitReport(
          postId: 'p_100',
          postTitle: 'Barang palsu',
          reportReason: 'Penipuan',
          uploaderName: 'Uploader X',
          reporterName: 'Reporter Y',
          reporterNim: '241511000',
        );

        expect(controller.lastOperationFailed, isTrue);
        expect(controller.message, equals('Anda sudah melaporkan postingan ini sebelumnya.'));
      },
    );

    test(
      'WB-M-09: submitReport DioException error lain → message berisi format "Gagal: <detail>"',
      () async {
        when(mockRepo.submitReport(
          postId: anyNamed('postId'),
          postTitle: anyNamed('postTitle'),
          reportReason: anyNamed('reportReason'),
          uploaderName: anyNamed('uploaderName'),
          postImageUrl: anyNamed('postImageUrl'),
          reporterName: anyNamed('reporterName'),
          reporterNim: anyNamed('reporterNim'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/moderation'),
          response: Response(
            data: {'message': 'Server overload'},
            statusCode: 500,
            requestOptions: RequestOptions(path: '/moderation'),
          ),
          type: DioExceptionType.badResponse,
        ));

        await controller.submitReport(
          postId: 'p_100',
          postTitle: 'Barang palsu',
          reportReason: 'Penipuan',
          uploaderName: 'Uploader X',
          reporterName: 'Reporter Y',
          reporterNim: '241511000',
        );

        expect(controller.lastOperationFailed, isTrue);
        expect(controller.message, equals('Gagal: Server overload'));
      },
    );

    test(
      'WB-M-10: submitReport generic Exception → message mengandung "Terjadi error: "',
      () async {
        when(mockRepo.submitReport(
          postId: anyNamed('postId'),
          postTitle: anyNamed('postTitle'),
          reportReason: anyNamed('reportReason'),
          uploaderName: anyNamed('uploaderName'),
          postImageUrl: anyNamed('postImageUrl'),
          reporterName: anyNamed('reporterName'),
          reporterNim: anyNamed('reporterNim'),
        )).thenThrow(Exception('Unexpected filesystem lock'));

        await controller.submitReport(
          postId: 'p_100',
          postTitle: 'Barang palsu',
          reportReason: 'Penipuan',
          uploaderName: 'Uploader X',
          reporterName: 'Reporter Y',
          reporterNim: '241511000',
        );

        expect(controller.lastOperationFailed, isTrue);
        expect(controller.message, contains('Terjadi error:'));
      },
    );
  });

  group('GROUP E — ModerationController.checkIfUserReported()', () {
    late MockModerationRepository mockRepo;
    late ModerationController controller;

    final dummyReports = [
      ModerationReport(
        id: 'mod_001',
        postId: 'p_001',
        postTitle: 'Laporan 1',
        reportReason: 'Spam',
        uploaderName: 'Uploader 1',
        reportedAt: DateTime(2025, 6, 1),
        status: ModerationStatus.pending,
        reporters: const [
          ModerationReporter(name: 'Farid', nim: '241511033', reason: 'Spam')
        ],
      ),
    ];

    setUp(() {
      mockRepo = MockModerationRepository();
      controller = ModerationController(repository: mockRepo);
    });

    tearDown(() => controller.dispose());

    test(
      'WB-M-11: checkIfUserReported matching → return true',
      () async {
        when(mockRepo.fetchReports()).thenAnswer((_) async => dummyReports);

        final result = await controller.checkIfUserReported('p_001', '241511033');

        expect(result, isTrue);
      },
    );

    test(
      'WB-M-12: checkIfUserReported mismatch nim / postId → return false',
      () async {
        when(mockRepo.fetchReports()).thenAnswer((_) async => dummyReports);

        final result1 = await controller.checkIfUserReported('p_001', '999999999'); 
        final result2 = await controller.checkIfUserReported('p_002', '241511033'); 

        expect(result1, isFalse);
        expect(result2, isFalse);
      },
    );

    test(
      'WB-M-13: checkIfUserReported repository throws exception → return false gracefully',
      () async {
        when(mockRepo.fetchReports()).thenThrow(Exception('DB error'));

        final result = await controller.checkIfUserReported('p_001', '241511033');

        expect(result, isFalse);
      },
    );
  });
}
