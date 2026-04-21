import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final bool isRequired;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.items,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
            if (isRequired) const Text(" *", style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 2),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
          hint: const Text("Pilih Kategori", style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (newValue) {
            // Logika simpan nilai kategori
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}