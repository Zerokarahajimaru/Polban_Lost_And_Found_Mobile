import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:core_module/core_module.dart';
import 'package:moderation/moderation.dart';
import 'package:provider/provider.dart';
import 'package:report/report.dart';
import 'package:claim/claim.dart';

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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const CustomHeader(
        title: 'Beranda',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Halo, $userName!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
            ),
            const Text(
              'Kelola barang temuan hari ini',
              style: TextStyle(fontSize: 13, color: AppColors.textGrey),
            ),
            const SizedBox(height: 16),

            // REACTIVE CLAIM BANNER
            Consumer<ClaimController>(
              builder: (context, claimController, child) {
                final pendingClaims = claimController.claims.where((c) => c.status == 'pending').length;
                return GestureDetector(
                  onTap: () => context.push('/claim-queue'),
                  child: _AntreanKlaimBanner(count: pendingClaims),
                );
              }
            ),

            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
              children: [
                _MenuTile(
                  icon: Icons.add_circle_outline,
                  label: 'Input\nLaporan',
                  accentColor: AppColors.primaryBlue,
                  onTap: () => context.push('/my-reports'),
                ),
                _MenuTile(
                  icon: Icons.access_time_outlined,
                  label: 'Inventaris\nBarang',
                  accentColor: AppColors.primaryYellow,
                  onTap: () => _showPlaceholderSnackBar(context, 'Inventaris Barang'),
                ),
                _MenuTile(
                  icon: Icons.warning_amber_outlined,
                  label: 'Moderasi\nLaporan',
                  accentColor: AppColors.primaryYellow,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ModerasiPostinganProvider())),
                ),
                _MenuTile(
                  icon: Icons.insert_drive_file_outlined,
                  label: 'Statistik\nLaporan',
                  accentColor: AppColors.primaryBlue,
                  onTap: () => _showPlaceholderSnackBar(context, 'Statistik Laporan'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MenuWideTile(
              icon: Icons.picture_as_pdf_outlined,
              label: 'Cetak Laporan Bulanan (PDF)',
              accentColor: AppColors.primaryBlue,
              onTap: () => _showPdfPeriodPicker(context),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Keluar Portal', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: () => _showLogoutConfirmation(context),
              ),
            ),
          ],
        ),
      ),
    );
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Cetak Laporan PDF", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedMonth,
                      items: months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (val) => setModalState(() => selectedMonth = val!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedYear,
                      items: ['2025', '2026', '2027'].map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                      onChanged: (val) => setModalState(() => selectedYear = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  onPressed: () {
                    final reports = context.read<ReportController>().reports;
                    PdfService.generateReport(reports: reports, month: selectedMonth, year: selectedYear);
                    Navigator.pop(ctx);
                  },
                  child: const Text("GENERATE PDF", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.logout_rounded, color: Colors.red, size: 40)),
              const SizedBox(height: 20),
              const Text('Konfirmasi Keluar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              const SizedBox(height: 12),
              const Text('Apakah Anda yakin ingin keluar dari portal teknisi?', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx, false), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), side: const BorderSide(color: AppColors.primaryBlue)), child: const Text('Batal', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)))),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0), child: const Text('Keluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirm == true && context.mounted) context.read<SessionController>().logout();
  }

  void _showPlaceholderSnackBar(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name — belum diimplementasikan.'), behavior: SnackBarBehavior.floating));
  }
}

class _AntreanKlaimBanner extends StatelessWidget {
  final int count;
  const _AntreanKlaimBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.inbox_outlined, color: Colors.white, size: 26)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Antrean Klaim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                Text('$count menunggu proses', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.chevron_right, color: Colors.white, size: 20)),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;
  const _MenuTile({required this.icon, required this.label, required this.accentColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: accentColor, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: accentColor, size: 36),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)),
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
  final VoidCallback onTap;
  const _MenuWideTile({required this.icon, required this.label, required this.accentColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: accentColor, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]),
        child: Row(
          children: [
            Icon(icon, color: accentColor, size: 30),
            const SizedBox(width: 16),
            Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 16, color: accentColor),
          ],
        ),
      ),
    );
  }
}
