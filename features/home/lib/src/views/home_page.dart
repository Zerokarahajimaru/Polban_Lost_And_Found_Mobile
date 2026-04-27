import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';
import 'package:report/report.dart';
import '../models/item_report.dart';

// ========================
// DUMMY DATA
// ========================
const List<LaporanItem> _dummyKehilangan = [
  LaporanItem(
    nama: 'Laptop ASUS ROG G14',
    lokasi: 'Ruang FJBL 1',
    status: 'Sedang Dicari',
    statusColor: Color(0xFFFF6B35),
    badge: 'Imbalan',
    imageUrl:
        'https://images.unsplash.com/photo-1593642632559-0c6d3fc62b89?w=400&h=200&fit=crop',
    imbalan: 'Rp 250.000',
    kategori: 'ELEKTRONIK',
    waktuLapor: '2026-04-01',
    deskripsi: 'Warna hitam, ada stiker SEVENTEEN di belakang',
  ),
  LaporanItem(
    nama: 'Headphone Wireless MH40',
    lokasi: 'Ruang Serbaguna',
    status: 'Sedang Dicari',
    statusColor: Color(0xFFFF6B35),
    imageUrl:
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=200&fit=crop',
    imbalan: 'Rp 100.000',
    kategori: 'ELEKTRONIK',
    waktuLapor: '2026-04-02',
    deskripsi: 'Headphone warna hitam, over-ear, ada foam pad yang sedikit rusak di kiri',
  ),
];

const List<LaporanItem> _dummyTemuan = [
  LaporanItem(
    nama: 'Kabel casan IPhone',
    lokasi: 'Ruang 108',
    status: 'Tersedia',
    statusColor: Color(0xFF2ECC71),
    imageUrl:
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=200&fit=crop',
    kategori: 'ELEKTRONIK',
    waktuLapor: '2026-04-02',
    deskripsi: 'Warna hitam, ada stiker SEVENTEEN di belakang',
  ),
];

// ========================
// HALAMAN UTAMA (HOME)
// ========================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isKehilangan = true;

  List<LaporanItem> get _laporanAktif =>
      _isKehilangan ? _dummyKehilangan : _dummyTemuan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGrey,
      appBar: const CustomHeader(title: 'Beranda Publik'),
      body: Column(
        children: [
          Container(
            color: AppColors.primaryBlue,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: 12),
                _buildTabSelector(),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDataLokalBanner(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: const [
                        Icon(Icons.verified_user_outlined,
                            color: AppColors.primaryBlue, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Laporan Terverifikasi',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: _laporanAktif
                          .map((item) => _buildLaporanCard(item))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: AppColors.primaryYellow,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.primaryBlue, width: 4),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateReportProvider(),
                ),
              );
            },
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
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: CustomBottomNav(
          currentIndex: 0,
          onTap: (index) {
            if (index == 1) {
              // Laporanku
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MyReportsProvider(),
                ),
              );
            }
            // Index 0 (Beranda) - stay pada halaman ini
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Row(
        children: [
          SizedBox(width: 16),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari barang hilang',
                hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Icon(Icons.search, color: AppColors.textGrey, size: 20),
          SizedBox(width: 14),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBlue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _tabButton('Kehilangan', _isKehilangan,
              () => setState(() => _isKehilangan = true)),
          _tabButton('Penemuan', !_isKehilangan,
              () => setState(() => _isKehilangan = false)),
        ],
      ),
    );
  }

  Widget _tabButton(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: active ? Border.all(color: AppColors.primaryBlue) : null,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (active)
                  const Icon(Icons.check,
                      color: AppColors.primaryYellow, size: 14),
                if (active) const SizedBox(width: 6),
                Text(
                  text,
                  style: TextStyle(
                    color: active
                        ? AppColors.primaryYellow
                        : Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataLokalBanner() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryYellow,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.download_rounded,
                  color: AppColors.primaryYellow, size: 24),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DATA LOKAL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.primaryBlue,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '3 laporan menunggu disinkronkan',
                  style: TextStyle(fontSize: 11, color: AppColors.primaryBlue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaporanCard(LaporanItem item) {
    return GestureDetector(
      // NAVIGASI KE DETAIL
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportDetailPage(item: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    item.imageUrl,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: AppColors.softGrey,
                      child: const Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            color: AppColors.textGrey, size: 48),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: item.statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.status,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (item.badge != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.badge!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.textGrey),
                      const SizedBox(width: 4),
                      Text(
                        item.lokasi,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}