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
      ],
      child: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportController>().getReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeController, ReportController>(
      builder: (context, homeController, reportController, child) {
        final allReports = reportController.reports;
        final filteredReports = homeController.filterReports(allReports);
        final unsyncedCount = homeController.getUnsyncedCount(allReports);

        return Scaffold(
          backgroundColor: AppColors.softGrey,
          appBar: null,
          body: Stack(
            children: [
              // 1. SCROLLABLE CONTENT (Layer Paling Bawah)
              Positioned.fill(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await context.read<ReportController>().getReports();
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Spacer agar konten tidak tertutup header + tab melayang
                      // (Tinggi Header ~116 + 60 Extra + 22 Setengah Tab = ~200)
                      const SliverToBoxAdapter(child: SizedBox(height: 200)),
                      
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
                          child: Center(child: CircularProgressIndicator()),
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
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = filteredReports[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildLaporanCard(context, item),
                                );
                              },
                              childCount: filteredReports.length,
                            ),
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                ),
              ),

              // 2. HEADER & FLOATING TAB (Layer Atas, membayangi konten saat scroll)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    CustomHeader(
                      title: 'Beranda Publik',
                      showBackButton: false,
                      onNotificationTap: () => context.push('/notifications'),
                      extraHeight: 60,
                      bottomChild: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: _buildSearchBar(context, homeController),
                      ),
                    ),
                    Positioned(
                      bottom: -22, 
                      left: 60,
                      right: 60,
                      child: _buildTabSelector(homeController),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context, HomeController controller) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => context.read<HomeController>().updateSearchQuery(value),
              decoration: const InputDecoration(
                hintText: 'Cari barang hilang',
                hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const Icon(Icons.search, color: Colors.black, size: 24),
        ],
      ),
    );
  }

  Widget _buildTabSelector(HomeController controller) {
    return Container(
      height: 44, // Reduced height for a sleeker look
      decoration: BoxDecoration(
        color: const Color(0xFFE6F0FF),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
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
          decoration: BoxDecoration(
            color: active ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active ? AppColors.primaryYellow : const Color(0xFF90AEE0),
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                fontSize: 13, // Slightly reduced font size to fit compact design
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataLokalBanner(BuildContext context, int unsyncedCount) {
    if (unsyncedCount == 0) return const SizedBox.shrink();
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
    final status = item.status?.toString().toLowerCase() ?? 'lost';
    final isLost = status == 'lost';
    final statusText = isLost ? 'Sedang Dicari' : 'Baru Ditemukan';
    final imageUrl = item.imageUrl ?? '';

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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    color: AppColors.softGrey,
                    child: Stack(
                      children: [
                        if (imageUrl.isNotEmpty)
                          Positioned.fill(
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        Positioned.fill(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(color: Colors.black.withOpacity(0.1)),
                          ),
                        ),
                        Center(
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_not_supported_outlined,
                                color: AppColors.textGrey, size: 48),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB3D7FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Color(0xFF002299),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title ?? 'No Title',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF002299),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.reward != null && item.reward!.toString().isNotEmpty && item.reward != '-')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE100),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF002299), width: 1),
                          ),
                          child: const Text(
                            'Imbalan',
                            style: TextStyle(
                              color: Color(0xFF002299),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 18, color: Color(0xFF3399FF)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.location ?? 'Unknown location',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF3399FF),
                            fontWeight: FontWeight.w600,
                          ),
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
