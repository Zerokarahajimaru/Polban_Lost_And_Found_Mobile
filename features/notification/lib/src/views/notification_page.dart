import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';

// ========================
// MODEL NOTIFIKASI
// ========================
class NotifikasiItem {
  final String judul;
  final String pesan;
  final String waktu;
  final bool isRead;

  const NotifikasiItem({
    required this.judul,
    required this.pesan,
    required this.waktu,
    this.isRead = false,
  });
}

// ========================
// DUMMY DATA
// ========================
const List<NotifikasiItem> _dummyNotifikasi = [
  NotifikasiItem(
    judul: 'Laporan Diterima!',
    pesan: 'Barang yang anda cari sedang diiklankan sebelum dikonfirmasi.',
    waktu: 'Baru saja',
    isRead: false,
  ),
];

// ========================
// HALAMAN NOTIFIKASI (KOTAK MASUK)
// ========================
class NotifikasiPage extends StatelessWidget {
  const NotifikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGrey,

      // ---- APP BAR ----
      appBar: const CustomHeader(title: 'Kotak Masuk'),

      body: _dummyNotifikasi.isEmpty
          ? _buildEmpty()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _dummyNotifikasi.length,
              itemBuilder: (context, index) {
                return _buildNotifCard(_dummyNotifikasi[index]);
              },
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
          currentIndex: 0,
          onTap: (index) {},
        ),
      ),
    );
  }

  // ========================
  // WIDGET: KARTU NOTIFIKASI
  // ========================
  Widget _buildNotifCard(NotifikasiItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryYellow,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Shield
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: AppColors.primaryYellow,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.judul,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    Text(
                      item.waktu,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.pesan,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryBlue,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Dot unread
          if (!item.isRead)
            Container(
              margin: const EdgeInsets.only(left: 8, top: 2),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  // ========================
  // WIDGET: EMPTY STATE
  // ========================
  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined,
              size: 64, color: AppColors.textGrey),
          SizedBox(height: 12),
          Text(
            'Belum ada notifikasi',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
