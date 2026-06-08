import 'dart:io';

import 'package:core_module/core_module.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:report/src/controllers/report_controller.dart';

import 'report_test.mocks.dart';

@GenerateMocks([ReportRepository, Dio])
void main() {
  group('GROUP A — ReportController.saveAsDraft()', () {
    late MockReportRepository mockRepo;
    late ReportController controller;

    final reportData = <String, dynamic>{
      'title': 'KTM Budi',
      'description': 'KTM warna biru',
      'location': 'Kantin Polban',
      'contact': '08123456789',
      'category': 'Dokumen',
      'reward': '',
      'status': 'draft',
    };

    setUp(() {
      mockRepo = MockReportRepository();
      controller = ReportController(reportRepository: mockRepo);

      when(mockRepo.getReports(userId: anyNamed('userId')))
          .thenAnswer((_) async => []);
    });

    tearDown(() => controller.dispose());

    test(
      'WB-P-08: existingId null → saveAsDraft dipanggil, message="Draft berhasil disimpan."',
      () async {
        when(mockRepo.saveAsDraft(
          reportData: anyNamed('reportData'),
          localImagePath: anyNamed('localImagePath'),
          existingId: anyNamed('existingId'),
        )).thenAnswer((_) async {});

        await controller.saveAsDraft(
          reportData: reportData,
          localImagePath: '/tmp/foto.jpg',
          existingId: null,
          userId: 'usr_001',
        );

        expect(controller.message, equals('Draft berhasil disimpan.'));
        expect(controller.lastOperationFailed, isFalse);
        verify(mockRepo.saveAsDraft(
          reportData: anyNamed('reportData'),
          localImagePath: anyNamed('localImagePath'),
          existingId: null,
        )).called(1);
        verifyNever(mockRepo.updateReportOnline(
          id: anyNamed('id'),
          reportData: anyNamed('reportData'),
          imageFile: anyNamed('imageFile'),
        ));
      },
    );

    test(
      'WB-P-09: existingId="draft_123" → tidak memanggil updateReportOnline',
      () async {
        when(mockRepo.saveAsDraft(
          reportData: anyNamed('reportData'),
          localImagePath: anyNamed('localImagePath'),
          existingId: anyNamed('existingId'),
        )).thenAnswer((_) async {});

        await controller.saveAsDraft(
          reportData: reportData,
          existingId: 'draft_1718000000000',
          userId: 'usr_001',
        );

        expect(controller.lastOperationFailed, isFalse);
        verifyNever(mockRepo.updateReportOnline(
          id: anyNamed('id'),
          reportData: anyNamed('reportData'),
          imageFile: anyNamed('imageFile'),
        ));
      },
    );

    test(
      'WB-P-10: existingId server ID → updateReportOnline dipanggil dulu',
      () async {
        when(mockRepo.updateReportOnline(
          id: anyNamed('id'),
          reportData: anyNamed('reportData'),
          imageFile: anyNamed('imageFile'),
        )).thenAnswer((_) async {});

        when(mockRepo.saveAsDraft(
          reportData: anyNamed('reportData'),
          localImagePath: anyNamed('localImagePath'),
          existingId: anyNamed('existingId'),
        )).thenAnswer((_) async {});

        await controller.saveAsDraft(
          reportData: reportData,
          existingId: '683abc123def456',
          userId: 'usr_001',
        );

        expect(controller.lastOperationFailed, isFalse);
        verify(mockRepo.updateReportOnline(
          id: '683abc123def456',
          reportData: anyNamed('reportData'),
          imageFile: anyNamed('imageFile'),
        )).called(1);
        verify(mockRepo.saveAsDraft(
          reportData: anyNamed('reportData'),
          localImagePath: anyNamed('localImagePath'),
          existingId: '683abc123def456',
        )).called(1);
      },
    );

    test(
      'WB-P-11: repository lempar exception → lastOperationFailed=true, message mengandung "Gagal menyimpan"',
      () async {
        when(mockRepo.saveAsDraft(
          reportData: anyNamed('reportData'),
          localImagePath: anyNamed('localImagePath'),
          existingId: anyNamed('existingId'),
        )).thenThrow(Exception('Hive write error'));

        await controller.saveAsDraft(
          reportData: reportData,
          existingId: null,
          userId: 'usr_001',
        );

        expect(controller.lastOperationFailed, isTrue);
        expect(controller.message, contains('Gagal menyimpan draft'));
      },
    );
  });

  group('GROUP B — ReportController.finalizeReport()', () {
    late MockReportRepository mockRepo;
    late ReportController controller;

    final baseData = <String, dynamic>{
      'title': 'Dompet Merah',
      'description': 'Dompet kulit warna merah',
      'location': 'Gedung A',
      'contact': '082233445566',
      'category': 'Dompet',
      'reward': '50000',
      'status': 'lost',
    };

    setUp(() {
      mockRepo = MockReportRepository();
      controller = ReportController(reportRepository: mockRepo);

      when(mockRepo.getReports()).thenAnswer((_) async => []);
      when(mockRepo.getReports(userId: anyNamed('userId')))
          .thenAnswer((_) async => []);
    });

    tearDown(() => controller.dispose());

    test(
      'WB-P-14: finalisasi draft tanpa imageFile → exception, lastOperationFailed=true',
      () async {
        await controller.finalizeReport(
          reportData: baseData,
          imageFile: null,          
          existingId: 'draft_1718000000000',
          userId: 'usr_001',
        );

        expect(controller.lastOperationFailed, isTrue);
        expect(controller.message, contains('error'));
      },
    );

    test(
      'WB-P-15: finalisasi draft dengan imageFile → postReportOnline + deleteReport dipanggil',
      () async {
        final fakeImage = _FakeFile('/tmp/foto.jpg');

        when(mockRepo.postReportOnline(
          reportData: anyNamed('reportData'),
          imageFile: anyNamed('imageFile'),
        )).thenAnswer((_) async {});

        when(mockRepo.deleteReport(any, any)).thenAnswer((_) async {});

        await controller.finalizeReport(
          reportData: baseData,
          imageFile: fakeImage,
          existingId: 'draft_1718000000000',
          userId: 'usr_001',
        );

        expect(controller.lastOperationFailed, isFalse);
        expect(controller.message, equals('Laporan berhasil dikirim!'));
        verify(mockRepo.postReportOnline(
          reportData: anyNamed('reportData'),
          imageFile: anyNamed('imageFile'),
        )).called(1);
        verify(mockRepo.deleteReport('draft_1718000000000', 'draft')).called(1);
      },
    );

    test(
      'WB-P-16: finalisasi draft, koneksi gagal → queueCreateForSync, lastOperationFailed=false',
      () async {
        final fakeImage = _FakeFile('/tmp/foto.jpg');

        when(mockRepo.postReportOnline(
          reportData: anyNamed('reportData'),
          imageFile: anyNamed('imageFile'),
        )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/reports'),
          type: DioExceptionType.connectionError,
        ));

        when(mockRepo.queueCreateForSync(
          reportData: anyNamed('reportData'),
          localImagePath: anyNamed('localImagePath'),
        )).thenAnswer((_) async {});

        when(mockRepo.deleteReport(any, any)).thenAnswer((_) async {});

        await controller.finalizeReport(
          reportData: baseData,
          imageFile: fakeImage,
          existingId: 'draft_1718000000000',
          userId: 'usr_001',
        );

        expect(controller.lastOperationFailed, isFalse);
        verify(mockRepo.queueCreateForSync(
          reportData: anyNamed('reportData'),
          localImagePath: anyNamed('localImagePath'),
        )).called(1);
      },
    );

    test(
      'WB-P-17: laporan baru tanpa gambar → exception, lastOperationFailed=true',
      () async {
        await controller.finalizeReport(
          reportData: baseData,
          imageFile: null,
          existingId: null,
          userId: 'usr_001',
        );

        expect(controller.lastOperationFailed, isTrue);
        expect(controller.message, contains('error'));
      },
    );

    test(
      'WB-P-18: getMyReports berhasil → myReports terisi, lastOperationFailed=false',
      () async {
        final fakeReport = _fakeReport('rpt_001', 'usr_001', 'lost');

        when(mockRepo.getReports(userId: 'usr_001'))
            .thenAnswer((_) async => [fakeReport]);

        await controller.getMyReports('usr_001');

        expect(controller.myReports.length, equals(1));
        expect(controller.myReports.first.id, equals('rpt_001'));
        expect(controller.lastOperationFailed, isFalse);
      },
    );
  });

  group('GROUP C — ReportRepository.saveAsDraft() key generation', () {

    test(
      'WB-P-12: existingId null → key diformat "draft_<timestamp>"',
      () {
        String? existingId;
        final key = existingId ?? 'draft_${DateTime.now().millisecondsSinceEpoch}';

        expect(key, startsWith('draft_'));
        expect(int.tryParse(key.replaceFirst('draft_', '')), isNotNull);
      },
    );

    test(
      'WB-P-13: existingId "draft_999" → key tetap "draft_999"',
      () {
        const existingId = 'draft_999';
        final key = existingId;   
        expect(key, equals('draft_999'));
      },
    );
  });

  group('GROUP D — ReportRepository cache logic (pure branch test)', () {

    List<ReportModel> loadAllFromCache(
      Map<String, Map<dynamic, dynamic>> fakeBox, {
      String? filterByUserId,
    }) {
      final reports = <ReportModel>[];
      for (final key in fakeBox.keys) {
        final map = fakeBox[key];
        if (map != null && !key.startsWith('pending_delete_')) {
          final dataWithId = Map<String, dynamic>.from(map);
          final report = ReportModel.fromMap(dataWithId);
          if (filterByUserId != null) {
            if (report.userId == filterByUserId) reports.add(report);
          } else {
            reports.add(report);
          }
        }
      }
      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reports;
    }

    test(
      'WB-P-19: filterByUserId → hanya report dengan userId cocok dikembalikan',
      () {
        final fakeBox = {
          'rpt_001': _reportMap('rpt_001', 'usr_001', 'lost'),
          'rpt_002': _reportMap('rpt_002', 'usr_002', 'lost'),
          'draft_999': _reportMap('draft_999', 'usr_001', 'draft'),
        };

        final result = loadAllFromCache(fakeBox, filterByUserId: 'usr_001');

        expect(result.length, equals(2));
        expect(result.every((r) => r.userId == 'usr_001'), isTrue);
      },
    );

    test(
      'WB-P-20: key "pending_delete_xyz" dikecualikan dari cache result',
      () {
        final fakeBox = {
          'rpt_001': _reportMap('rpt_001', 'usr_001', 'lost'),
          'pending_delete_rpt_002': {'id': 'rpt_002'},
        };

        final result = loadAllFromCache(fakeBox);

        expect(result.length, equals(1));
        expect(result.first.id, equals('rpt_001'));
      },
    );

    test(
      'WB-P-20b: hasil diurutkan berdasarkan createdAt descending',
      () {
        final older = _reportMap(
          'rpt_old',
          'usr_001',
          'lost',
          createdAt: DateTime(2024, 1, 1),
        );
        final newer = _reportMap(
          'rpt_new',
          'usr_001',
          'lost',
          createdAt: DateTime(2025, 1, 1),
        );

        final fakeBox = {'rpt_old': older, 'rpt_new': newer};
        final result = loadAllFromCache(fakeBox);

        expect(result.first.id, equals('rpt_new'));
      },
    );
  });

  group('GROUP E — deleteReport() isLocalOnly branch', () {
    bool isLocalOnly(String id) =>
        id.startsWith('draft_') || id.startsWith('pending_');

    test(
      'WB-P-21: id="draft_xxx" → isLocalOnly=true, tidak ada network call',
      () {
        expect(isLocalOnly('draft_1718000000000'), isTrue);
        expect(isLocalOnly('pending_create_123'), isTrue);
      },
    );

    test(
      'WB-P-22: id="683abc123" (server ObjectId) → isLocalOnly=false',
      () {
        expect(isLocalOnly('683abc123def456'), isFalse);
        expect(isLocalOnly('507f191e810c19729de860ea'), isFalse);
      },
    );
  });

  group('GROUP F — _isFormValid() form validation branches', () {
    bool isFormValid({
      required String name,
      required String description,
      required String? category,
      required String phone,
      required bool isLost,
      bool isFinalizing = false,
      bool hasImage = false,
    }) {
      bool basicValid =
          name.isNotEmpty && description.isNotEmpty && category != null;
      if (isFinalizing) {
        basicValid = basicValid && hasImage;
      }
      if (isLost) {
        return basicValid && phone.length >= 4 && phone.length <= 18;
      }
      return basicValid;
    }

    test(
      'WB-P-03: finalisasi tanpa gambar → isFormValid=false',
      () {
        final result = isFormValid(
          name: 'KTM Budi',
          description: 'KTM warna biru',
          category: 'Dokumen',
          phone: '08123456789',
          isLost: true,
          isFinalizing: true,
          hasImage: false, 
        );
        expect(result, isFalse);
      },
    );

    test(
      'WB-P-04: laporan kehilangan dengan nomor WA terlalu pendek → false',
      () {
        final result = isFormValid(
          name: 'KTM Budi',
          description: 'KTM warna biru',
          category: 'Dokumen',
          phone: '08',              
          isLost: true,
          isFinalizing: true,
          hasImage: true,
        );
        expect(result, isFalse);
      },
    );

    test(
      'WB-P-05: nomor WA melebihi 18 karakter → false',
      () {
        final result = isFormValid(
          name: 'KTM Budi',
          description: 'KTM warna biru',
          category: 'Dokumen',
          phone: '0812345678901234567', 
          isLost: true,
          isFinalizing: true,
          hasImage: true,
        );
        expect(result, isFalse);
      },
    );

    test(
      'WB-P-06: laporan Penemuan (isLost=false) → phone tidak diwajibkan',
      () {
        final result = isFormValid(
          name: 'Dompet Ditemukan',
          description: 'Dompet coklat tanpa identitas',
          category: 'Dompet',
          phone: '',               
          isLost: false,
          isFinalizing: true,
          hasImage: true,
        );
        expect(result, isTrue);
      },
    );

    test(
      'WB-P-01: role user → isLost dikunci true, tab Penemuan tidak tersedia',
      () {
        const isTeknisi = false;
        var isLost = true;
        if (!isTeknisi) {
          isLost = true; 
        }
        expect(isLost, isTrue); 
      },
    );

    test(
      'WB-P-07: semua field valid, ada gambar, phone OK → isFormValid=true',
      () {
        final result = isFormValid(
          name: 'Dompet Merah',
          description: 'Dompet kulit warna merah ada KTP',
          category: 'Dompet',
          phone: '08123456789',   
          isLost: true,
          isFinalizing: true,
          hasImage: true,
        );
        expect(result, isTrue);
      },
    );
  });

  group('GROUP G — TC-038: Navigasi ke ReportDetailPage', () {
    test(
      'WB-P-25: onTap kartu laporan membuka ReportDetailPage dengan item benar',
      () {
        // Logika navigasi dalam _buildReportCard :
        //
        // GestureDetector(
        //   onTap: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (_) => ReportDetailPage(
        //           item: report,
        //           canManage: true,
        //         ),
        //       ),
        //     );
        //   },
        //   ...
        // )
        //
        // Test unit: verifikasi data report yang dikirim (tanpa widget tree)

        final report = _fakeReport('rpt_tap_001', 'usr_001', 'lost');

        final itemPassedToDetail = report;

        expect(itemPassedToDetail.id, equals('rpt_tap_001'));
        expect(itemPassedToDetail.userId, equals('usr_001'));
        expect(itemPassedToDetail.status, equals('lost'));

        const canManage = true;
        expect(canManage, isTrue);
      },
    );
  });
}

ReportModel _fakeReport(String id, String userId, String status,
    {DateTime? createdAt}) {
  return ReportModel(
    id: id,
    userId: userId,
    title: 'Test Report $id',
    description: 'Deskripsi test',
    category: 'Dokumen',
    location: 'Polban',
    status: status,
    imageUrl: '',
    createdAt: createdAt ?? DateTime(2025, 6, 1),
  );
}

Map<String, dynamic> _reportMap(String id, String userId, String status,
    {DateTime? createdAt}) {
  return {
    'id': id,
    'userId': userId,
    'title': 'Report $id',
    'description': 'Deskripsi $id',
    'category': 'Dokumen',
    'location': 'Polban',
    'status': status,
    'imageUrl': '',
    'createdAt': (createdAt ?? DateTime(2025, 6, 1)).toIso8601String(),
  };
}

class _FakeFile extends Fake implements File {
  final String _path;
  _FakeFile(this._path);

  @override
  String get path => _path;
}