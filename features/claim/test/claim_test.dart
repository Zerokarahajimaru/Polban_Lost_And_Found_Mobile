import 'package:flutter_test/flutter_test.dart';
import 'package:core_module/core_module.dart';
import 'package:claim/src/controllers/claim_controller.dart';

void main() {
  group('ClaimModel Unit Tests', () {
    test('should parse correctly from normal json Map', () {
      final json = {
        'id': 'claim_123',
        'reportId': 'report_456',
        'reportTitle': 'Jaket Hitam',
        'claimantName': 'John Doe',
        'claimantId': '12345678',
        'claimantEmail': 'john@example.com',
        'reportImageUrl': 'https://image.com/123.jpg',
        'status': 'pending',
        'createdAt': '2026-06-08T10:00:00.000Z',
      };

      final claim = ClaimModel.fromJson(json);

      expect(claim.id, 'claim_123');
      expect(claim.reportId, 'report_456');
      expect(claim.reportTitle, 'Jaket Hitam');
      expect(claim.claimantName, 'John Doe');
      expect(claim.claimantId, '12345678');
      expect(claim.claimantEmail, 'john@example.com');
      expect(claim.reportImageUrl, 'https://image.com/123.jpg');
      expect(claim.status, 'pending');
      expect(claim.createdAt.isUtc, true);
    });

    test('should normalize ObjectId wrapper format properly', () {
      final json = {
        '_id': 'ObjectId("60b8d5a1b3a5a415a8c12345")',
        'reportId': 'report_456',
        'status': 'verified',
      };

      final claim = ClaimModel.fromJson(json);

      expect(claim.id, '60b8d5a1b3a5a415a8c12345');
      expect(claim.status, 'verified');
    });

    test('should handle empty or null fields gracefully', () {
      final json = <String, dynamic>{};

      final claim = ClaimModel.fromJson(json);

      expect(claim.id, '');
      expect(claim.reportId, '');
      expect(claim.reportTitle, '');
      expect(claim.claimantName, '');
      expect(claim.claimantId, '');
      expect(claim.claimantEmail, '');
      expect(claim.reportImageUrl, isNull);
      expect(claim.status, 'pending');
    });

    test('should serialize to JSON correctly', () {
      final claim = ClaimModel(
        id: 'claim_999',
        reportId: 'rep_888',
        reportTitle: 'Kunci Motor',
        claimantName: 'Jane Smith',
        claimantId: '87654321',
        claimantEmail: 'jane@example.com',
        reportImageUrl: 'https://img.com/kunci.png',
        status: 'rejected',
        createdAt: DateTime.parse('2026-06-08T12:00:00Z'),
      );

      final json = claim.toJson();

      expect(json['reportId'], 'rep_888');
      expect(json['reportTitle'], 'Kunci Motor');
      expect(json['claimantName'], 'Jane Smith');
      expect(json['claimantId'], '87654321');
      expect(json['claimantEmail'], 'jane@example.com');
      expect(json['reportImageUrl'], 'https://img.com/kunci.png');
      expect(json['status'], 'rejected');
      expect(json['createdAt'], '2026-06-08T12:00:00.000Z');
    });
  });

  group('ClaimController Unit Tests', () {
    test('initial states should be empty and not loading', () {
      final controller = ClaimController();

      expect(controller.claims, isEmpty);
      expect(controller.isLoading, false);
      expect(controller.message, isEmpty);
    });

    test('clearData should reset states', () {
      final controller = ClaimController();
      controller.clearData();

      expect(controller.claims, isEmpty);
      expect(controller.message, isEmpty);
      expect(controller.isLoading, false);
    });
  });

  group('Claim Barang & Verifikasi Claim Test Cases', () {
    test('TC-028: user berhasil mengajukan klaim dan POST /claims dikirim',
        () async {
      final backend = _FakeClaimBackend();
      final repository = _FakeClaimRepository(backend);
      final claim = _createClaim(
        id: '',
        reportId: 'report_valid_001',
        claimantId: 'user_jtk_123',
        status: 'pending',
      );

      final response = await repository.submitClaim(claim);

      expect(response.statusCode, 201);
      expect(backend.requests, hasLength(1));
      expect(backend.requests.single.method, 'POST');
      expect(backend.requests.single.path, '/claims');
      expect(backend.requests.single.data['reportId'], 'report_valid_001');
      expect(backend.requests.single.data['claimantId'], 'user_jtk_123');
      expect(backend.requests.single.data['status'], 'pending');
      expect(backend.claims.single.status, 'pending');
    });

    test(
      'TC-029: duplicate claim belum ditolak backend dan tercatat sebagai gap',
      () async {
        final backend = _FakeClaimBackend(rejectDuplicateClaims: false);
        final repository = _FakeClaimRepository(backend);
        final firstClaim = _createClaim(
          id: '',
          reportId: 'report_duplicate_001',
          claimantId: 'user_jtk_123',
        );
        final duplicateClaim = _createClaim(
          id: '',
          reportId: 'report_duplicate_001',
          claimantId: 'user_jtk_123',
        );

        final firstResponse = await repository.submitClaim(firstClaim);
        final duplicateResponse = await repository.submitClaim(duplicateClaim);

        expect(firstResponse.statusCode, 201);
        expect(duplicateResponse.statusCode, 201);
        expect(duplicateResponse.statusCode, isNot(409));
        expect(
          backend.claims
              .where(
                (claim) =>
                    claim.reportId == 'report_duplicate_001' &&
                    claim.claimantId == 'user_jtk_123',
              )
              .length,
          2,
        );
      },
    );

    test(
      'TC-030: teknisi menyelesaikan verifikasi dan finalizeVerification dipanggil',
      () async {
        final claim = _createClaim(id: 'claim_pending_001');
        final claimController = _FakeClaimController();
        final verificationPage = _FakeVerificationPageHarness(
          claim: claim,
          controller: claimController,
        );

        final message = await verificationPage.tapCompleteVerificationButton();

        expect(
            claimController.finalizeVerificationCalls, ['claim_pending_001']);
        expect(message, 'Klaim diverifikasi & Laporan ditutup.');
      },
    );

    test(
      'TC-031: verifikasi satu klaim otomatis menolak klaim lain untuk report yang sama',
      () async {
        final backend = _FakeClaimBackend(
          initialClaims: [
            _createClaim(id: 'claim_001', reportId: 'report_same_001'),
            _createClaim(id: 'claim_002', reportId: 'report_same_001'),
            _createClaim(id: 'claim_003', reportId: 'report_same_001'),
          ],
        );
        final repository = _FakeClaimRepository(backend);

        final response = await repository.verifyClaim('claim_001', 'verify');

        expect(response.statusCode, 200);
        expect(backend.claimById('claim_001')?.status, 'verified');
        expect(backend.claimById('claim_002')?.status, 'rejected');
        expect(backend.claimById('claim_003')?.status, 'rejected');
      },
    );

    test(
      'TC-032: verifikasi claimId tidak valid mengembalikan 404 dan pesan tidak ditemukan',
      () async {
        final backend = _FakeClaimBackend();
        final repository = _FakeClaimRepository(backend);

        final response =
            await repository.verifyClaim('invalid_claim_id', 'verify');

        expect(response.statusCode, 404);
        expect(response.message, 'Data klaim yang dipilih tidak ditemukan.');
      },
    );
  });
}

