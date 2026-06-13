import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:core_module/core_module.dart';
import '../controllers/moderation_controller.dart';
import '../models/moderation_report.dart';
import '../widgets/moderation_card.dart';
import 'review_postingan_page.dart';


class ModerasiPostinganProvider extends StatelessWidget {
  const ModerasiPostinganProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ModerationController()..loadReports(),
      child: const ModerasiPostinganPage(),
    );
  }
}


class ModerasiPostinganPage extends StatefulWidget {
  const ModerasiPostinganPage({super.key});

  @override
  State<ModerasiPostinganPage> createState() => _ModerasiPostinganPageState();
}

class _ModerasiPostinganPageState extends State<ModerasiPostinganPage> {
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


  Future<void> _onTakedown(ModerationReport report) async {
    final confirm = await _showTakedownDialog(report.postTitle);
    if (confirm == true && mounted) {
      await _controller.takedownReport(report.id);
    }
  }


  Future<void> _onIgnore(ModerationReport report) async {
    await _controller.ignoreReport(report.id);
  }


  void _openReview(ModerationReport report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: _controller,
          child: ReviewPostinganPage(report: report),
        ),
      ),
    );
  }


  Future<bool?> _showTakedownDialog(String postTitle) {
    return showDialog<bool>(
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
          'Yakin ingin men-takedown\n"$postTitle"?\n\nAksi ini tidak bisa dibatalkan.',
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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: const CustomHeader(
        title: 'Moderasi Postingan',
        showBackButton: true,
      ),
      body: Consumer<ModerationController>(
        builder: (context, ctrl, _) {
          // Loading state
          if (ctrl.isLoading && ctrl.reports.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          final pending = ctrl.pendingReports;

          // Empty state
          if (pending.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 72,
                    color: Colors.green.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tidak ada laporan masuk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Semua postingan sudah dimoderasi.',
                    style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                  ),
                ],
              ),
            );
          }

          // List laporan
          return RefreshIndicator(
            color: AppColors.primaryBlue,
            onRefresh: ctrl.loadReports,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                    child: Text(
                      'Laporan Masuk',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) {
                      final report = pending[index];
                      return ModerationCard(
                        report: report,
                        onTap: () => _openReview(report),
                        onTakedown: () => _onTakedown(report),
                        onIgnore: () => _onIgnore(report),
                      );
                    },
                    childCount: pending.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}