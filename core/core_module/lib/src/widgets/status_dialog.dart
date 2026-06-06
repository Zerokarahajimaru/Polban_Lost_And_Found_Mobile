import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/color_service.dart';

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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.network(
              isSuccess
                  ? 'https://assets10.lottiefiles.com/packages/lf20_afwjhign.json' // Success checkmark
                  : 'https://assets10.lottiefiles.com/packages/lf20_ghunp9cd.json', // Error cross
              height: 120,
              repeat: false,
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  if (onConfirm != null) onConfirm!();
                },
                child: const Text(
                  "OK",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
