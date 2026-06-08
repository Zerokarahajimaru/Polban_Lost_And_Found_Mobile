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
}
