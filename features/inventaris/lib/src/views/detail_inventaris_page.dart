// features/inventaris/lib/src/views/detail_inventaris_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:core_module/core_module.dart';
import '../controllers/inventaris_controller.dart';
import '../models/inventaris_item.dart';

class DetailInventarisPage extends StatelessWidget {
  final InventarisItem item;

  const DetailInventarisPage({super.key, required this.item});

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
                // ---- HERO IMAGE ----
                _buildHeroImage(),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Deskripsi
                      _buildDeskripsi(),
                      const SizedBox(height: 16),

                      // Tanggal Masuk & Keluar
                      _buildTanggalChips(),
                      const SizedBox(height: 24),

                      // Tombol Proses Serah Terima
                      _buildSerahTerimaButton(context),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ---- TOMBOL BACK ----
          _buildTopButtons(context),
        ],
      ),

      // ---- FAB ----
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: AppColors.primaryYellow,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.primaryBlue, width: 4),
            ),
            onPressed: () {},
            child: const Icon(Icons.add, color: AppColors.primaryBlue, size: 35),
          ),
          const SizedBox(height: 4),
          const Text(
            'Lapor',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ---- BOTTOM NAV ----
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: CustomBottomNav(
          currentIndex: 1,
          onTap: (index) {},
        ),
      ),
    );
  }

  // ========================
  // WIDGET: HERO IMAGE
  // ========================
  Widget _buildHeroImage() {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Foto atau placeholder
          item.imageUrl != null
              ? Image.network(
                  item.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imagePlaceholder(),
                )
              : _imagePlaceholder(),

          // Gradient gelap bawah
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),

          // Badge Status
          Positioned(
            bottom: 70,
            left: 20,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: item.status == InventarisStatus.finished
                    ? const Color(0xFF2ECC71)
                    : Colors.grey,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.status == InventarisStatus.finished
                    ? 'Tersedia'
                    : 'Nonaktif',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Nama & Lokasi
          Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nama.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    shadows: [
                      Shadow(
                          color: Colors.black54,
                          blurRadius: 8,
                          offset: Offset(0, 2))
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppColors.primaryYellow, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      item.lokasi,
                      style: const TextStyle(
                        color: AppColors.primaryYellow,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.primaryBlue,
      child: const Center(
        child: Icon(Icons.inventory_2_outlined,
            size: 80, color: AppColors.primaryYellow),
      ),
    );
  }

  // ========================
  // WIDGET: TOMBOL BACK
  // ========================
  Widget _buildTopButtons(BuildContext context) {
    return Positioned(
      top: 48,
      left: 16,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppColors.primaryBlue,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.chevron_left,
              color: AppColors.primaryYellow, size: 24),
        ),
      ),
    );
  }

  // ========================
  // WIDGET: DESKRIPSI
  // ========================
  Widget _buildDeskripsi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deskripsi Lengkap',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.deskripsi,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ========================
  // WIDGET: CHIP TANGGAL
  // ========================
  Widget _buildTanggalChips() {
    return Row(
      children: [
        _tanggalChip('Tanggal Masuk', item.tanggalMasuk),
        const SizedBox(width: 12),
        _tanggalChip('Tanggal Keluar', item.tanggalKeluar),
      ],
    );
  }

  Widget _tanggalChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(
              color: AppColors.secondaryBlue.withValues(alpha: 0.6), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================
  // WIDGET: TOMBOL SERAH TERIMA
  // ========================
  Widget _buildSerahTerimaButton(BuildContext context) {
    return Consumer<InventarisController>(
      builder: (context, controller, _) {
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              disabledBackgroundColor:
                  AppColors.primaryBlue.withValues(alpha: 0.5),
            ),
            icon: controller.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline,
                    color: AppColors.primaryYellow, size: 20),
            label: Text(
              controller.isLoading ? 'Memproses...' : 'PROSES SERAH TERIMA',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 15,
                letterSpacing: 1,
              ),
            ),
            onPressed: controller.isLoading
                ? null
                : () async {
                    await controller.prosesSerahTerima(item.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              controller.lastOperationFailed
                                  ? Icons.error_outline
                                  : Icons.check_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              controller.message,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                        backgroundColor: controller.lastOperationFailed
                            ? Colors.red
                            : AppColors.primaryBlue,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                    controller.clearMessage();
                    if (!controller.lastOperationFailed && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
          ),
        );
      },
    );
  }
}
