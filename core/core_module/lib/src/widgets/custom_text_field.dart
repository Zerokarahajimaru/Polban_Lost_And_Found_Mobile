// core/core_module/lib/src/widgets/custom_text_field.dart
import 'package:flutter/material.dart';
import '../theme/color_service.dart';

class CustomTextField extends StatelessWidget {
  final String label; // Judul di atas input (misal: "Nama Barang")
  final String hint; // Teks abu-abu di dalam input
  final bool isRequired; // Apakah perlu tanda bintang merah (*)
  final int maxLines; // Untuk deskripsi yang butuh baris banyak
  final TextEditingController? controller; // Untuk mengambil data input
  final TextInputType keyboardType; // Misal: phone untuk nomor WA

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.isRequired = false,
    this.maxLines = 1,
    this.controller,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bagian Label dengan penanganan Bintang Merah (*)
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontFamily: 'Montserrat', // Sesuaikan font jika ada
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

        // Input Field
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
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

            // Border saat tidak diklik (halus)
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                  color: AppColors.secondaryBlue.withOpacity(0.5), width: 1.5),
            ),

            // Border saat diklik (lebih tegas)
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide:
                  const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 18), // Spasi antar field
      ],
    );
  }
}
