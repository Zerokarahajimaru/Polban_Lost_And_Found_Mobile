import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';

class DetailInfoGrid extends StatelessWidget {
  final String kategori;
  final String waktuLapor;

  const DetailInfoGrid({
    super.key,
    required this.kategori,
    required this.waktuLapor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _infoCard("Kategori", kategori, Icons.category_outlined),
        const SizedBox(width: 10),
        _infoCard("Waktu", waktuLapor, Icons.access_time_outlined),
      ],
    );
  }

  Widget _infoCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(border: Border.all(color: AppColors.secondaryBlue.withOpacity(0.5)), borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppColors.secondaryBlue),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textGrey)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue), overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class DetailRewardBanner extends StatelessWidget {
  final String imbalan;

  const DetailRewardBanner({
    super.key,
    required this.imbalan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.primaryYellow, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Imbalan bagi Penemu", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              Text(imbalan, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryBlue)),
            ],
          ),
        ],
      ),
    );
  }
}
