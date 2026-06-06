import 'package:flutter/material.dart';
import '../theme/color_service.dart';
import '../theme/theme_service.dart';

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
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
      ),
      child: Stack(
        children: [
          // Yellow accent line (Shadow/Depth effect)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60 + extraHeight,
              decoration: const BoxDecoration(
                color: AppColors.primaryYellow,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(AppTheme.kRadiusLarge * 2),
                  bottomRight: Radius.circular(AppTheme.kRadiusLarge * 2),
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
                bottomLeft: Radius.circular(AppTheme.kRadiusLarge * 1.8),
                bottomRight: Radius.circular(AppTheme.kRadiusLarge * 1.8),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.kPadding,
                      vertical: AppTheme.kPaddingSmall,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              if (showBackButton)
                                IconButton(
                                  icon: const Icon(
                                    Icons.chevron_left_rounded,
                                    color: AppColors.primaryYellow,
                                    size: 32,
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              Flexible(
                                child: Text(
                                  title,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildNotificationIcon(context),
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

  Widget _buildNotificationIcon(BuildContext context) {
    return Stack(
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
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryBlue, width: 1.5),
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
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + extraHeight + 40);
}
