import 'package:core_module/core_module.dart' hide ReportModel;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:report/src/controllers/report_controller.dart';
import 'package:report/src/models/report_model.dart';
import 'package:report/src/views/create_report_page.dart';

// Wrap the original page in a provider
class MyReportsProvider extends StatelessWidget {
  const MyReportsProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportController()..getReports(), // Fetch reports on init
      child: const MyReportsPage(),
    );
  }
}

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<ReportController>(
        builder: (context, controller, child) {
          switch (controller.state) {
            case NotifierState.loading:
              return const Center(child: CircularProgressIndicator());
            case NotifierState.error:
              return Center(child: Text('Gagal memuat data: ${controller.message}'));
            case NotifierState.initial:
            case NotifierState.loaded:
              return _buildLoadedView(controller.reports);
          }
        },
      ),
      // ADD THE FLOATING ACTION BUTTON AND ITS NAVIGATION LOGIC HERE
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: AppColors.primaryYellow,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.primaryBlue, width: 4),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateReportProvider()),
              ).then((_) {
                // After returning from create page, refresh the list
                context.read<ReportController>().getReports();
              });
            },
            child: const Icon(Icons.add, color: AppColors.primaryBlue, size: 35),
          ),
          const SizedBox(height: 4),
          const Text(
            "Lapor",
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          // Navigation logic here
        },
      ),
    );
  }

  Widget _buildLoadedView(List<ReportModel> reports) {
    // For now, pending is empty and history shows all reports
    final pendingReports = <ReportModel>[];
    final historyReports = reports;

    return Column(
      children: [
        _buildHeader(historyReports.length),
        const SizedBox(height: 50),
        _buildTabs(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildReportList(pendingReports, isPending: true),
              _buildReportList(historyReports, isPending: false),
            ],
          ),
        ),
      ],
    );
  }

  // ---UNCHANGED UI HELPER WIDGETS---
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
              bottomRight: Radius.circular(40),
            ),
          ),
          padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.chevron_left, color: AppColors.primaryYellow, size: 30),
              SizedBox(width: 10),
              Text(
                "Riwayat Laporanku",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: -40,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.primaryYellow.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
                      child: const Icon(Icons.history, color: AppColors.primaryBlue),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("TOTAL LAPORAN", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        Text("$total Laporan", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                      ],
                    )
                  ],
                ),
                const CircleAvatar(
                  backgroundColor: AppColors.primaryBlue,
                  child: Icon(Icons.add, color: Colors.white),
                )
              ],
            ),
          ),
        )
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
        tabs: const [
          Tab(text: "Pending"),
          Tab(text: "Riwayat"),
        ],
      ),
    );
  }

  Widget _buildReportList(List<ReportModel> reports, {required bool isPending}) {
    if (reports.isEmpty) {
      return Center(child: Text(isPending ? "Tidak ada laporan pending" : "Belum ada riwayat laporan"));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildReportCard(report, isPending);
      },
    );
  }

  Widget _buildReportCard(ReportModel report, bool isPending) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: AppColors.secondaryBlue,
              image: DecorationImage(image: NetworkImage(report.imageUrl), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                Text(report.location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPending ? Colors.orange.shade100 : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isPending ? "Pending" : "Tersinkron",
                    style: TextStyle(color: isPending ? Colors.orange : Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}