import 'package:flutter/material.dart';
import '../theme/color_service.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isTeknisi;

  const CustomBottomNav({super.key, 
    required this.currentIndex,
    required this.onTap,
    this.isTeknisi = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _navItem(Icons.home_outlined, "Beranda", 0)),
          Expanded(child: _navItem(Icons.assignment_outlined, "Laporanku", 1)),
          const SizedBox(width: 60), // Space for FAB
          if (isTeknisi)
            Expanded(child: _navItem(Icons.check_box_outlined, "Klaim", 3))
          else
            Expanded(child: _navItem(Icons.inventory_2_outlined, "Klaim Saya", 3)),
          Expanded(child: _navItem(Icons.person_outline, "Profil", 4)),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive
                ? AppColors.primaryYellow
                : Colors.white.withOpacity(0.6),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? AppColors.primaryYellow
                  : Colors.white.withOpacity(0.6),
              fontSize: 9, // Slightly smaller to accommodate 5 items nicely
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
