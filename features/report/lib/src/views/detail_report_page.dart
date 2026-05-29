import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';
import 'package:provider/provider.dart';
import 'package:claim/claim.dart';
import 'package:post/post.dart';

// ========================
// HALAMAN DETAIL LAPORAN
// ========================
class ReportDetailPage extends StatelessWidget {
  final dynamic item;

  const ReportDetailPage({super.key, required this.item});

  bool get isReportModel => item is ReportModel;

  String get nama => isReportModel ? item.title : item.nama;
  String get lokasi => isReportModel ? item.location : item.lokasi;
  String get status => isReportModel ? item.status : item.status;
  
  // Normalize status to lowercase for comparison
  String get normalizedStatus => status.toLowerCase();
  bool get isFound => normalizedStatus == 'found';
  bool get isLost => normalizedStatus == 'lost';

  Color get statusColor {
    if (!isReportModel) return item.statusColor;
    return isFound ? AppColors.primaryYellow : AppColors.primaryBlue;
  }

  String get imageUrl => isReportModel ? item.imageUrl : item.imageUrl;
  String? get localImagePath => isReportModel ? item.localImagePath : null;
  String? get imbalan => isReportModel ? item.reward : item.imbalan;
  String get kategori => isReportModel ? item.category : item.kategori;
  String get waktuLapor {
    if (!isReportModel) return item.waktuLapor;
    final createdAt = item.createdAt as DateTime;
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get deskripsi => isReportModel ? item.description : item.deskripsi;
  String get id => isReportModel ? item.id : item.nama;

  // Reward section visibility
  bool get showRewardBanner => imbalan != null && imbalan!.isNotEmpty && imbalan != '-';

  ImageProvider<Object>? get imageProvider {
    if (isReportModel) {
      if (localImagePath != null && localImagePath!.isNotEmpty) {
        return FileImage(File(localImagePath!));
      }
      if (imageUrl.isNotEmpty) {
        return NetworkImage(imageUrl);
      }
      return null;
    }
    return imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null;
  }

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
                      // Banner Imbalan hanya muncul jika ada imbalan
                      if (showRewardBanner) _buildImbalanBanner(),
                      if (showRewardBanner) const SizedBox(height: 20),

                      // Nama Barang & Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              nama,
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
                              color: statusColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
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
                        deskripsi,
                        style: const TextStyle(
                            color: AppColors.textGrey, height: 1.5),
                      ),
                      const SizedBox(height: 24),

                      // Info Chips (Kategori, Lokasi, Waktu)
                      _buildInfoGrid(),
                      const SizedBox(height: 32),

                      // --- LOGIKA TOMBOL ---
                      if (isFound) ...[
                        _buildKlaimButton(context), // Claim on top for Found items
                        const SizedBox(height: 16),
                        _buildHubungiButton(context), // Followed by Contact button
                        const SizedBox(height: 16),
                      ] else if (isLost) ...[
                        _buildHubungiButton(context), // Just Contact for Lost items
                        const SizedBox(height: 16),
                      ],
                      
                      // Tombol Report dengan tanda seru merah (always at bottom of action group)
                      _buildReportButton(context),

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
    final provider = imageProvider;
    return Stack(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          color: AppColors.softGrey,
          child: provider != null
              ? Stack(
                  children: [
                    // Blurred background
                    Positioned.fill(
                      child: Image(
                        image: provider,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(color: Colors.black.withValues(alpha: 0.2)),
                      ),
                    ),
                    // Main image (100% visible)
                    Center(
                      child: Image(
                        image: provider,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: Icon(Icons.image_not_supported_outlined,
                      color: AppColors.textGrey, size: 48),
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
                imbalan ?? "-",
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
        _infoCard("Kategori", kategori, Icons.category_outlined),
        const SizedBox(width: 10),
        _infoCard("Lokasi", lokasi, Icons.location_on_outlined),
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
    final session = context.watch<SessionController>();
    final user = session.currentUser;

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
        onPressed: () async {
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Harap login untuk melakukan klaim."))
            );
            return;
          }

          final claimRepo = ClaimRepository();
          final claim = ClaimModel(
            id: '', // Will be generated by server
            reportId: id,
            reportTitle: nama,
            claimantName: user.name,
            claimantId: user.id,
            claimantEmail: user.email,
            reportImageUrl: imageUrl,
            status: 'pending',
            createdAt: DateTime.now(),
          );

          try {
            await claimRepo.submitClaim(claim);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Klaim berhasil diajukan! Pantau antrean."),
                  backgroundColor: Colors.green,
                )
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Gagal mengajukan klaim: $e"),
                  backgroundColor: Colors.red,
                )
              );
            }
          }
        },
      ),
    );
  }

  // Tombol Hubungi Pelapor
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

  // Tombol Report dengan tanda seru merah
  Widget _buildReportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        icon: const Icon(Icons.warning_outlined, color: Colors.red),
        label: const Text(
          "LAPORKAN POSTINGAN",
          style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportPostPageProvider(item: item),
            ),
          );
        },
      ),
    );
  }
}
