import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';
import 'package:provider/provider.dart';
import 'package:report/report.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:timeago/timeago.dart' as timeago_lib;
import '../controllers/home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  String _headerTitle = 'Beranda Publik';

  @override
  void initState() {
    super.initState();
    // Initialize timeago Indonesian
    timeago_lib.setLocaleMessages('id', timeago_lib.IdMessages());
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportController>().getReports();
      context.read<HomeController>().loadHiddenPosts(); 
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    double offset = _scrollController.offset;
    if (offset > 50) {
      if (_headerTitle != 'Cari Barangmu...') {
        setState(() {
          _headerTitle = 'Cari Barangmu...';
        });
      }
    } else {
      if (_headerTitle != 'Beranda Publik') {
        setState(() {
          _headerTitle = 'Beranda Publik';
        });
      }
    }
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
              // 1. BACKGROUND LAYER: Scrollable Content
              Positioned.fill(
                child: RefreshIndicator(
                  edgeOffset: 170,
                  displacement: 40,
                  onRefresh: () async {
                    await context.read<ReportController>().getReports();
                  },
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Header Spacer
                      const SliverToBoxAdapter(child: SizedBox(height: 180)),
                      
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
                                'Laporan Terbaru',
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
                          child: _buildEmptyState(),
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

              // 2. FOREGROUND LAYER: Fixed Header + Floating Tab
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CustomHeader(
                      title: _headerTitle,
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

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.kPaddingLarge * 1.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.kPaddingLarge),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 100,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppTheme.kPadding),
            Text(
              "Tidak Ada Laporan",
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: AppTheme.kPaddingSmall),
            Text(
              "Coba cari dengan kata kunci lain atau tarik ke bawah untuk memuat ulang.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, HomeController controller) {
    final theme = Theme.of(context);
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.kRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.kPadding),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) => controller.updateSearchQuery(value),
              decoration: InputDecoration(
                hintText: 'Cari barang hilang...',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textGrey),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const Icon(Icons.search_rounded, color: AppColors.primaryBlue, size: 24),
        ],
      ),
    );
  }

  Widget _buildTabSelector(HomeController controller) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white, // Fully opaque for better contrast and no scroll artifacts
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
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
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque, 
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: active ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              text,
              style: theme.textTheme.labelSmall?.copyWith(
                color: active ? AppColors.primaryYellow : AppColors.primaryBlue.withOpacity(0.6),
                fontWeight: active ? FontWeight.bold : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataLokalBanner(BuildContext context, int unsyncedCount) {
    if (unsyncedCount == 0) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.go('/my-reports'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppTheme.kPadding, 
          AppTheme.kPadding, 
          AppTheme.kPadding, 
          AppTheme.kPaddingSmall
        ),
        padding: const EdgeInsets.all(AppTheme.kPadding),
        decoration: BoxDecoration(
          color: AppColors.primaryYellow,
          borderRadius: BorderRadius.circular(AppTheme.kRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(AppTheme.kRadius - 4),
              ),
              child: const Icon(Icons.sync_problem_rounded,
                  color: AppColors.primaryYellow, size: 24),
            ),
            const SizedBox(width: AppTheme.kPadding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DRAFT & PENDING',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '$unsyncedCount item belum terkirim',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildLaporanCard(BuildContext context, dynamic item) {
    final theme = Theme.of(context);
    final status = item.status?.toString().toLowerCase() ?? 'lost';
    final isLost = status == 'lost';
    final statusText = isLost ? 'Sedang Dicari' : 'Baru Ditemukan';
    final imageUrl = item.imageUrl ?? '';
    
    final DateTime createdAt = item.createdAt is DateTime ? item.createdAt : DateTime.now();
    final String relativeTime = timeago_lib.format(createdAt, locale: 'id');

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
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.kRadius)),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    color: AppColors.softGrey,
                    child: Center(
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: AppColors.textGrey, size: 48),
                            )
                          : const Icon(Icons.image_not_supported_outlined,
                              color: AppColors.textGrey, size: 48),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      relativeTime,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.kPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title ?? 'No Title',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppColors.primaryBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.reward != null && item.reward!.toString().isNotEmpty && item.reward != '-')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryYellow,
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
