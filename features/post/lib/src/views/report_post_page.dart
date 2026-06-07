import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';
import 'package:moderation/moderation.dart';
import 'package:provider/provider.dart';
import 'package:home/home.dart';

// ========================
// HALAMAN LAPORKAN KONTEN
// ========================
class ReportPostPageProvider extends StatelessWidget {
  final dynamic item;
  const ReportPostPageProvider({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ModerationController()),
      ],
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
  String? _selectedReason;
  bool _isHidingPost = false; // [1] Hide Post Option

  final List<String> _reasons = [
    'Spam atau Iklan',
    'Penipuan atau Barang Palsu',
    'Konten Tidak Pantas/Kasar',
    'Informasi Salah (Hoax)',
    'Sudah Ditemukan tapi Belum Ditutup',
    'Lainnya',
  ];

  String get _itemTitle => widget.item is ReportModel ? widget.item.title : widget.item.namaBarang;
  String get _itemOwner => widget.item is ReportModel ? (widget.item.userId ?? 'Unknown') : widget.item.userId;
  String get _itemImage => widget.item is ReportModel ? widget.item.imageUrl : (widget.item.images?.isNotEmpty == true ? widget.item.images[0] : '');

  @override
  Widget build(BuildContext context) {
    final modController = context.watch<ModerationController>();
    final session = context.read<SessionController>();
    final user = session.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const CustomHeader(title: 'Laporkan Postingan'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Postingan
            _buildPostPreview(),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Mengapa Anda melaporkan ini?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Laporan Anda membantu kami menjaga komunitas Polban tetap aman.",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),

                  // List Alasan
                  ..._reasons.map((reason) => _buildReasonItem(reason)),
                  
                  const SizedBox(height: 32),

                  // [1] Hide Post Toggle
                  _buildHideToggle(),

                  const SizedBox(height: 40),

                  // Tombol Kirim
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _selectedReason == null
                            ? Colors.grey.shade300
                            : const Color(0xFFD32F2F), // Red for Warning
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      onPressed: (_selectedReason == null || modController.isLoading)
                          ? null
                          : () => _submitReport(context, modController, user),
                      child: modController.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "KIRIM LAPORAN",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 60,
              height: 60,
              color: AppColors.softGrey,
              child: _itemImage.isNotEmpty
                  ? Image.network(_itemImage, fit: BoxFit.cover)
                  : const Icon(Icons.image_outlined, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _itemTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Oleh: $_itemOwner",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHideToggle() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility_off_outlined, color: Colors.grey),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Sembunyikan postingan ini dari beranda saya",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Switch(
            value: _isHidingPost,
            onChanged: (val) => setState(() => _isHidingPost = val),
            activeThumbColor: AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildReasonItem(String reason) {
    bool isSelected = _selectedReason == reason;
    return GestureDetector(
      onTap: () => setState(() => _selectedReason = reason),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFEBEE) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFD32F2F) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                reason,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFFD32F2F) : Colors.black87,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? const Color(0xFFD32F2F) : Colors.grey.shade300,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  void _submitReport(BuildContext context, ModerationController controller, dynamic user) async {
    final postId = widget.item.id;
    
    await controller.submitReport(
      postId: postId,
      postTitle: _itemTitle,
      reportReason: _selectedReason!,
      uploaderName: _itemOwner,
      postImageUrl: _itemImage.isNotEmpty ? _itemImage : null,
      reporterName: user?.name ?? 'Anonymous',
      reporterNim: user?.id ?? '-',
    );

    if (!mounted) return;

    if (controller.lastOperationFailed) {
      StatusDialog.show(
        context,
        isSuccess: false,
        title: "Gagal",
        message: controller.message,
      );
    } else {
      // [1] Handle local hiding if selected
      if (_isHidingPost) {
        final hive = HiveService();
        final hiddenPosts = hive.settingsBox.get('hidden_posts', defaultValue: <String>[]) as List<dynamic>;
        final newList = List<String>.from(hiddenPosts);
        if (!newList.contains(postId)) {
          newList.add(postId);
          await hive.settingsBox.put('hidden_posts', newList);
          
          // Force home feed to reload local filters
          if (mounted) {
            context.read<HomeController>().loadHiddenPosts();
          }
        }
      }

      StatusDialog.show(
        context,
        title: "Laporan Terkirim",
        message: "Terima kasih, laporan Anda sedang ditinjau oleh tim moderasi.",
        onConfirm: () {
          Navigator.pop(context); // Close dialog
          Navigator.pop(context, true); // Back to detail/home with result true
        },
      );
    }
  }
}
