import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/color_service.dart';
import '../theme/theme_service.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool isRequired;
  final bool obscureText;
  final int maxLines;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.isRequired = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: AppColors.error),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.kPaddingSmall),
        TextField(
          controller: controller,
          maxLines: maxLines,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
          ),
        ),
        const SizedBox(height: AppTheme.kPadding),
      ],
    );
  }
}