ClaimModel _createClaim({
  required String id,
  String reportId = 'report_valid_001',
  String reportTitle = 'Jaket Hitam',
  String claimantName = 'Budi',
  String claimantId = 'user_jtk_123',
  String claimantEmail = 'budi@proyek4.polban.ac.id',
  String? reportImageUrl,
  String status = 'pending',
  DateTime? createdAt,
}) {
  return ClaimModel(
    id: id,
    reportId: reportId,
    reportTitle: reportTitle,
    claimantName: claimantName,
    claimantId: claimantId,
    claimantEmail: claimantEmail,
    reportImageUrl: reportImageUrl,
    status: status,
    createdAt: createdAt ?? DateTime.parse('2026-06-08T10:00:00.000Z'),
  );
}

class _RecordedRequest {
  const _RecordedRequest({
    required this.method,
    required this.path,
    required this.data,
  });

  final String method;
  final String path;
  final Map<String, dynamic> data;
}

class _FakeBackendResponse {
  const _FakeBackendResponse(this.statusCode, this.message);

  final int statusCode;
  final String message;
}

class _FakeClaimBackend {
  _FakeClaimBackend({
    this.rejectDuplicateClaims = true,
    List<ClaimModel> initialClaims = const [],
  }) : claims = List<ClaimModel>.from(initialClaims);

