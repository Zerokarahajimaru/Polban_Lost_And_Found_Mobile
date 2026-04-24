import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:report/src/repositories/report_repository.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initData();
  }

  Future<void> _initData() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder(
              valueListenable: Hive.box<ReportModel>('reports').listenable(),
              builder: (context, Box<ReportModel> box, _) {
                final allReports = box.values.toList();
                final pendingReports = allReports.where((r) => !r.isSynced).toList();
                final syncedReports = allReports.where((r) => r.isSynced).toList();

                return Column(
                  children: [
                    _buildHeader(allReports.length),
                    const SizedBox(height: 50), 
                    _buildTabs(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildReportList(pendingReports, isPending: true),
                          _buildReportList(syncedReports, isPending: false),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          // Logika pindah halaman
        },
      ),
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
      return const Center(child: Text("Tidak ada laporan"));
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
              image: report.images.isNotEmpty 
                  ? DecorationImage(image: NetworkImage(report.images.first), fit: BoxFit.cover)
                  : null,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report.namaBarang, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
                Text(report.lokasiKehilangan, style: const TextStyle(color: Colors.grey, fontSize: 12)),
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