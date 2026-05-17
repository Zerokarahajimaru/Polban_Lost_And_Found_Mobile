import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/admin_stat_controller.dart';

class AdminStatPage extends StatefulWidget {
  const AdminStatPage({super.key});

  @override
  State<AdminStatPage> createState() => _AdminStatPageState();
}

class _AdminStatPageState extends State<AdminStatPage> {
  @override
  void initState() {
    super.initState();
    // Tarik data dari backend pas halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminStatController>().fetchAdminStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminStatController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Analitik Admin'),
        backgroundColor: const Color(0xff1a237e),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchAdminStats(),
        child: _buildBody(controller),
      ),
    );
  }

  Widget _buildBody(AdminStatController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null) {
      return Center(
        child: Text(
          controller.errorMessage!,
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }

    final stats = controller.statsData;
    if (stats == null) {
      return const Center(child: Text('Tidak ada data statistik.'));
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Aktivitas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff0d47a1)),
          ),
          const SizedBox(height: 12),
          
          // Grid Angka Ringkasan
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildStatCard('Total Laporan', stats.totalReports.toString(), Icons.assignment, Colors.blue),
              _buildStatCard('Kehilangan (Lost)', stats.totalLost.toString(), Icons.search_off, Colors.amber.shade800),
              _buildStatCard('Temuan (Found)', stats.foundReports.toString(), Icons.explore, Colors.teal),
              _buildStatCard('Kasus Selesai', stats.totalClaimed.toString(), Icons.check_circle, Colors.green),
            ],
          ),
          const SizedBox(height: 28),

          const Text(
            'Distribusi Kategori Barang',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff0d47a1)),
          ),
          const SizedBox(height: 12),
          
          // Grafik Kategori
          _buildCategoryChart(stats.reportsByCategory, stats.totalReports),
          const SizedBox(height: 28),

          const Text(
            'Hotspot Lokasi Kehilangan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff0d47a1)),
          ),
          const SizedBox(height: 12),
          
          // Daftar Lokasi Rawan
          _buildLocationList(stats.reportsByLocation),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.bold)),
                Icon(icon, color: color.withOpacity(0.7), size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(Map<String, int> categories, int total) {
    if (categories.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Belum ada data kategori.')));
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: categories.entries.map((entry) {
            final double percentage = total > 0 ? entry.value / total : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${entry.value} item (${(percentage * 100).toStringAsFixed(1)}%)', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey.shade200,
                    color: const Color(0xff1a237e),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLocationList(Map<String, int> locations) {
    if (locations.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(16.0), child: Text('Belum ada data lokasi.')));
    }

    final sortedLocations = locations.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedLocations.length > 5 ? 5 : sortedLocations.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = sortedLocations[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
              radius: 14,
              child: Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            title: Text(entry.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text('${entry.value} Kasus', style: TextStyle(color: Colors.red.shade900, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}