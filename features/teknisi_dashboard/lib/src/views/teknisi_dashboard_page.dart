import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:core_module/core_module.dart';
import 'package:moderation/moderation.dart';
import 'package:provider/provider.dart';
import 'package:report/report.dart';
import 'package:claim/claim.dart';
import 'package:notification/notification.dart';

class TeknisiDashboardPage extends StatefulWidget {
  const TeknisiDashboardPage({super.key});

  @override
  State<TeknisiDashboardPage> createState() => _TeknisiDashboardPageState();
}

class _TeknisiDashboardPageState extends State<TeknisiDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClaimController>().loadClaims();
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final userName = session.currentUser?.name ?? 'Teknisi';

    return Scaffold(
      backgroundColor: AppColors.softGrey,
      appBar: null,
      body: Stack(
        children: [
          // 1. BACKGROUND LAYER: Scrollable Content
          Positioned.fill(
            child: RefreshIndicator(
              edgeOffset: 120,
              onRefresh: () async {
                await context.read<ClaimController>().loadClaims();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Reduced Header Spacer to fix the large gap
                  const SliverToBoxAdapter(child: SizedBox(height: 85)),
                  
                  SliverPadding(
                    padding: const EdgeInsets.all(AppTheme.kPadding),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 8),
                        Text(
                          'Halo, $userName!',
                          style: const TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold, 
                            color: AppColors.primaryBlue,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Text(
                          'Selamat bertugas! Kelola laporan dan inventaris hari ini.',
                          style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                        ),
                        const SizedBox(height: 24),

                        // REACTIVE CLAIM BANNER (Priority Focus)
                        Consumer<ClaimController>(
                          builder: (context, claimController, child) {
                            final pendingClaims = claimController.claims.where((c) => c.status == 'pending').length;
                            return GestureDetector(
                              onTap: () => context.push('/claim-queue'),
                              child: _AntreanKlaimBanner(count: pendingClaims),
                            );
                          }
                        ),

                        const SizedBox(height: 12),

                        _MenuWideTile(
                          icon: Icons.picture_as_pdf_rounded,
                          label: 'Cetak Laporan Bulanan (PDF)',
                          accentColor: AppColors.primaryBlue,
                          backgroundColor: const Color(0xFFE3F2FD), // Soft Blue
                          onTap: () => _showPdfPeriodPicker(context),
                        ),

                        const SizedBox(height: 28),
                        
                        const Text(
                          'Menu Utama',
                          style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold, 
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),

                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.25,
                          children: [
                            _MenuTile(
                              icon: Icons.add_rounded,
                              label: 'Input Laporan',
                              color: AppColors.primaryBlue,
                              onTap: () => context.push('/my-reports'),
                            ),
                            _MenuTile(
                              icon: Icons.inventory_2_rounded,
                              label: 'Inventaris',
                              color: AppColors.warning,
                              onTap: () => _showPlaceholderSnackBar(context, 'Inventaris Barang'),
                            ),
                            _MenuTile(
                              icon: Icons.gavel_rounded,
                              label: 'Moderasi',
                              color: AppColors.error,
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ModerasiPostinganProvider())),
                            ),
                            _MenuTile(
                              icon: Icons.bar_chart_rounded,
                              label: 'Statistik',
                              color: AppColors.info,
                              onTap: () => _showPlaceholderSnackBar(context, 'Statistik Laporan'),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),

                        // LOGOUT BUTTON
                        _MenuWideTile(
                          icon: Icons.logout_rounded,
                          label: 'Keluar Portal',
                          accentColor: AppColors.error,
                          backgroundColor: AppColors.error.withOpacity(0.05),
                          onTap: () => _showLogoutConfirmation(context),
                        ),

                        const SizedBox(height: 40),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. FOREGROUND LAYER: Fixed Header Only (Stats Card removed)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomHeader(
              title: 'Beranda Staff',
              showBackButton: false,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar Portal', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
        content: const Text('Apakah Anda yakin ingin keluar dari portal teknisi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _handleLogout(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('KELUAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    // 1. Clear Security State
    context.read<ReportController>().clearData();
    context.read<ClaimController>().clearData();
    context.read<NotificationController>().clearData();
    
    // 2. Clear Session
    context.read<SessionController>().logout();
    
    // 3. Redirect
    context.go('/login');
    
    NotificationBanner.show(context, 'Anda telah keluar.');
  }

  void _showPdfPeriodPicker(BuildContext context) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    String selectedMonth = months[DateTime.now().month - 1];
    String selectedYear = DateTime.now().year.toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 20),
              const Text("Cetak Laporan PDF", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              const SizedBox(height: 8),
              const Text("Pilih periode laporan yang ingin diunduh", style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Bulan'),
                      value: selectedMonth,
                      items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (val) => setModalState(() => selectedMonth = val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Tahun'),
                      value: selectedYear,
                      items: ['2025', '2026', '2027'].map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                      onChanged: (val) => setModalState(() => selectedYear = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  final reports = context.read<ReportController>().reports;
                  PdfService.generateReport(reports: reports, month: selectedMonth, year: selectedYear);
                  Navigator.pop(ctx);
                },
                child: const Text("GENERATE PDF"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlaceholderSnackBar(BuildContext context, String name) {
    NotificationBanner.show(context, '$name — Fitur sedang dikembangkan.');
  }
}

class _AntreanKlaimBanner extends StatelessWidget {
  final int count;
  const _AntreanKlaimBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ]
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12), 
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15), 
              borderRadius: BorderRadius.circular(15)
            ), 
            child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 28)
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Antrean Klaim', 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)
                ),
                Text(
                  '$count permintaan verifikasi masuk', 
                  style: const TextStyle(color: Colors.white70, fontSize: 13)
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  
  const _MenuTile({
    required this.icon, 
    required this.label, 
    required this.color, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, 
          borderRadius: BorderRadius.circular(AppTheme.kRadius), 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), 
              blurRadius: 10, 
              offset: const Offset(0, 4)
            )
          ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              label, 
              style: const TextStyle(
                fontSize: 14, 
                fontWeight: FontWeight.w600, 
                color: AppColors.textDark
              )
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuWideTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final Color? backgroundColor;
  final VoidCallback onTap;
  
  const _MenuWideTile({
    required this.icon, 
    required this.label, 
    required this.accentColor, 
    this.backgroundColor,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white, 
          borderRadius: BorderRadius.circular(AppTheme.kRadius), 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), 
              blurRadius: 8, 
              offset: const Offset(0, 3)
            )
          ]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(backgroundColor != null ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              label, 
              style: const TextStyle(
                fontSize: 15, 
                fontWeight: FontWeight.bold, 
                color: AppColors.textDark
              )
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey[backgroundColor != null ? 600 : 400]),
          ],
        ),
      ),
    );
  }
}
