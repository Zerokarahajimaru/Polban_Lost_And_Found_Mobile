import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:core_module/core_module.dart';
import 'package:provider/provider.dart';
import 'package:claim/claim.dart';
import 'package:post/post.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:moderation/moderation.dart';
import '../controllers/report_controller.dart';
import '../widgets/detail_hero_image.dart';
import '../widgets/detail_info_widgets.dart';

// ========================
// HALAMAN DETAIL LAPORAN
// ========================
class ReportDetailPage extends StatefulWidget {
  final dynamic item;
  final bool canManage;
  final bool isFromUserClaim; 

  const ReportDetailPage({
    super.key, 
    required this.item,
    this.canManage = false,
    this.isFromUserClaim = false,
  });

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  bool _hasAlreadyReported = false;
  bool _isCheckingReport = true;

  @override
  void initState() {
    super.initState();
    _checkReportStatus();
  }

  Future<void> _checkReportStatus() async {
    final session = context.read<SessionController>();
    final user = session.currentUser;
    if (user == null) {
      setState(() => _isCheckingReport = false);
      return;
    }

    try {
      final String postId = widget.item is ReportModel ? widget.item.id : (widget.item is ClaimModel ? widget.item.reportId : widget.item.id);
      
      // Use controller instead of direct repository instantiation
      final controller = ModerationController();
      final reported = await controller.checkIfUserReported(postId, user.id);
      
      if (mounted) {
        setState(() {
          _hasAlreadyReported = reported;
          _isCheckingReport = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isCheckingReport = false);
    }
  }

  bool get isReportModel => widget.item is ReportModel;
  bool get isClaimModel => widget.item is ClaimModel;

  String get nama => isReportModel ? widget.item.title : (isClaimModel ? widget.item.reportTitle : widget.item.nama);
  String get lokasi => isReportModel ? widget.item.location : (isClaimModel ? "Lihat di Beranda" : widget.item.lokasi);
  String get status => isReportModel ? widget.item.status : (isClaimModel ? widget.item.status : widget.item.status);
  
  String get normalizedStatus => status.toLowerCase();
  bool get isFound => normalizedStatus == 'found';
  bool get isLost => normalizedStatus == 'lost';
  bool get isResolved => normalizedStatus == 'resolved';
  bool get isVerified => normalizedStatus == 'verified'; 
  bool get isRejected => normalizedStatus == 'rejected'; 
  bool get isSynced => isReportModel && !widget.item.id.startsWith('draft_') && !widget.item.id.startsWith('pending_');

  Color get statusColor {
    if (isResolved || isVerified) return AppColors.success;
    if (isRejected) return AppColors.error;
    if (isReportModel) return isFound ? AppColors.primaryYellow : AppColors.primaryBlue;
    if (isClaimModel) return AppColors.warning;
    return AppColors.textGrey;
  }

  String get imageUrl => isReportModel ? widget.item.imageUrl : (isClaimModel ? (widget.item.reportImageUrl ?? '') : widget.item.imageUrl);
  String? get localImagePath => isReportModel ? widget.item.localImagePath : null;
  String? get imbalan => isReportModel ? widget.item.reward : null;
  String get kategori => isReportModel ? widget.item.category : "Barang Temuan";
  String get waktuLapor {
    if (isReportModel || isClaimModel) {
      final createdAt = widget.item.createdAt as DateTime;
      return TimeHelper.formatRelative(createdAt);
    }
    return "";
  }

  String get deskripsi => isReportModel ? widget.item.description : (isClaimModel ? "Detail klaim yang sedang diajukan." : widget.item.deskripsi);
  String get id => isReportModel ? widget.item.id : (isClaimModel ? widget.item.id : widget.item.nama);
  String? get userId => isReportModel ? widget.item.userId : (isClaimModel ? widget.item.claimantId : null);
  String? get kontak => isReportModel ? widget.item.contact : null;

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
    final theme = Theme.of(context);
    final session = context.watch<SessionController>();
    final claimController = context.watch<ClaimController>();
    final currentUser = session.currentUser;
    final isOwner = userId != null && currentUser != null && userId == currentUser.id;
    final isTeknisi = session.isTeknisi;

    final hasAlreadyClaimed = !widget.isFromUserClaim && claimController.claims.any((c) => c.reportId == id && c.claimantId == currentUser?.id);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailHeroImage(
                  imageProvider: imageProvider,
                  onBack: () => Navigator.pop(context),
                ),
                const SizedBox(height: AppTheme.kPaddingLarge),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.kPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.isFromUserClaim) ...[
                        ClaimProgressStepper(status: status),
                        const SizedBox(height: AppTheme.kPaddingLarge),
                      ] else if (widget.canManage) ...[
                        ReportProgressStepper(
                          status: status, 
                          isLost: isLost,
                          isEdit: id.startsWith('pending_update_') || id.startsWith('draft_') && widget.item.createdAt != null && !id.startsWith('pending_create_'),
                        ),
                        const SizedBox(height: AppTheme.kPaddingLarge),
                      ],

                      if (showRewardBanner) DetailRewardBanner(imbalan: imbalan!),
                      if (showRewardBanner) const SizedBox(height: AppTheme.kPadding),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              nama,
                              style: theme.textTheme.headlineLarge,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15), 
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor.withOpacity(0.3)),
                            ),
                            child: Text(
                              isVerified ? "VERIFIED" : (isRejected ? "REJECTED" : (isResolved ? (isLost ? "KETEMU" : "DIAMBIL") : status.toUpperCase())),
                              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.kPadding),
                      Text("Deskripsi", style: theme.textTheme.titleMedium?.copyWith(color: AppColors.primaryBlue)),
                      const SizedBox(height: 8),
                      Text(
                        deskripsi, 
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          color: Colors.black87,
                        )
                      ),
                      const SizedBox(height: AppTheme.kPaddingLarge),
                      DetailInfoGrid(kategori: kategori, waktuLapor: waktuLapor),
                      const SizedBox(height: AppTheme.kPaddingLarge * 1.5),

                      if (widget.isFromUserClaim) ...[
                        if (isVerified) ...[
                          Center(
                            child: Text(
                              "Klaim ini telah diverifikasi. Silakan ambil barang di tempat yang ditentukan.",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ] else if (isRejected) ...[
                          Center(
                            child: Text(
                              "Klaim ditolak. Barang kemungkinan besar telah diserahkan kepada pemilik yang sah.",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ] else ...[
                          _buildCancelClaimButton(context),
                        ],
                        const SizedBox(height: AppTheme.kPadding),
                      ] else ...[
                        if (!isResolved) ...[
                          if (isFound && !isOwner) ...[
                            _buildKlaimButton(context, hasAlreadyClaimed),
                            const SizedBox(height: AppTheme.kPadding),
                          ],

                          if (widget.canManage && isSynced) ...[
                            if (isFound && isTeknisi) ...[
                              _buildResolvedButton(context, "TANDAI SUDAH DIAMBIL"),
                              const SizedBox(height: AppTheme.kPadding),
                            ] else if (isLost && isOwner) ...[
                              _buildResolvedButton(context, "BARANG SUDAH KETEMU"),
                              const SizedBox(height: AppTheme.kPadding),
                            ],
                          ],

                          if (!isOwner) ...[
                            _buildHubungiButton(context),
                            const SizedBox(height: AppTheme.kPadding),
                            _buildReportButton(context),
                          ] else ...[
                             if (!isSynced && !isResolved) ...[
                               _buildSubmitDraftButton(context),
                               const SizedBox(height: AppTheme.kPadding),
                             ],
                             Center(
                               child: Text(
                                 "Ini adalah postingan Anda.", 
                                 style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)
                               )
                             ),
                          ],
                        ] else ...[
                          Center(
                            child: Text(
                              "Postingan ini telah diselesaikan.", 
                              style: theme.textTheme.titleMedium?.copyWith(color: AppColors.success)
                            )
                          ),
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

  Widget _buildSubmitDraftButton(BuildContext context) {
    final controller = context.watch<ReportController>();
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
      icon: controller.isLoading 
        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryYellow))
        : const Icon(Icons.send_rounded, color: AppColors.primaryYellow),
      label: const Text("KIRIM LAPORAN"),
      onPressed: controller.isLoading ? null : () => _handlePublishDraft(context),
    );
  }

  Future<void> _handlePublishDraft(BuildContext context) async {
    final controller = context.read<ReportController>();
    final session = context.read<SessionController>();
    final user = session.currentUser;

    if (imageProvider == null) {
       NotificationBanner.show(context, "Gambar wajib untuk mengirim laporan.", isError: true);
       return;
    }

    File? imageFile;
    if (localImagePath != null && localImagePath!.isNotEmpty) {
      imageFile = File(localImagePath!);
    }

    try {
      await controller.finalizeReport(
        reportData: (widget.item as ReportModel).toMap(),
        imageFile: imageFile,
        existingId: id,
        userId: user?.id,
      );
      
      if (context.mounted) {
        if (!controller.lastOperationFailed) {
          final session = context.read<SessionController>();
          StatusDialog.show(
            context,
            title: "Berhasil!",
            confirmLabel: "OK",
            message: "Laporan anda telah berhasil dibuat dan simpan di database",
            onConfirm: () {
              if (session.isTeknisi) {
                context.go('/teknisi-home');
              } else {
                context.go('/my-reports');
              }
            },
          );
        } else {
          NotificationBanner.show(context, controller.message, isError: true);
        }
      }
    } catch (e) {
      if (context.mounted) NotificationBanner.show(context, "Gagal mengirim: $e", isError: true);
    }
  }

  Widget _buildKlaimButton(BuildContext context, bool hasAlreadyClaimed) {
    final session = context.watch<SessionController>();
    final user = session.currentUser;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: hasAlreadyClaimed ? AppColors.mediumGrey : AppColors.primaryBlue,
        foregroundColor: hasAlreadyClaimed ? AppColors.textGrey : Colors.white,
      ),
      icon: Icon(Icons.check_circle_outline, color: hasAlreadyClaimed ? AppColors.textGrey : AppColors.primaryYellow),
      label: Text(hasAlreadyClaimed ? "KLAIM SEDANG DIPROSES" : "AJUKAN KLAIM"),
      onPressed: hasAlreadyClaimed ? null : () async {
        if (user == null) {
          NotificationBanner.show(context, "Harap login untuk melakukan klaim.", isError: true);
          return;
        }

        final claimRepo = ClaimRepository();
        final claim = ClaimModel(id: '', reportId: id, reportTitle: nama, claimantName: user.name, claimantId: user.id, claimantEmail: user.email, reportImageUrl: imageUrl, status: 'pending', createdAt: DateTime.now());

        try {
          await claimRepo.submitClaim(claim);
          if (context.mounted) {
            context.read<ClaimController>().loadClaims(); 
            NotificationBanner.show(context, "Klaim berhasil diajukan! Pantau di menu Klaim Saya.");
          }
        } catch (e) {
          if (context.mounted) NotificationBanner.show(context, "Gagal mengajukan klaim: $e", isError: true);
        }
      },
    );
  }

  Widget _buildCancelClaimButton(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      icon: const Icon(Icons.cancel_outlined),
      label: const Text("BATALKAN KLAIM"),
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Batalkan Klaim?"),
            content: const Text("Apakah Anda yakin ingin membatalkan pengajuan klaim ini?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("TIDAK")),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true), 
                child: const Text("YA, BATALKAN", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold))
              ),
            ],
          ),
        );

        if (confirm == true && context.mounted) {
          final claimRepo = ClaimRepository();
          try {
            await claimRepo.deleteClaim(id); 
            if (context.mounted) {
              context.read<ClaimController>().loadClaims();
              Navigator.pop(context);
              NotificationBanner.show(context, "Klaim berhasil dibatalkan.");
            }
          } catch (e) {
            NotificationBanner.show(context, "Gagal membatalkan klaim: $e", isError: true);
          }
        }
      },
    );
  }

  Widget _buildHubungiButton(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
      icon: const Icon(Icons.chat_outlined),
      label: const Text("HUBUNGI PELAPOR"),
      onPressed: () async {
        if (kontak == null || kontak!.isEmpty) {
          NotificationBanner.show(context, "Nomor kontak tidak tersedia.", isError: true);
          return;
        }

        String phone = kontak!.replaceAll(RegExp(r'[^0-9]'), '');
        if (phone.startsWith('0')) {
          phone = '62${phone.substring(1)}';
        }

        final Uri whatsappUri = Uri.parse("https://wa.me/$phone");
        
        try {
          if (await canLaunchUrl(whatsappUri)) {
            await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
          } else {
            final Uri telUri = Uri.parse("tel:$phone");
            if (await canLaunchUrl(telUri)) {
              await launchUrl(telUri);
            } else {
              throw 'Could not launch $whatsappUri';
            }
          }
        } catch (e) {
           NotificationBanner.show(context, "Gagal membuka aplikasi chat: $e", isError: true);
        }
      },
    );
  }

  Widget _buildReportButton(BuildContext context) {
    if (_isCheckingReport) {
      return const Center(child: CircularProgressIndicator());
    }

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: _hasAlreadyReported ? AppColors.textGrey : AppColors.error,
        side: BorderSide(color: _hasAlreadyReported ? AppColors.mediumGrey : AppColors.error, width: 1.5),
      ),
      icon: const Icon(Icons.warning_outlined),
      label: Text(_hasAlreadyReported ? "TELAH DILAPORKAN" : "LAPORKAN POSTINGAN"),
      onPressed: _hasAlreadyReported ? null : () async {
        final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ReportPostPageProvider(item: widget.item)));
        if (result == true) {
          _checkReportStatus(); // Refresh status
        }
      },
    );
  }

  Widget _buildResolvedButton(BuildContext context, String label) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
      icon: const Icon(Icons.done_all_rounded, color: Colors.white),
      label: Text(label),
      onPressed: () => _showResolveDialog(context),
    );
  }

  void _showResolveDialog(BuildContext context) {
    final nameController = TextEditingController();
    final idController = TextEditingController();
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Selesaikan Laporan"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Masukkan data pengambil barang untuk arsip sistem.",
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppTheme.kPadding),
            CustomTextField(label: "Nama Pengambil", hint: "Nama Lengkap", controller: nameController),
            CustomTextField(label: "NIM Pengambil", hint: "NIM / ID", controller: idController),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("BATAL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 40)),
            onPressed: () async {
              if (nameController.text.isEmpty || idController.text.isEmpty) {
                NotificationBanner.show(ctx, "Data pengambil wajib diisi.", isError: true);
                return;
              }
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
                  StatusDialog.show(context, title: "Berhasil", message: "Laporan telah diselesaikan dan barang telah diambil.");
                }
              } catch (e) {
                NotificationBanner.show(ctx, "Error: $e", isError: true);
              }
            },
            child: const Text("SIMPAN"),
          ),
        ],
      ),
    );
  }
}
