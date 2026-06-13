import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:post/src/controllers/report_post_controller.dart';

void main() {
  group('GROUP A — ReportPostController Form State', () {
    late ReportPostController controller;

    setUp(() {
      controller = ReportPostController();
    });

    tearDown(() => controller.dispose());

    test('WB-RP-01: setReason() → selectedReason ter-update dan notifyListeners dipanggil', () {
      expect(controller.selectedReason, isNull);

      controller.setReason(ReportReason.spam);

      expect(controller.selectedReason, equals(ReportReason.spam));
      expect(controller.selectedReason!.displayName, equals('Spam'));
    });

    test('WB-RP-02: setDescription() → description ter-update', () {
      expect(controller.description, isEmpty);

      controller.setDescription('Postingan ini spam dan menipu');

      expect(controller.description, equals('Postingan ini spam dan menipu'));
    });

    test('WB-RP-03: addAttachment() → menambah file ke list attachments hingga batas maks 5', () {
      expect(controller.attachments, isEmpty);

      final file1 = _FakeFile('f1.png');
      final file2 = _FakeFile('f2.png');
      final file3 = _FakeFile('f3.png');
      final file4 = _FakeFile('f4.png');
      final file5 = _FakeFile('f5.png');
      final file6 = _FakeFile('f6.png');

      controller.addAttachment(file1);
      controller.addAttachment(file2);
      controller.addAttachment(file3);
      controller.addAttachment(file4);
      controller.addAttachment(file5);

      expect(controller.attachments.length, equals(5));

      controller.addAttachment(file6);
      expect(controller.attachments.length, equals(5));
      expect(controller.message, equals('Maksimal 5 lampiran'));
    });

    test('WB-RP-04: removeAttachment() → menghapus file dari attachments pada index tertentu', () {
      final file1 = _FakeFile('f1.png');
      final file2 = _FakeFile('f2.png');

      controller.addAttachment(file1);
      controller.addAttachment(file2);
      expect(controller.attachments.length, equals(2));

      controller.removeAttachment(0);
      expect(controller.attachments.length, equals(1));
      expect(controller.attachments.first.path, equals('f2.png'));

      controller.removeAttachment(99);
      expect(controller.attachments.length, equals(1));
    });

    test('WB-RP-05: clearForm() → me-reset semua field form', () {
      controller.setReason(ReportReason.harassment);
      controller.setDescription('Melakukan perundungan verbal');
      controller.addAttachment(_FakeFile('bukti.png'));

      controller.clearForm();

      expect(controller.selectedReason, isNull);
      expect(controller.description, isEmpty);
      expect(controller.attachments, isEmpty);
      expect(controller.message, isEmpty);
    });
  });

  group('GROUP B — ReportPostController.submitReport() & Validation', () {
    late ReportPostController controller;

    setUp(() {
      controller = ReportPostController();
    });

    tearDown(() => controller.dispose());

    test('WB-RP-06: submitReport tanpa memilih alasan → return false, state=error, message="Pilih alasan pelaporan"', () async {
      controller.setDescription('Deskripsi yang cukup panjang');

      final result = await controller.submitReport('post_123', 'usr_999');

      expect(result, isFalse);
      expect(controller.state, equals(ReportPostState.error));
      expect(controller.message, equals('Pilih alasan pelaporan'));
    });

    test('WB-RP-07: submitReport dengan deskripsi kosong → return false, state=error, message="Deskripsi tidak boleh kosong"', () async {
      controller.setReason(ReportReason.copyright);
      controller.setDescription('');

      final result = await controller.submitReport('post_123', 'usr_999');

      expect(result, isFalse);
      expect(controller.state, equals(ReportPostState.error));
      expect(controller.message, equals('Deskripsi tidak boleh kosong'));
    });

    test('WB-RP-08: submitReport dengan deskripsi < 10 karakter → return false, state=error, message="Deskripsi minimal 10 karakter"', () async {
      controller.setReason(ReportReason.copyright);
      controller.setDescription('Singkat');

      final result = await controller.submitReport('post_123', 'usr_999');

      expect(result, isFalse);
      expect(controller.state, equals(ReportPostState.error));
      expect(controller.message, equals('Deskripsi minimal 10 karakter'));
    });

    test('WB-RP-09: submitReport valid → return true, state=loaded, form di-clear', () async {
      controller.setReason(ReportReason.hateSpeech);
      controller.setDescription('Menggunakan kata-kata kasar dan provokatif');
      controller.addAttachment(_FakeFile('ss.png'));

      final result = await controller.submitReport('post_123', 'usr_999');

      expect(result, isTrue);
      expect(controller.state, equals(ReportPostState.loaded));
      expect(controller.message, isEmpty); 

      expect(controller.selectedReason, isNull);
      expect(controller.description, isEmpty);
      expect(controller.attachments, isEmpty);
    });
  });

  group('GROUP C — ReportPostController.getMyReports()', () {
    late ReportPostController controller;

    setUp(() {
      controller = ReportPostController();
    });

    tearDown(() => controller.dispose());

    test('WB-RP-10: getMyReports() → memuat riwayat laporan buatan user', () async {
      expect(controller.myReports, isEmpty);

      await controller.getMyReports('usr_999');

      expect(controller.state, equals(ReportPostState.loaded));
      expect(controller.myReports.length, equals(1));
      expect(controller.myReports.first.reporterUserId, equals('usr_999'));
      expect(controller.myReports.first.reason, equals('Informasi Palsu atau Menyesatkan'));
    });
  });
}

class _FakeFile extends Fake implements File {
  final String _path;
  _FakeFile(this._path);

  @override
  String get path => _path;
}
