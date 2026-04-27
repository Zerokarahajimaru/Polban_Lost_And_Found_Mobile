import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/claim_model.dart';

class ClaimRepository {
  // Ganti URL ini sesuai dengan IP server Dart Frog kamu/Emir
  final String baseUrl = 'http://localhost:8080'; 

  /// Fungsi untuk mengirim pengajuan klaim ke server
  Future<bool> submitClaim(ClaimModel claim) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/claims'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(claim.toPostMap()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true; // Klaim berhasil terkirim
      } else {
        print('Gagal kirim klaim: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error Repository Klaim: $e');
      return false;
    }
  }

  /// Fungsi untuk mengambil daftar klaim (jika nanti dibutuhkan untuk tracking)
  Future<List<ClaimModel>> getClaimsByReportId(String reportId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reports/$reportId/claims'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ClaimModel.fromMap(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}