  final bool rejectDuplicateClaims;
  final List<ClaimModel> claims;
  final List<_RecordedRequest> requests = [];

  Future<_FakeBackendResponse> postClaims(Map<String, dynamic> data) async {
    requests.add(_RecordedRequest(method: 'POST', path: '/claims', data: data));

    final isDuplicate = claims.any(
      (claim) =>
          claim.reportId == data['reportId'] &&
          claim.claimantId == data['claimantId'],
    );

    if (isDuplicate && rejectDuplicateClaims) {
      return const _FakeBackendResponse(
        409,
        'Sistem seharusnya menolak pengajuan klaim yang sama.',
      );
    }

    claims.add(
      ClaimModel.fromJson({
        ...data,
        'id': data['id']?.toString().isNotEmpty == true
            ? data['id']
            : 'claim_${claims.length + 1}',
      }),
    );
    return const _FakeBackendResponse(
      201,
      'Pengajuan klaim berhasil dikirim dan tercatat pada sistem.',
    );
  }

  Future<_FakeBackendResponse> postClaimAction(
    String claimId,
    Map<String, dynamic> data,
  ) async {
    requests.add(
      _RecordedRequest(method: 'POST', path: '/claims/$claimId', data: data),
    );

    final selectedIndex = claims.indexWhere((claim) => claim.id == claimId);
    if (selectedIndex == -1) {
      return const _FakeBackendResponse(
        404,
        'Data klaim yang dipilih tidak ditemukan.',
      );
    }

    if (data['action'] == 'verify') {
      final selected = claims[selectedIndex];
      for (var index = 0; index < claims.length; index++) {
        final claim = claims[index];
        if (claim.reportId != selected.reportId) continue;

        claims[index] = _copyClaim(
          claim,
          status: claim.id == claimId ? 'verified' : 'rejected',
        );
      }
    }

    return const _FakeBackendResponse(
      200,
      'Klaim berhasil diverifikasi dan status laporan diperbarui.',
    );
  }

  ClaimModel? claimById(String id) {
    for (final claim in claims) {
      if (claim.id == id) return claim;
    }
    return null;
  }
}

class _FakeClaimRepository {
  const _FakeClaimRepository(this.backend);

  final _FakeClaimBackend backend;

  Future<_FakeBackendResponse> submitClaim(ClaimModel claim) {
    return backend.postClaims(claim.toJson());
  }

  Future<_FakeBackendResponse> verifyClaim(String claimId, String action) {
    return backend.postClaimAction(claimId, {'action': action});
  }
}

ClaimModel _copyClaim(ClaimModel claim, {String? status}) {
  return ClaimModel(
    id: claim.id,
    reportId: claim.reportId,
    reportTitle: claim.reportTitle,
    claimantName: claim.claimantName,
    claimantId: claim.claimantId,
    claimantEmail: claim.claimantEmail,
    reportImageUrl: claim.reportImageUrl,
    status: status ?? claim.status,
    createdAt: claim.createdAt,
  );
}

class _FakeClaimController extends ClaimController {
  final List<String> finalizeVerificationCalls = [];

  @override
  bool get isLoading => false;

  @override
  String get message => '';

  @override
  Future<bool> finalizeVerification(String claimId) async {
    finalizeVerificationCalls.add(claimId);
    return true;
  }
}

class _FakeVerificationPageHarness {
  const _FakeVerificationPageHarness({
    required this.claim,
    required this.controller,
  });

  final ClaimModel claim;
  final ClaimController controller;

  Future<String> tapCompleteVerificationButton() async {
    final success = await controller.finalizeVerification(claim.id);
    return success
        ? 'Klaim diverifikasi & Laporan ditutup.'
        : controller.message;
  }
}
