import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';
import 'package:home/home.dart';
import 'package:claim/claim.dart';

// ========================
// HALAMAN DETAIL LAPORAN
// ========================
class ReportDetailPage extends StatelessWidget {
  final LaporanItem item;

  const ReportDetailPage({super.key, required this.item});

  // Logika: Jika imbalan tidak null, berarti ini postingan orang yang KEHILANGAN barang.
  // Jika imbalan null, berarti ini postingan penemu (Barang TEMUAN).
  bool get isKehilangan => item.imbalan != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto + Tombol Back Overlay
                _buildHeroImage(context),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner Imbalan hanya muncul jika kategori Kehilangan
                      if (isKehilangan) _buildImbalanBanner(),
                      if (isKehilangan) const SizedBox(height: 20),

                      // Nama Barang & Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.nama,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: item.statusColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item.status,
                              style: TextStyle(
                                color: item.statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Deskripsi
                      const Text(
                        "Deskripsi",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.deskripsi,
                        style: const TextStyle(
                            color: AppColors.textGrey, height: 1.5),
                      ),
                      const SizedBox(height: 24),

                      // Info Chips (Kategori, Lokasi, Waktu)
                      _buildInfoGrid(),
                      const SizedBox(height: 32),

                      // --- LOGIKA TOMBOL BERDASARKAN TIPE POSTINGAN ---
                      if (!isKehilangan)
                        _buildKlaimButton(context) // Muncul jika TEMUAN
                      else
                        _buildHubungiButton(context), // Muncul jika KEHILANGAN

                      const SizedBox(height: 100), // Spasi bawah agar tidak tertutup
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(item.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Gradient overlay agar tombol back terlihat jelas
        Container(
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImbalanBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryYellow,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Imbalan bagi Penemu",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue),
              ),
              Text(
                item.imbalan ?? "-",
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Row(
      children: [
        _infoCard("Kategori", item.kategori, Icons.category_outlined),
        const SizedBox(width: 10),
        _infoCard("Lokasi", item.lokasi, Icons.location_on_outlined),
      ],
    );
  }

  Widget _infoCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.secondaryBlue.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppColors.secondaryBlue),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
            Text(value,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  //Tombol untuk Barang Temuan
  Widget _buildKlaimButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        icon: const Icon(Icons.check_circle_outline, color: AppColors.primaryYellow),
        label: const Text(
          "AJUKAN KLAIM",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AjukanKlaimPageProvider(
                reportId: item.nama,
              ),
            ),
          );
        },
      ),
    );
  }

  // Tombol untuk Barang Hilang
  Widget _buildHubungiButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primaryBlue, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        icon: const Icon(Icons.chat_outlined, color: AppColors.primaryBlue),
        label: const Text(
          "HUBUNGI PELAPOR",
          style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        onPressed: () {
          // Tambahkan logika WhatsApp/Chat di sini
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Menghubungi pelapor...")),
          );
        },
      ),
    );
  }
}