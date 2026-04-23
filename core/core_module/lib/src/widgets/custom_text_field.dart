import 'package:flutter/material.dart';
import '../theme/color_service.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool isRequired;
  final int maxLines;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.isRequired = false,
    this.maxLines = 1,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 13,
                fontWeight: FontWeight.w500),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                  color: AppColors.secondaryBlue.withOpacity(0.5), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide:
                  const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}