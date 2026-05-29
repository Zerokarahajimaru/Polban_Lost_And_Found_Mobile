import 'dart:io';
import 'dart:ui';
import 'package:core_module/core_module.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:report/src/controllers/report_controller.dart';
import 'package:report/src/views/create_report_page.dart';

class MyReportsProvider extends StatelessWidget {
  const MyReportsProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyReportsPage();
  }
}

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ReportController _controller;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller = context.read<ReportController>();
    _controller.addListener(_handleControllerUpdates);
    
    _userId = context.read<SessionController>().currentUser?.id;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.getReports(); // Fetch all reports globally
    });
  }

  void _handleControllerUpdates() {
    if (!mounted) return;
    if (_controller.message.isNotEmpty) {
      NotificationBanner.show(
        context,
        _controller.message,
        isError: _controller.lastOperationFailed,
      );
      _controller.clearMessage(); 
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerUpdates);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _navigateToCreateOrEdit({ReportModel? report}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateReportPage(existingReport: report),
      ),
    );
    
    // Always refresh list after returning from edit/create
    if (mounted) {
      _controller.getReports();
    }
  }

  Future<void> _deleteAndRefresh(ReportModel report) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Laporan?"),
        content: Text(
            "Anda yakin ingin menghapus '${report.title}'? Tindakan ini tidak dapat dibatalkan."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Batal")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _controller.deleteReport(report.id, report.status);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReportController>();
    final session = context.watch<SessionController>();
    final isTeknisi = session.isTeknisi;
    
    // Filter ALL reports locally to only show reports belonging to this user
    final reports = controller.reports.where((r) => r.userId == _userId).toList();
    
    return Scaffold(
      backgroundColor: AppColors.softGrey,
      appBar: CustomHeader(
        title: "Riwayat Laporanku",
        showBackButton: isTeknisi, 
        extraHeight: 110,
        onNotificationTap: () {},
        bottomChild: _buildStatsCard(reports.length, isTeknisi),
      ),
      body: _buildLoadedView(reports, controller.isLoading),
    );
  }

  Widget _buildLoadedView(List<ReportModel> reports, bool isLoading) {
    // Correct filtering for tabs
    final pendingReports = reports.where((r) => 
      r.status.toLowerCase().contains('pending') || 
      r.status.toLowerCase() == 'draft'
    ).toList();
    
    final historyReports = reports.where((r) => 
      !r.status.toLowerCase().contains('pending') && 
      r.status.toLowerCase() != 'draft'
    ).toList();

    return Column(
      children: [
        const SizedBox(height: 12),
        _buildTabs(),
        Expanded(
          child: isLoading && reports.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildReportList(pendingReports, isLoading),
                  _buildReportList(historyReports, isLoading)
                ],
              ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(int total, bool isTeknisi) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ]),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppColors.primaryYellow.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(15)),
                  child: const Icon(Icons.history,
                      color: AppColors.primaryBlue)),
              const SizedBox(width: 15),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("TOTAL LAPORAN",
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold)),
                    Text("$total Laporan",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue))
                  ])
            ]),
            if (isTeknisi)
              GestureDetector(
                onTap: () => _navigateToCreateOrEdit(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryBlue, width: 2),
                  ),
                  child: const Icon(Icons.add, color: AppColors.primaryBlue, size: 24),
                ),
              ),
          ]),
    );
  }

  Widget _buildTabs() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primaryYellow,
            indicatorWeight: 3,
            tabs: const [Tab(text: "Pending"), Tab(text: "Riwayat")]));
  }

  Widget _buildReportList(List<ReportModel> reports, bool isLoading) {
    return RefreshIndicator(
      onRefresh: () => context.read<ReportController>().getReports(),
      child: reports.isEmpty
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.5,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        size: 64,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Belum Ada Laporan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Tarik ke bawah untuk memuat ulang.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: reports.length,
              itemBuilder: (context, index) => _buildReportCard(reports[index])),
    );
  }

  Widget _buildReportCard(ReportModel report) {
    final bool isDraft = report.status.toLowerCase() == 'draft';
    final bool isPending = report.status.toLowerCase().contains('pending');
    final bool isOffline = isDraft || isPending;
    final bool canEdit = isOffline || (DateTime.now().difference(report.createdAt).inHours < 24);
    final bool isLost = report.status.toLowerCase() != 'found';

    ImageProvider? imageProvider;
    if (report.localImagePath != null && report.localImagePath!.isNotEmpty) {
      imageProvider = FileImage(File(report.localImagePath!));
    } else if (report.imageUrl.isNotEmpty) {
      imageProvider = NetworkImage(report.imageUrl);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 100,
              decoration: BoxDecoration(
                color: AppColors.softGrey,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                child: imageProvider != null
                    ? Stack(
                        children: [
                          Positioned.fill(
                            child: Image(image: imageProvider, fit: BoxFit.cover),
                          ),
                          Positioned.fill(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(color: Colors.black.withValues(alpha: 0.1)),
                            ),
                          ),
                          Center(
                            child: Image(image: imageProvider, fit: BoxFit.contain),
                          ),
                        ],
                      )
                    : const Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            color: AppColors.textGrey, size: 30),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusBadge(
                          isDraft ? "DRAFT" : (isPending ? "PENDING" : "TERKIRIM"),
                          isDraft ? Colors.orange : (isPending ? Colors.blue : Colors.green),
                        ),
                        if (canEdit)
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => _navigateToCreateOrEdit(report: report),
                                child: const Icon(Icons.edit_outlined,
                                    color: AppColors.primaryBlue, size: 18),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _deleteAndRefresh(report),
                                child: const Icon(Icons.delete_outline,
                                    color: Colors.red, size: 20),
                              ),
                            ],
                          )
                        else
                          GestureDetector(
                            onTap: () => _deleteAndRefresh(report),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.red, size: 20),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      report.title.isEmpty ? "(Tanpa Judul)" : report.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primaryBlue,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: AppColors.textGrey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            report.location.isEmpty
                                ? "Lokasi tidak ditentukan"
                                : report.location,
                            style: const TextStyle(color: AppColors.textGrey, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTypeBadge(isLost),
                        Text(
                          "${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}",
                          style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTypeBadge(bool isLost) {
    final color = isLost ? const Color(0xFFFF6B35) : AppColors.primaryYellow;
    final textColor = isLost ? Colors.white : AppColors.primaryBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isLost ? "KEHILANGAN" : "TEMUAN",
        style: TextStyle(
          color: textColor,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
