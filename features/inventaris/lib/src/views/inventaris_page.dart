import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:core_module/core_module.dart';
import '../controllers/inventaris_controller.dart';
import '../models/inventaris_item.dart';
import 'detail_inventaris_page.dart';

class InventarisPage extends StatefulWidget {
  const InventarisPage({super.key});

  @override
  State<InventarisPage> createState() => _InventarisPageState();
}

class _InventarisPageState extends State<InventarisPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventarisController>().loadInventaris();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softGrey,
      appBar: const CustomHeader(title: 'Inventaris Barang'),

      body: Column(
        children: [
          // ---- SEARCH + FILTER ----
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                // Search Bar
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppColors.secondaryBlue.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) =>
                                context.read<InventarisController>().search(val),
                            decoration: const InputDecoration(
                              hintText: 'Cari barang',
                              hintStyle: TextStyle(
                                  color: AppColors.textGrey, fontSize: 13),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        const Icon(Icons.search,
                            color: AppColors.textGrey, size: 20),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),

          // ---- LIST BARANG ----
          Expanded(
            child: Consumer<InventarisController>(
              builder: (context, controller, _) {
                if (controller.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    ),
                  );
                }

                if (controller.items.isEmpty) {
                  return _buildEmpty();
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 0),
                  itemBuilder: (context, index) {
                    return _buildItemCard(context, controller.items[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ---- FAB ----
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: AppColors.primaryYellow,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.primaryBlue, width: 4),
            ),
            onPressed: () {},
            child: const Icon(Icons.add, color: AppColors.primaryBlue, size: 35),
          ),
          const SizedBox(height: 4),
          const Text(
            'Lapor',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ---- BOTTOM NAV ----
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: CustomBottomNav(
          currentIndex: 1,
          onTap: (index) {},
        ),
      ),
    );
  }

  // ========================
  // WIDGET: KARTU ITEM
  // ========================
  Widget _buildItemCard(BuildContext context, InventarisItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider.value(
              value: context.read<InventarisController>(),
              child: DetailInventarisPage(item: item),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: AppColors.primaryBlue.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryYellow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: item.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.primaryBlue,
                          size: 28,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.inventory_2_outlined,
                      color: AppColors.primaryBlue,
                      size: 28,
                    ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTanggal(item.tanggalMasuk),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),

            // Status Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: item.status == InventarisStatus.finished
                    ? const Color(0xFF2ECC71).withValues(alpha: 0.12)
                    : Colors.grey.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.status == InventarisStatus.finished
                    ? 'Selesai'
                    : 'Nonaktif',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: item.status == InventarisStatus.finished
                      ? const Color(0xFF2ECC71)
                      : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================
  // WIDGET: EMPTY STATE
  // ========================
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined,
              size: 64, color: AppColors.textGrey),
          const SizedBox(height: 12),
          const Text(
            'Belum ada data inventaris',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_searchController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                _searchController.clear();
                context.read<InventarisController>().search('');
              },
              child: const Text('Hapus pencarian'),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTanggal(String raw) {
    try {
      final dt = DateTime.parse(raw);
      const bulan = [
        '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${dt.day} ${bulan[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}
