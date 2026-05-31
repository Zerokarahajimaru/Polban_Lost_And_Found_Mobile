import 'package:flutter/material.dart';
import '../theme/color_service.dart';

class ClaimProgressStepper extends StatelessWidget {
  final String status;

  const ClaimProgressStepper({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    int activeIndex;
    String statusLabel = status.toLowerCase();

    if (statusLabel == 'verified') {
      activeIndex = 2; // Verified/Success
    } else if (statusLabel == 'rejected') {
      activeIndex = -1; // Special case for rejected
    } else {
      activeIndex = 0; // Default: Pending/Submitted
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
            "Progress Klaim",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStep(0, activeIndex, "Diajukan", Icons.send_rounded),
              _buildConnector(0, activeIndex),
              _buildStep(1, activeIndex, "Verifikasi", Icons.admin_panel_settings_rounded),
              _buildConnector(1, activeIndex),
              _buildStep(2, activeIndex, "Selesai", Icons.check_circle_rounded, isRejected: statusLabel == 'rejected'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int index, int activeIndex, String label, IconData icon, {bool isRejected = false}) {
    bool isCompleted = activeIndex >= index;
    bool isCurrent = activeIndex == index;
    Color color;
    
    if (isRejected && index == 2) {
      color = Colors.red;
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
            child: Icon(isRejected && index == 2 ? Icons.cancel_rounded : icon, size: 20, color: color),
          ),
          const SizedBox(height: 8),
          Text(
            isRejected && index == 2 ? "Ditolak" : label,
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
