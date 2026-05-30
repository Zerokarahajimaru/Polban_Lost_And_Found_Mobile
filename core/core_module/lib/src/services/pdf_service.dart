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

    // 1. Filter reports for the given month and year
    final filteredReports = reports.where((r) {
      final date = r.createdAt;
      final m = DateFormat('MMMM').format(date);
      final y = date.year.toString();
      return m.toLowerCase() == month.toLowerCase() && y == year;
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
            // HEADER / KOP SURAT
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

            // JUDUL
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

            // RINGKASAN
            pw.Text("Ringkasan Laporan:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Bullet(text: "Total Barang Temuan (Di Lab): $totalFound"),
            pw.Bullet(text: "Total Barang Dikembalikan: $totalResolved"),
            pw.Bullet(text: "Total Laporan Kehilangan: $totalLost"),
            pw.SizedBox(height: 20),

            // TABEL
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

            // TANDA TANGAN
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

    // 2. Open Preview
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
