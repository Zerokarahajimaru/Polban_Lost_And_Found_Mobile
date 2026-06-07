import 'package:flutter/material.dart';
import '../theme/color_service.dart';

class ReportProgressStepper extends StatelessWidget {
  final String status;
  final bool isLost;
  final bool isEdit;

  const ReportProgressStepper({
    super.key, 
    required this.status,
    required this.isLost,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    int activeIndex;
    String statusLabel = status.toLowerCase();

    if (statusLabel == 'resolved') {
      activeIndex = 2; // Selesai
    } else if (statusLabel == 'lost' || statusLabel == 'found') {
      activeIndex = 1; // Mencari/Mengamankan
    } else {
      activeIndex = 0; // Pembuatan (Draft/Pending Sync)
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Status Laporan Anda",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStep(0, activeIndex, isEdit ? "Mengedit" : "Pembuatan", isEdit ? Icons.edit_calendar_rounded : Icons.edit_note_rounded),
              _buildConnector(0, activeIndex),
              _buildStep(1, activeIndex, isLost ? "Mencari" : "Mengamankan", isLost ? Icons.search_rounded : Icons.inventory_rounded),
              _buildConnector(1, activeIndex),
              _buildStep(2, activeIndex, "Selesai", Icons.task_alt_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int index, int activeIndex, String label, IconData icon) {
    bool isCompleted = activeIndex >= index;
    bool isCurrent = activeIndex == index;
    
    // Custom color logic: Step 0 is green when active/completed
    Color color;
    if (index == 0) {
      color = (isCompleted || isCurrent) ? Colors.green : Colors.grey.shade300;
    } else {
      color = isCompleted ? Colors.green : (isCurrent ? AppColors.primaryBlue : Colors.grey.shade300);
    }

    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isCompleted || isCurrent ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector(int index, int activeIndex) {
    bool isCompleted = activeIndex > index;
    return Container(
      width: 20,
      height: 2,
      margin: const EdgeInsets.only(bottom: 18),
      color: isCompleted ? Colors.green : Colors.grey.shade200,
    );
  }
}
