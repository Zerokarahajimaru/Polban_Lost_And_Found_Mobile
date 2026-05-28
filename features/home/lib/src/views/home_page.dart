import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';
import 'package:provider/provider.dart';
import 'package:report/report.dart';
import 'package:go_router/go_router.dart';
import '../controllers/home_controller.dart';

// ========================
// HALAMAN UTAMA (HOME) - PROVIDER WRAPPER
// ========================
class HomePageProvider extends StatelessWidget {
  const HomePageProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeController()),
        // ReportController sudah disediakan di root (main.dart)
      ],
      child: const HomePage(),
    );
  }
}

// ========================
// HALAMAN UTAMA (HOME)
// ========================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Memuat laporan saat pertama kali halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportController>().getReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeController, ReportController>(
      builder: (context, homeController, reportController, child) {
        // Gunakan data dari ReportController
        final allReports = reportController.reports;
        final filteredReports = homeController.filterReports(allReports);
        final unsyncedCount = homeController.getUnsyncedCount(allReports);

        return Scaffold(
          backgroundColor: AppColors.softGrey,
          appBar: CustomHeader(
            title: 'Beranda Publik',
            onNotificationTap: () => context.push('/notifications'),
          ),
          body: Column(
            children: [
              Container(
                color: AppColors.primaryBlue,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    _buildSearchBar(context, homeController),
                    const SizedBox(height: 12),
                    _buildTabSelector(homeController),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await context.read<ReportController>().getReports();
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _buildDataLokalBanner(context, unsyncedCount),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
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
                      ),
                      if (reportController.isLoading && allReports.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        )
                      else if (reportController.lastOperationFailed && allReports.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                'Gagal memuat laporan: ${reportController.message}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        )
                      else if (filteredReports.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.search_off_rounded,
                                      size: 64,
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  const Text(
                                    "Tidak Ada Laporan",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    "Coba cari dengan kata kunci lain atau tarik ke bawah untuk memuat ulang.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.75, // Adjust this to balance image vs text area
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = filteredReports[index];
                                return _buildLaporanCard(context, item);
                              },
                              childCount: filteredReports.length,
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 24),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // FAB dan BottomNav sekarang dikelola oleh MainScaffold
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context, HomeController controller) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              onChanged: (value) => context.read<HomeController>().updateSearchQuery(value),
              decoration: const InputDecoration(
                hintText: 'Cari barang hilang',
                hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const Icon(Icons.search, color: AppColors.textGrey, size: 20),
          const SizedBox(width: 14),
        ],
      ),
    );
  }

  Widget _buildTabSelector(HomeController controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBlue.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _tabButton('Kehilangan', controller.activeTab == HomeTab.kehilangan,
              () => controller.setActiveTab(HomeTab.kehilangan)),
          _tabButton('Penemuan', controller.activeTab == HomeTab.penemuan,
              () => controller.setActiveTab(HomeTab.penemuan)),
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
                        : Colors.white.withValues(alpha: 0.7),
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

  Widget _buildDataLokalBanner(BuildContext context, int unsyncedCount) {
    return GestureDetector(
      onTap: () => context.go('/my-reports'),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DATA LOKAL',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.primaryBlue,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$unsyncedCount laporan menunggu disinkronkan',
                  style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLaporanCard(BuildContext context, dynamic item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailPage(item: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(15)),
                    child: Container(
                      width: double.infinity,
                      color: AppColors.softGrey,
                      child: Stack(
                        children: [
                          // Blurred Background
                          Positioned.fill(
                            child: Image.network(
                              item.imageUrl ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox(),
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.1),
                            ),
                          ),
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(color: Colors.transparent),
                            ),
                          ),
                          // Main Image
                          Center(
                            child: Image.network(
                              item.imageUrl ?? '',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.image_not_supported_outlined,
                                    color: AppColors.textGrey, size: 32),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.status ?? 'Pending',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title ?? 'No Title',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: AppColors.textGrey),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          item.location ?? 'Unknown location',
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textGrey),
                          overflow: TextOverflow.ellipsis,
                        ),
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
