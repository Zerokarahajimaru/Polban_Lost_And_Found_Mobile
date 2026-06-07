import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/color_service.dart';
import '../theme/theme_service.dart';
import '../controllers/session_controller.dart';
import '../controllers/notification_controller.dart';

class CustomHeader extends StatefulWidget implements PreferredSizeWidget {
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
  State<CustomHeader> createState() => _CustomHeaderState();

  @override
  Size get preferredSize {
    // kToolbarHeight is usually 56. 
    // We add safe area padding (handled automatically by PreferredSize inside an AppBar, but here we estimate)
    // + extraHeight for search bar + bottom shadow peek
    return Size.fromHeight(kToolbarHeight + extraHeight + 20); 
  }
}

class _CustomHeaderState extends State<CustomHeader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialNotifications();
    });
  }

  void _loadInitialNotifications() {
    if (!mounted) return;
    final session = context.read<SessionController>();
    context.read<NotificationController>().loadNotificationsForUser(session);
  }

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
              height: 40, // Fixed small height just to peek out at the bottom
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
            margin: const EdgeInsets.only(bottom: 4), // Leave space for yellow shadow
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
                mainAxisSize: MainAxisSize.min, // Wrap content tightly
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
                              if (widget.showBackButton)
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
                                  widget.title,
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
                  if (widget.bottomChild != null) widget.bottomChild!,
                  // ADDED: Provide actual vertical space based on extraHeight
                  if (widget.extraHeight > 0 && widget.bottomChild == null) 
                    SizedBox(height: widget.extraHeight),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return Consumer<NotificationController>(
      builder: (context, controller, child) {
        final count = controller.unreadCount;
        
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.primaryYellow,
                size: 28,
              ),
              onPressed: widget.onNotificationTap ?? () {},
            ),
            if (count > 0)
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
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    count > 9 ? '9+' : count.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
