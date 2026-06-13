import 'dart:async';
import 'package:flutter/material.dart';
import 'package:core_module/src/theme/color_service.dart';

class NotificationBanner {
  static OverlayEntry? _overlayEntry;
  static Timer? _timer;

  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    if (_overlayEntry != null) {
      _timer?.cancel();
      _overlayEntry?.remove();
      _overlayEntry = null;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => _TopBanner(
        message: message,
        isError: isError,
        onClose: _hide,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    _timer = Timer(const Duration(seconds: 4), () {
      _hide();
    });
  }

  static void _hide() {
    _timer?.cancel();
    if (_overlayEntry != null) {
      // We'll need a GlobalKey to animate the exit, but for now, just remove it.
      // A more advanced solution would use an AnimationController passed to the widget.
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }
}

class _TopBanner extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onClose;

  const _TopBanner({
    required this.message,
    required this.isError,
    required this.onClose,
  });

  @override
  __TopBannerState createState() => __TopBannerState();
}

class __TopBannerState extends State<_TopBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8.0,
      left: 8.0,
      right: 8.0,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: widget.isError ? Colors.red[600] : AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  widget.isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
