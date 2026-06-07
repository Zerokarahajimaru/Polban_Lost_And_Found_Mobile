import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final bool isRequired;
  final String? value;
  final Function(String?)? onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    this.isRequired = false,
    this.value,
    this.onChanged,
  });

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Dokumen':
        return Icons.description_outlined;
      case 'Elektronik':
        return Icons.devices_outlined;
      case 'Kunci':
        return Icons.vpn_key_outlined;
      case 'Dompet':
        return Icons.account_balance_wallet_outlined;
      case 'Pakaian':
        return Icons.checkroom_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            if (isRequired)
              const Text(" *", style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(15),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryBlue),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: AppColors.secondaryBlue,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 2,
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
          hint: const Text(
            "Pilih Kategori",
            style: TextStyle(color: AppColors.textGrey, fontSize: 14),
          ),
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Row(
                children: [
                  Icon(_getIconForCategory(val), size: 20, color: AppColors.primaryBlue),
                  const SizedBox(width: 12),
                  Text(
                    val,
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}