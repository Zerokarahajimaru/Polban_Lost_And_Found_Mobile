import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/color_service.dart';
import '../theme/theme_service.dart';

class StatusDialog extends StatelessWidget {
  final String title;
  final String message;
  final bool isSuccess;
  final VoidCallback? onConfirm;

  const StatusDialog({
    super.key,
    required this.title,
    required this.message,
    this.isSuccess = true,
    this.onConfirm,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    bool isSuccess = true,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatusDialog(
        title: title,
        message: message,
        isSuccess: isSuccess,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.kRadiusLarge),
      ),
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.kPaddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              isSuccess
                  ? 'https://assets10.lottiefiles.com/packages/lf20_afwjhign.json'
                  : 'https://assets10.lottiefiles.com/packages/lf20_ghunp9cd.json',
              height: 120,
              repeat: false,
            ),
            const SizedBox(height: AppTheme.kPadding),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: isSuccess ? AppColors.primaryBlue : AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.kPaddingSmall),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: AppTheme.kPaddingLarge),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSuccess ? AppColors.primaryBlue : AppColors.error,
              ),
              onPressed: () {
                Navigator.pop(context);
                if (onConfirm != null) onConfirm!();
              },
              child: const Text("MENGERTI"),
            ),
          ],
        ),
      ),
    );
  }
}
