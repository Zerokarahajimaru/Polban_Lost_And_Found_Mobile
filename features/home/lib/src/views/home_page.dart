import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:report/report.dart'; 
import 'package:home/src/controllers/home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // LOGIC BE: Memastikan data diambil saat startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportController>().getReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(),
      child: Scaffold(
        body: Consumer2<ReportController, HomeController>(
          builder: (context, reportCtrl, homeCtrl, child) {
            
            // LOGIC BE: Memanggil fungsi filter yang sudah kita buat di HomeController
            final reports = homeCtrl.filterReports(reportCtrl.reports);
            final unsynced = homeCtrl.getUnsyncedCount(reportCtrl.reports);

            return RefreshIndicator(
              onRefresh: () => reportCtrl.getReports(),
              child: CustomScrollView(
                slivers: [
                  // 1. SEARCH BAR
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        onChanged: (val) => homeCtrl.updateSearchQuery(val),
                        decoration: const InputDecoration(
                          hintText: 'Cari barang...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 2. BANNER DATA LOKAL (Poin 2 Tugasmu)
                  if (unsynced > 0)
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orangeAccent),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            const Icon(Icons.sync_problem, color: Colors.orange),
                            const SizedBox(width: 10),
                            Text(
                              "DATA LOKAL - $unsynced laporan menunggu sinkronisasi",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 3. TAB FILTER (Kehilangan / Penemuan)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTabButton(context, homeCtrl, HomeTab.kehilangan, "KEHILANGAN"),
                          _buildTabButton(context, homeCtrl, HomeTab.penemuan, "PENEMUAN"),
                        ],
                      ),
                    ),
                  ),

                  // 4. LIST BARANG (Poin 3 Tugasmu)
                  if (reportCtrl.state == NotifierState.loading)
                    const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                  else if (reports.isEmpty)
                    const SliverFillRemaining(child: Center(child: Text("Tidak ada laporan ditemukan")))
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = reports[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: item.imageUrl.isNotEmpty 
                                  ? Image.network(item.imageUrl, width: 55, height: 55, fit: BoxFit.cover)
                                  : Container(width: 55, height: 55, color: Colors.grey[300], child: const Icon(Icons.image_not_supported)),
                            ),
                            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(item.location),
                            trailing: item.reward != null 
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text("Reward", style: TextStyle(fontSize: 10, color: Colors.green)),
                                      Text(item.reward!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                    ],
                                  )
                                : null,
                            onTap: () {
                              // POIN 4: LOGIC KLAIM
                              debugPrint("Navigasi ke Klaim barang: ${item.id}");
                            },
                          );
                        },
                        childCount: reports.length,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, HomeController homeCtrl, HomeTab tab, String label) {
    final bool isActive = homeCtrl.activeTab == tab;
    return InkWell(
      onTap: () => homeCtrl.setActiveTab(tab),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isActive ? Colors.blue : Colors.transparent, width: 2)),
        ),
        child: Text(label, style: TextStyle(color: isActive ? Colors.blue : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}