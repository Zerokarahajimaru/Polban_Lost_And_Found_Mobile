import 'dart:io';
import 'package:core_module/core_module.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:report/src/controllers/report_controller.dart';
import 'package:report/src/views/create_report_page.dart';

class MyReportsProvider extends StatelessWidget {
  const MyReportsProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportController()..getReports(),
      child: const MyReportsPage(),
    );
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller = context.read<ReportController>();
    _controller.addListener(_handleControllerUpdates);
  }

  void _handleControllerUpdates() {
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
    // The controller is now passed down using ChangeNotifierProvider.value
    // to ensure the same instance is used by the CreateReportPage.
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: _controller,
          // The CreateReportProvider is no longer needed here as we provide the controller directly.
          child: CreateReportPage(existingReport: report),
        ),
      ),
    );
    // No need to call getReports() here anymore.
    // The controller will update its state and notify listeners itself.
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
      await _controller.getReports();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ReportController>();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _buildLoadedView(controller.reports, controller.isLoading),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryYellow,
        shape: const CircleBorder(
            side: BorderSide(color: AppColors.primaryBlue, width: 4)),
        onPressed: () => _navigateToCreateOrEdit(),
        child: const Icon(Icons.add, color: AppColors.primaryBlue, size: 35),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: CustomBottomNav(
          currentIndex: 1,
          onTap: (index) {
             if (index == 0) {
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadedView(List<ReportModel> reports, bool isLoading) {
    final pendingReports = reports.where((r) => r.status.contains('pending') || r.status == 'draft').toList();
    final historyReports = reports.where((r) => !r.status.contains('pending') && r.status != 'draft').toList();

    return Column(
      children: [
        _buildHeader(reports.length),
        const SizedBox(height: 50),
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

  Widget _buildHeader(int total) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40))),
          padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.chevron_left,
                      color: AppColors.primaryYellow, size: 30)),
              const SizedBox(width: 10),
              const Text("Riwayat Laporanku",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Positioned(
            bottom: -40, left: 20, right: 20,
            child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
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
                                color: AppColors.primaryYellow.withOpacity(0.2),
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
                    ]))),
      ],
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
    if (isLoading && reports.isEmpty) {
       return const Center(child: CircularProgressIndicator());
    }
    if (reports.isEmpty) {
      return const Center(child: Text("Tidak ada laporan di sini"));
    }
    return RefreshIndicator(
      onRefresh: () => context.read<ReportController>().getReports(),
      child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: reports.length,
          itemBuilder: (context, index) => _buildReportCard(reports[index])),
    );
  }

  Widget _buildReportCard(ReportModel report) {
    final bool isDraft = report.status == 'draft';
    final bool isPending = report.status.contains('pending');
    final bool isOffline = isDraft || isPending;
    final bool canEdit = isOffline || (DateTime.now().difference(report.createdAt).inHours < 24);
    final bool isLost = report.status != 'found';

    ImageProvider? imageProvider;
    if (report.localImagePath != null && report.localImagePath!.isNotEmpty) {
      imageProvider = FileImage(File(report.localImagePath!));
    } else if (report.imageUrl.isNotEmpty) {
      imageProvider = NetworkImage(report.imageUrl);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100)),
      child: Row(
        children: [
          Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: AppColors.secondaryBlue,
                  image: imageProvider != null
                      ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                      : null),
              child: imageProvider == null
                  ? const Icon(Icons.image_not_supported, color: Colors.white)
                  : null),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.title.isEmpty ? "(Tanpa Judul)" : report.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                    report.location.isEmpty
                        ? "Lokasi tidak ditentukan"
                        : report.location,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: isOffline
                                ? Colors.orange.shade100
                                : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                            isDraft
                                ? "Draft"
                                : (isPending ? "Pending" : "Tersinkron"),
                            style: TextStyle(
                                color: isOffline
                                    ? Colors.orange.shade800
                                    : Colors.blue.shade800,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: isLost
                                ? Colors.red.shade100
                                : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(isLost ? "Hilang" : "Ditemukan",
                            style: TextStyle(
                                color: isLost
                                    ? Colors.red.shade800
                                    : Colors.green.shade800,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                    ]),
                    Row(children: [
                      if (canEdit)
                        GestureDetector(
                          onTap: () => _navigateToCreateOrEdit(report: report),
                          child: const Icon(Icons.edit,
                              color: AppColors.primaryBlue, size: 20),
                        ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _deleteAndRefresh(report),
                        child: const Icon(Icons.delete_forever,
                            color: Colors.red, size: 22),
                      ),
                    ])
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}