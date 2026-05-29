import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';
import 'package:moderation/moderation.dart';
import 'package:provider/provider.dart';

// ========================
// HALAMAN LAPORKAN KONTEN (FULL RED BACKGROUND)
// ========================
class ReportPostPageProvider extends StatelessWidget {
  final dynamic item;
  const ReportPostPageProvider({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ModerationController(),
      child: ReportPostPage(item: item),
    );
  }
}

class ReportPostPage extends StatefulWidget {
  final dynamic item;
  const ReportPostPage({super.key, required this.item});

  @override
  State<ReportPostPage> createState() => _ReportPostPageState();
}

class _ReportPostPageState extends State<ReportPostPage> {
  String? _selectedAlasan;

  final List<String> _alasanList = [
    'SPAM/IKLAN',
    'Penyampaian palsu (Isi tidak sesuai)',
    'Konten tidak pantas',
    'Sudah ditemukan',
  ];

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ModerationController>();
    final session = context.watch<SessionController>();
    final currentUser = session.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFD32F2F), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'LAPORKAN KONTEN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pilih alasan mengapa konten ini melanggar peraturan kami.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  'Alasan Pelaporan:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ..._alasanList.map((alasan) => _buildAlasanTile(alasan)),
              
              const SizedBox(height: 32),

              if (controller.isLoading)
                const CircularProgressIndicator(color: Colors.white)
              else
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFD32F2F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: const Icon(Icons.flag_rounded, size: 20),
                    label: const Text(
                      'LAPORKAN SEKARANG',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: _selectedAlasan == null
                        ? null
                        : () async {
                            final isReportModel = widget.item is ReportModel;
                            final String postId = isReportModel ? widget.item.id : widget.item.nama;
                            final String postTitle = isReportModel ? widget.item.title : widget.item.nama;
                            final String uploaderName = isReportModel ? 'User' : (widget.item.uploaderName ?? 'Unknown');
                            final String? postImageUrl = isReportModel ? widget.item.imageUrl : widget.item.imageUrl;

                            await controller.submitReport(
                              postId: postId,
                              postTitle: postTitle,
                              reportReason: _selectedAlasan!,
                              uploaderName: uploaderName,
                              postImageUrl: postImageUrl,
                              reporterName: currentUser?.name ?? 'Anonymous',
                              reporterNim: currentUser?.id ?? '0000000000',
                            );

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(controller.message),
                                backgroundColor: controller.lastOperationFailed ? Colors.red : Colors.black87,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );

                            if (!controller.lastOperationFailed) {
                              Navigator.pop(context);
                            }
                          },
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlasanTile(String alasan) {
    final isSelected = _selectedAlasan == alasan;
    return GestureDetector(
      onTap: () => setState(() => _selectedAlasan = alasan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.1),
          border: Border.all(
            color: Colors.white,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                alasan,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD32F2F) : Colors.white,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? const Color(0xFFD32F2F) : Colors.white70,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}