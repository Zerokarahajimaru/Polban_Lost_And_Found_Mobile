import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';
import 'package:provider/provider.dart';
import 'package:claim/claim.dart';
import 'package:post/post.dart';
import '../controllers/report_controller.dart';

// ========================
// HALAMAN DETAIL LAPORAN
// ========================
class ReportDetailPage extends StatelessWidget {
  final dynamic item;
  final bool canManage;
  final bool isFromUserClaim; // Flag for "Klaim Saya" view

  const ReportDetailPage({
    super.key, 
    required this.item,
    this.canManage = false,
    this.isFromUserClaim = false,
  });

  bool get isReportModel => item is ReportModel;
  bool get isClaimModel => item is ClaimModel;

  String get nama => isReportModel ? item.title : (isClaimModel ? item.reportTitle : item.nama);
  String get lokasi => isReportModel ? item.location : (isClaimModel ? "Lihat di Beranda" : item.lokasi);
  String get status => isReportModel ? item.status : (isClaimModel ? item.status : item.status);
  
  // Normalize status to lowercase for comparison
  String get normalizedStatus => status.toLowerCase();
  bool get isFound => normalizedStatus == 'found';
  bool get isLost => normalizedStatus == 'lost';
  bool get isResolved => normalizedStatus == 'resolved';
  bool get isVerified => normalizedStatus == 'verified'; // Specifically for ClaimModel
  bool get isRejected => normalizedStatus == 'rejected'; // Specifically for ClaimModel
  bool get isSynced => isReportModel && !item.id.startsWith('draft_') && !item.id.startsWith('pending_');

  Color get statusColor {
    if (isResolved || isVerified) return Colors.green;
    if (isRejected) return Colors.red;
    if (isReportModel) return isFound ? AppColors.primaryYellow : AppColors.primaryBlue;
    if (isClaimModel) return Colors.orange;
    return Colors.grey;
  }

  String get imageUrl => isReportModel ? item.imageUrl : (isClaimModel ? (item.reportImageUrl ?? '') : item.imageUrl);
  String? get localImagePath => isReportModel ? item.localImagePath : null;
  String? get imbalan => isReportModel ? item.reward : null;
  String get kategori => isReportModel ? item.category : "Barang Temuan";
  String get waktuLapor {
    if (isReportModel || isClaimModel) {
      final createdAt = item.createdAt as DateTime;
      return TimeHelper.formatRelative(createdAt);
    }
    return "";
  }

  String get deskripsi => isReportModel ? item.description : (isClaimModel ? "Detail klaim yang sedang diajukan." : item.deskripsi);
  String get id => isReportModel ? item.id : (isClaimModel ? item.id : item.nama);
  String? get userId => isReportModel ? item.userId : (isClaimModel ? item.claimantId : null);

  // Reward section visibility
  bool get showRewardBanner => imbalan != null && imbalan!.isNotEmpty && imbalan != '-';

