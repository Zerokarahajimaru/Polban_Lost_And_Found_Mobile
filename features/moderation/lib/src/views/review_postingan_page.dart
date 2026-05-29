import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:core_module/core_module.dart';
import '../controllers/moderation_controller.dart';
import '../models/moderation_report.dart';
import '../widgets/moderation_widgets.dart';

class ReviewPostinganPage extends StatefulWidget {
  final ModerationReport report;

  const ReviewPostinganPage({super.key, required this.report});

  @override
  State<ReviewPostinganPage> createState() => _ReviewPostinganPageState();
}

class _ReviewPostinganPageState extends State<ReviewPostinganPage> {
  late ModerationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = context.read<ModerationController>();
    _controller.addListener(_handleControllerUpdate);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerUpdate);
    super.dispose();
  }

  void _handleControllerUpdate() {
    if (_controller.message.isNotEmpty) {
      NotificationBanner.show(
        context,
        _controller.message,
        isError: _controller.lastOperationFailed,
      );
      _controller.clearMessage();
    }
  }


  Future<void> _onTakedown() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Konfirmasi Takedown',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Yakin ingin men-takedown\n"${widget.report.postTitle}"?\n\nAksi ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ya, Takedown'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _controller.takedownReport(widget.report.id);
      if (mounted && !_controller.lastOperationFailed) {
        Navigator.pop(context); // kembali ke list setelah sukses
      }
    }
  }


  Future<void> _onIgnore() async {
    await _controller.ignoreReport(widget.report.id);
    if (mounted && !_controller.lastOperationFailed) {
      Navigator.pop(context);
    }
  }


  String _formatDate(DateTime dt) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(dt);
  }

  String _formatTime(DateTime dt) {
    return '${DateFormat('HH.mm').format(dt)} WIB';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const CustomHeader(
        title: 'Review Postingan',
        showBackButton: true,
      ),
      body: Consumer<ModerationController>(
        builder: (context, ctrl, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPostImage(),
                    _buildUploaderCard(),
                    _buildReportersList(),
                  ],
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildActionBar(ctrl.isLoading),
              ),
            ],
          );
        },
      ),
    );
  }


  Widget _buildPostImage() {
    final imageUrl = widget.report.postImageUrl;
    return SizedBox(
      height: 220,
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imageFallback(),
            )
          : _imageFallback(),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: AppColors.secondaryBlue,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 64, color: AppColors.primaryBlue),
      ),
    );
  }


  Widget _buildUploaderCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Avatar pengunggah
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          // Nama pengunggah
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Diposting oleh',
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
                Text(
                  widget.report.uploaderName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          // Tanggal & jam laporan
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: AppColors.primaryYellow,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(widget.report.reportedAt),
                    style: const TextStyle(
                      color: AppColors.primaryYellow,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.white60,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(widget.report.reportedAt),
                    style: const TextStyle(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildReportersList() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              'Daftar Pelapor',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          ...widget.report.reporters.asMap().entries.map(
                (e) => _buildReporterRow(number: e.key + 1, reporter: e.value),
              ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildReporterRow({
    required int number,
    required ModerationReporter reporter,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Nomor urut
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nama & NIM
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reporter.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  reporter.nim,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          // Badge alasan
          ReasonBadge(reason: reporter.reason),
        ],
      ),
    );
  }


  Widget _buildActionBar(bool isLoading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tombol Takedown Konten
          Expanded(
            flex: 3,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _onTakedown,
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.delete_outline, size: 18),
              label: const Text(
                'Takedown Konten',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Tombol Abaikan
          Expanded(
            flex: 2,
            child: OutlinedButton(
              onPressed: isLoading ? null : _onIgnore,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textGrey,
                side: const BorderSide(color: Color(0xFFDDDDDD)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Abaikan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}