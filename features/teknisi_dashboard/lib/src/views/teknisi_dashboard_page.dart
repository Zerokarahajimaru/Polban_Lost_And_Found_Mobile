import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:core_module/core_module.dart';
import 'package:moderation/moderation.dart';
import 'package:provider/provider.dart';

class TeknisiDashboardPage extends StatelessWidget {
  const TeknisiDashboardPage({super.key});

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
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),

            const Text(
              'Kelola barang temuan hari ini',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
              ),
            ),

            const SizedBox(height: 16),

            const _AntreanKlaimBanner(count: 0),

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
                  onTap: () {
                    context.push('/create-report');
                  },
                ),

                _MenuTile(
                  icon: Icons.access_time_outlined,
                  label: 'Inventaris\nBarang',
                  accentColor: AppColors.primaryYellow,
                  onTap: () => _showPlaceholderSnackBar(
                    context,
                    'Inventaris Barang',
                  ),
                ),

                _MenuTile(
                  icon: Icons.warning_amber_outlined,
                  label: 'Moderasi\nLaporan',
                  accentColor: AppColors.primaryYellow,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ModerasiPostinganProvider(),
                    ),
                  ),
                ),

                _MenuTile(
                  icon: Icons.insert_drive_file_outlined,
                  label: 'Statistik\nLaporan',
                  accentColor: AppColors.primaryBlue,
                  onTap: () => _showPlaceholderSnackBar(
                    context,
                    'Statistik Laporan',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Tombol logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Keluar Portal',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Konfirmasi Keluar'),
                      content: const Text(
                          'Apakah Anda yakin ingin keluar dari portal?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Keluar',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    context.read<SessionController>().logout();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlaceholderSnackBar(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name — belum diimplementasikan.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _AntreanKlaimBanner extends StatelessWidget {
  final int count;

  const _AntreanKlaimBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inbox_outlined,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Antrean Klaim',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                Text(
                  '$count menunggu proses',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.chevron_right,
                color: Colors.white, size: 20),
          ),
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

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accentColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: accentColor, size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}