  ImageProvider<Object>? get imageProvider {
    if (isReportModel) {
      if (localImagePath != null && localImagePath!.isNotEmpty) return FileImage(File(localImagePath!));
      if (imageUrl.isNotEmpty) return NetworkImage(imageUrl);
    }
    if (isClaimModel && imageUrl.isNotEmpty) return NetworkImage(imageUrl);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final claimController = context.watch<ClaimController>();
    final currentUser = session.currentUser;
    final isOwner = userId != null && currentUser != null && userId == currentUser.id;
    final isTeknisi = session.isTeknisi;

    // Check if current user already claimed this item (only if not already in claim management)
    final hasAlreadyClaimed = !isFromUserClaim && claimController.claims.any((c) => c.reportId == id && c.claimantId == currentUser?.id);

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
                      // [19] PROGRESS STEPPER
                      if (isFromUserClaim) ...[
                        // Stepper for Claimant
                        ClaimProgressStepper(status: status),
                        const SizedBox(height: 24),
                      ] else if (canManage) ...[
                        // Stepper for Report Owner (My Reports)
                        ReportProgressStepper(status: status, isLost: isLost),
                        const SizedBox(height: 24),
                      ],

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
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              isVerified ? "VERIFIED" : (isRejected ? "REJECTED" : (isResolved ? (isLost ? "KETEMU" : "DIAMBIL") : status.toUpperCase())),
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Deskripsi
                      const Text("Deskripsi", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                      const SizedBox(height: 8),
                      Text(deskripsi, style: const TextStyle(color: AppColors.textGrey, height: 1.5)),
                      const SizedBox(height: 24),

                      // Info Chips (Kategori, Lokasi, Waktu)
                      _buildInfoGrid(),
                      const SizedBox(height: 32),

                      // --- LOGIKA TOMBOL ---
                      if (isFromUserClaim) ...[
                        if (isVerified) ...[
                          const Center(
                            child: Text(
                              "Klaim ini telah diverifikasi. Silakan ambil barang di tempat yang ditentukan.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ] else if (isRejected) ...[
                          const Center(
                            child: Text(
                              "Klaim ditolak. Barang kemungkinan besar telah diserahkan kepada pemilik yang sah.",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ] else ...[
                          _buildCancelClaimButton(context),
                        ],
                        const SizedBox(height: 16),
                      ] else ...[
                        if (!isResolved) ...[
                           // Only show Claim button for Found items that belong to someone else
                          if (isFound && !isOwner) ...[
                            _buildKlaimButton(context, hasAlreadyClaimed),
                            const SizedBox(height: 16),
                          ],

                          // Only show Resolve button if opened from "Management" (My Reports) and is Synced
                          if (canManage && isSynced) ...[
                            if (isFound && isTeknisi) ...[
                              _buildResolvedButton(context, "TANDAI SUDAH DIAMBIL"),
                              const SizedBox(height: 16),
                            ] else if (isLost && isOwner) ...[
                              _buildResolvedButton(context, "BARANG SUDAH KETEMU"),
                              const SizedBox(height: 16),
                            ],
                          ],

                          // Show interaction buttons ONLY if NOT the owner
                          if (!isOwner) ...[
                            _buildHubungiButton(context),
                            const SizedBox(height: 16),
                            _buildReportButton(context),
                          ] else ...[
                             const Center(child: Text("Ini adalah postingan Anda.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))),
                          ],
                        ] else ...[
                          const Center(child: Text("Postingan ini telah diselesaikan.", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                        ],
                      ],

                      const SizedBox(height: 100), 
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
                    Positioned.fill(child: Image(image: provider, fit: BoxFit.cover)),
                    Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), child: Container(color: Colors.black.withOpacity(0.2)))),
                    // Main image (100% visible)
                    Center(child: Image(image: provider, fit: BoxFit.contain)),
                  ],
                )
              : const Center(child: Icon(Icons.image_not_supported_outlined, color: AppColors.textGrey, size: 48)),
        ),
        // Gradient overlay
        Container(
          height: 100,
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.5), Colors.transparent])),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: CircleAvatar(backgroundColor: Colors.white, child: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue), onPressed: () => Navigator.pop(context))),
          ),
        ),
      ],
    );
  }

  Widget _buildImbalanBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.primaryYellow, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Imbalan bagi Penemu", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              Text(imbalan ?? "-", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryBlue)),
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
        _infoCard("Waktu", waktuLapor, Icons.access_time_outlined),
      ],
    );
  }

  Widget _infoCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: AppColors.secondaryBlue.withOpacity(0.5)), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppColors.secondaryBlue),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  //Tombol untuk Barang Temuan
  Widget _buildKlaimButton(BuildContext context, bool hasAlreadyClaimed) {
    final session = context.watch<SessionController>();
    final user = session.currentUser;

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: hasAlreadyClaimed ? Colors.grey : AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
        icon: Icon(Icons.check_circle_outline, color: hasAlreadyClaimed ? Colors.white70 : AppColors.primaryYellow),
        label: Text(hasAlreadyClaimed ? "KLAIM SEDANG DIPROSES" : "AJUKAN KLAIM", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        onPressed: hasAlreadyClaimed ? null : () async {
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Harap login untuk melakukan klaim.")));
            return;
          }

          final claimRepo = ClaimRepository();
          final claim = ClaimModel(id: '', reportId: id, reportTitle: nama, claimantName: user.name, claimantId: user.id, claimantEmail: user.email, reportImageUrl: imageUrl, status: 'pending', createdAt: DateTime.now());

          try {
            await claimRepo.submitClaim(claim);
            if (context.mounted) {
              context.read<ClaimController>().loadClaims(); // Refresh claims
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Klaim berhasil diajukan! Pantau di menu Klaim Saya."), backgroundColor: Colors.green));
            }
          } catch (e) {
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal mengajukan klaim: $e"), backgroundColor: Colors.red));
          }
        },
      ),
    );
  }

  Widget _buildCancelClaimButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
        icon: const Icon(Icons.cancel_outlined, color: Colors.red),
        label: const Text("BATALKAN KLAIM", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Batalkan Klaim?"),
              content: const Text("Apakah Anda yakin ingin membatalkan pengajuan klaim ini?"),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Tidak")),
                TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Ya, Batalkan", style: TextStyle(color: Colors.red))),
              ],
            ),
          );

          if (confirm == true && context.mounted) {
            final claimRepo = ClaimRepository();
            try {
              await claimRepo.deleteClaim(id); // Using the claim ID
              if (context.mounted) {
                context.read<ClaimController>().loadClaims();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Klaim berhasil dibatalkan.")));
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
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
        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primaryBlue, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
        icon: const Icon(Icons.chat_outlined, color: AppColors.primaryBlue),
        label: const Text("HUBUNGI PELAPOR", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16)),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menghubungi pelapor...")));
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
        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
        icon: const Icon(Icons.warning_outlined, color: Colors.red),
        label: const Text("LAPORKAN POSTINGAN", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ReportPostPageProvider(item: item)));
        },
      ),
    );
  }

  Widget _buildResolvedButton(BuildContext context, String label) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
        icon: const Icon(Icons.done_all, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        onPressed: () => _showResolveDialog(context),
      ),
    );
  }

  void _showResolveDialog(BuildContext context) {
    final nameController = TextEditingController();
    final idController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Selesaikan Laporan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Masukkan data pengambil barang."),
            const SizedBox(height: 16),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nama Pengambil")),
            TextField(controller: idController, decoration: const InputDecoration(labelText: "NIM Pengambil")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              final reportRepo = ReportRepository();
              try {
                await reportRepo.updateReportStatus(
                  id: id, 
                  status: 'resolved', 
                  claimantName: nameController.text, 
                  claimantId: idController.text
                );
                if (context.mounted) {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                  context.read<ReportController>().getReports();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Laporan berhasil diselesaikan."), backgroundColor: Colors.green));
                }
              } catch (e) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("Selesaikan"),
          ),
        ],
      ),
    );
  }
}
