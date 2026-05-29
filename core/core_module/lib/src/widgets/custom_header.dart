import 'package:flutter/material.dart';
import '../theme/color_service.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onNotificationTap;
  final Widget? bottomChild;
  final double extraHeight;

  const CustomHeader({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onNotificationTap,
    this.bottomChild,
    this.extraHeight = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.softGrey,
      ),
      child: Stack(
        children: [
          // Yellow accent line at the very bottom of the curve
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60 + extraHeight,
              decoration: const BoxDecoration(
                color: AppColors.primaryYellow,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(44),
                  bottomRight: Radius.circular(44),
                ),
              ),
            ),
          ),
          // Main Blue Header with curve
          Container(
            height: preferredSize.height - 4,
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (showBackButton)
                              IconButton(
                                icon: const Icon(
                                  Icons.chevron_left,
                                  color: AppColors.primaryYellow,
                                  size: 32,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_none_rounded,
                                color: AppColors.primaryYellow,
                                size: 28,
                              ),
                              onPressed: onNotificationTap ?? () {},
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE34234),
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '3',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (bottomChild != null) bottomChild!,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + extraHeight + 40);
}
