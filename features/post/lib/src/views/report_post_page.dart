import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';

// ========================
// HALAMAN LAPORKAN KONTEN (FULL RED BACKGROUND)
// ========================
class ReportPostPageProvider extends StatefulWidget {
  const ReportPostPageProvider({super.key});

  @override
  State<ReportPostPageProvider> createState() => _ReportPostPageProviderState();
}

class _ReportPostPageProviderState extends State<ReportPostPageProvider> {
  String? _selectedAlasan;

  final List<String> _alasanList = [
    'SPAM/IKLAN',
    'Penyampaian palsu (Isi tidak sesuai)',
    'Konten tidak pantas',
    'Sudah ditemukan',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SEKARANG BACKGROUND FULL MERAH
      backgroundColor: const Color(0xFFD32F2F), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // ICON HEADER
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'LAPORKAN KONTEN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilih alasan mengapa konten ini melanggar peraturan kami.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // DAFTAR ALASAN
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Alasan Pelaporan:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ..._alasanList.map((alasan) => _buildAlasanTile(alasan)),
              
              const SizedBox(height: 32),

              // TOMBOL LAPORKAN
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Tombol putih agar kontras dengan background merah
                    foregroundColor: const Color(0xFFD32F2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.flag_rounded, size: 20),
                  label: const Text(
                    'LAPORKAN SEKARANG',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: _selectedAlasan == null
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Laporan berhasil dikirimkan'),
                              backgroundColor: Colors.black87,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          Navigator.pop(context);
                        },
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlasanTile(String alasan) {
    final isSelected = _selectedAlasan == alasan;
    return GestureDetector(
      onTap: () => setState(() => _selectedAlasan = alasan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          // Box transparan putih jika tidak dipilih, putih solid jika dipilih
          color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.1),
          border: Border.all(
            color: Colors.white,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                alasan,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD32F2F) : Colors.white,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? const Color(0xFFD32F2F) : Colors.white70,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}