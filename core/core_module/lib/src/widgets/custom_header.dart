import 'package:flutter/material.dart';
import '../theme/color_service.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback?
      onNotificationTap; // Tambahkan ini agar bisa diklik dari luar

  const CustomHeader({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      elevation: 0,
      centerTitle: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.chevron_left,
                  color: AppColors.primaryYellow, size: 32),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.white,
          fontSize: 20,
        ),
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded,
                  color: AppColors.primaryYellow, size: 28),
              onPressed: onNotificationTap ?? () {}, // Gunakan callback di sini
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                child: const Text('3',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(4),
        child: Container(color: AppColors.primaryYellow, height: 4),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);
}
