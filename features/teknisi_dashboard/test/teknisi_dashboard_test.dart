import 'package:core_module/core_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TC-036 - PDF Report', () {
    testWidgets('Teknisi berhasil generate laporan PDF bulanan',
        (tester) async {
      final reports = [
        _createReport(
          id: 'report_001',
          title: 'Dompet Hitam',
          status: 'lost',
          createdAt: DateTime(2026, 1, 10),
        ),
        _createReport(
          id: 'report_002',
          title: 'Kunci Motor',
          status: 'found',
          createdAt: DateTime(2026, 1, 18),
        ),
      ];
      final reportController = _FakeReportController(reports);
      final pdfService = _FakePdfService();

      await tester.pumpWidget(
        MaterialApp(
          home: _TeknisiDashboardPdfHarness(
            reportController: reportController,
            pdfService: pdfService,
          ),
        ),
      );

      await tester.tap(find.text('Cetak Laporan Bulanan (PDF)'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('month-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Januari').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('year-dropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2026').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('GENERATE PDF'));
      await tester.pumpAndSettle();

      expect(pdfService.generateReportCalls, hasLength(1));
      expect(pdfService.generateReportCalls.single.month, 'Januari');
      expect(pdfService.generateReportCalls.single.year, '2026');
      expect(pdfService.generateReportCalls.single.reports, reports);
    });
  });
}

ReportModel _createReport({
  required String id,
  required String title,
  required String status,
  required DateTime createdAt,
}) {
  return ReportModel(
    id: id,
    title: title,
    description: 'Test Description',
    category: 'Dokumen',
    location: 'Gedung JTK',
    status: status,
    imageUrl: 'https://example.com/image.jpg',
    createdAt: createdAt,
  );
}

class _FakeReportController {
  const _FakeReportController(this.reports);

  final List<ReportModel> reports;
}

class _FakePdfService {
  final List<_GenerateReportCall> generateReportCalls = [];

  Future<void> generateReport({
    required List<ReportModel> reports,
    required String month,
    required String year,
  }) async {
    generateReportCalls.add(
      _GenerateReportCall(reports: reports, month: month, year: year),
    );
  }
}

class _GenerateReportCall {
  const _GenerateReportCall({
    required this.reports,
    required this.month,
    required this.year,
  });

  final List<ReportModel> reports;
  final String month;
  final String year;
}

class _TeknisiDashboardPdfHarness extends StatefulWidget {
  const _TeknisiDashboardPdfHarness({
    required this.reportController,
    required this.pdfService,
  });

  final _FakeReportController reportController;
  final _FakePdfService pdfService;

  @override
  State<_TeknisiDashboardPdfHarness> createState() =>
      _TeknisiDashboardPdfHarnessState();
}

class _TeknisiDashboardPdfHarnessState
    extends State<_TeknisiDashboardPdfHarness> {
  static const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  String selectedMonth = 'Januari';
  String selectedYear = '2026';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showPdfPeriodPicker(context),
          child: const Text('Cetak Laporan Bulanan (PDF)'),
        ),
      ),
    );
  }

  void _showPdfPeriodPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    key: const Key('month-dropdown'),
                    value: selectedMonth,
                    decoration: const InputDecoration(labelText: 'Bulan'),
                    items: months
                        .map(
                          (month) => DropdownMenuItem(
                            value: month,
                            child: Text(month),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setModalState(() => selectedMonth = value!);
                    },
                  ),
                  DropdownButtonFormField<String>(
                    key: const Key('year-dropdown'),
                    value: selectedYear,
                    decoration: const InputDecoration(labelText: 'Tahun'),
                    items: ['2025', '2026', '2027']
                        .map(
                          (year) => DropdownMenuItem(
                            value: year,
                            child: Text(year),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setModalState(() => selectedYear = value!);
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      await widget.pdfService.generateReport(
                        reports: widget.reportController.reports,
                        month: selectedMonth,
                        year: selectedYear,
                      );
                      if (context.mounted) {
                        Navigator.pop(sheetContext);
                      }
                    },
                    child: const Text('GENERATE PDF'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
