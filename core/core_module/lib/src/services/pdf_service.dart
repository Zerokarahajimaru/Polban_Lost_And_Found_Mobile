import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:core_module/core_module.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateReport({
    required List<ReportModel> reports,
    required String month,
    required String year,
  }) async {
    final pdf = pw.Document();

    final Map<String, int> monthMap = {
      'january': 1, 'januari': 1,
      'february': 2, 'februari': 2,
      'march': 3, 'maret': 3,
      'april': 4,
      'may': 5, 'mei': 5,
      'june': 6, 'juni': 6,
      'july': 7, 'juli': 7,
      'august': 8, 'agustus': 8,
      'september': 9,
      'october': 10, 'oktober': 10,
      'november': 11,
      'december': 12, 'desember': 12,
    };
    final targetMonth = monthMap[month.toLowerCase()];

    final filteredReports = reports.where((r) {
      final date = r.createdAt;
      final matchMonth = targetMonth == null || date.month == targetMonth;
      final y = date.year.toString();
      return matchMonth && y == year;
    }).toList();

    final totalFound = filteredReports.where((r) => r.status.toLowerCase() == 'found').length;
    final totalResolved = filteredReports.where((r) => r.status.toLowerCase() == 'resolved').length;
    final totalLost = filteredReports.where((r) => r.status.toLowerCase() == 'lost').length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Column(
              children: [
                pw.Text("KEMENTERIAN PENDIDIKAN, KEBUDAYAAN,", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Text("RISET, DAN TEKNOLOGI", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Text("POLITEKNIK NEGERI BANDUNG", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text("JURUSAN TEKNIK KOMPUTER DAN INFORMATIKA", style: pw.TextStyle(fontSize: 11)),
                pw.Text("Jalan Gegerkalong Hilir, Ds. Ciwaruga, Bandung", style: pw.TextStyle(fontSize: 9)),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 20),
              ],
            ),

            pw.Center(
              child: pw.Text(
                "BERITA ACARA INVENTARIS BARANG HILANG & TEMUAN",
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, decoration: pw.TextDecoration.underline),
              ),
            ),
            pw.Center(
              child: pw.Text("Periode: $month $year", style: pw.TextStyle(fontSize: 11)),
            ),
            pw.SizedBox(height: 30),

            pw.Text("Ringkasan Laporan:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Bullet(text: "Total Barang Temuan (Di Lab): $totalFound"),
            pw.Bullet(text: "Total Barang Dikembalikan: $totalResolved"),
            pw.Bullet(text: "Total Laporan Kehilangan: $totalLost"),
            pw.SizedBox(height: 20),

            pw.TableHelper.fromTextArray(
              headers: ['No', 'Tanggal', 'Nama Barang', 'Kategori', 'Status', 'Pengambil'],
              data: List<List<dynamic>>.generate(filteredReports.length, (index) {
                final r = filteredReports[index];
                return [
                  index + 1,
                  DateFormat('dd/MM/yyyy').format(r.createdAt),
                  r.title,
                  r.category,
                  r.status.toUpperCase(),
                  r.claimantName ?? '-',
                ];
              }),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.centerLeft,
                4: pw.Alignment.center,
                5: pw.Alignment.centerLeft,
              },
            ),

            pw.SizedBox(height: 50),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  children: [
                    pw.Text("Mengetahui,", style: pw.TextStyle(fontSize: 10)),
                    pw.Text("Kepala Laboratorium", style: pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 50),
                    pw.Text("__________________________", style: pw.TextStyle(fontSize: 10)),
                    pw.Text("NIP. ..........................", style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
                pw.Column(
                  children: [
                    pw.Text("Bandung, ${DateFormat('dd MMMM yyyy').format(DateTime.now())}", style: pw.TextStyle(fontSize: 10)),
                    pw.Text("Teknisi Jaga,", style: pw.TextStyle(fontSize: 10)),
                    pw.SizedBox(height: 50),
                    pw.Text("__________________________", style: pw.TextStyle(fontSize: 10)),
                    pw.Text("NIP. ..........................", style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
