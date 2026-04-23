import 'package:flutter/material.dart';
import '../theme/color_service.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({required this.currentIndex, required this.onTap});

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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, "Beranda", 0),
          _navItem(Icons.assignment_outlined, "Laporanku", 1),
          const SizedBox(width: 40), // Ruang untuk tombol (+) di tengah
          _navItem(Icons.check_box_outlined, "Klaim", 3),
          _navItem(Icons.person_outline, "Profil", 4),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive
                ? AppColors.primaryYellow
                : Colors.white.withOpacity(0.6),
          ),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? AppColors.primaryYellow
                  : Colors.white.withOpacity(0.6),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
