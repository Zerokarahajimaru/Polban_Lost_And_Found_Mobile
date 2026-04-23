import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';

class CreateReportPage extends StatefulWidget {
  const CreateReportPage({super.key});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  // Menentukan apakah user memilih tab barang "Hilang" atau "Temuan"
  bool isLost = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHeader(title: "Buat Laporan"),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            // Barang Hilang / Temuan
            _buildTabSelector(),
            const SizedBox(height: 24),

            // Upload Photo (Dummy box)
            _buildPhotoPicker(),
            const SizedBox(height: 20),

            const CustomTextField(
              label: "Nama Barang",
              hint: "Misal: KTM atas nama Lu Guang",
              isRequired: true,
            ),

            if (isLost) ...[
              const CustomTextField(
                label: "Nomor WhatsApp (Aktif)",
                hint: "08xxxxxxxxx",
                isRequired: true,
                keyboardType: TextInputType.phone,
              ),
            ],

            const CustomDropdown(
              label: "Kategori",
              items: [
                "Dokumen",
                "Elektronik",
                "Kunci",
                "Dompet",
                "Pakaian",
                "Lainnya",
              ],
              isRequired: true,
            ),
            const CustomTextField(
              label: "Lokasi (Opsional)",
              hint: "Lokasi Terakhir Diingat",
            ),
            const CustomTextField(
              label: "Deskripsi Barang",
              hint: "Detail Ciri Khusus Barang",
              isRequired: true,
              maxLines: 4,
            ),

            // Imbalan (Hanya muncul jika Barang Hilang)
            if (isLost) _buildRewardSection(),

            const SizedBox(height: 30),

            // Tombol Submit
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // Logika submit (data dummy)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Laporan berhasil dibuat (Dummy)"),
                    ),
                  );
                },
                child: const Text(
                  "SUBMIT LAPORAN",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),

      // TOMBOL (+) TENGAH DENGAN TEKS
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min, // Agar column tidak memenuhi layar
        children: [
          FloatingActionButton(
            backgroundColor: AppColors.primaryYellow,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.primaryBlue, width: 4),
            ),
            onPressed: () {
              // Kosongkan atau refresh halaman
            },
            child: const Icon(
              Icons.add,
              color: AppColors.primaryBlue,
              size: 35,
            ),
          ),
          const SizedBox(height: 4), // Jarak antara tombol dan teks
          const Text(
            "Lapor",
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Navigasi Bawah
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: CustomBottomNav(
          currentIndex: 2,
          onTap: (index) {
            // Logika pindah halaman nanti
          },
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBlue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _tabButton(
            "Barang Hilang",
            isLost,
            () => setState(() => isLost = true),
          ),
          _tabButton(
            "Barang Temuan",
            !isLost,
            () => setState(() => isLost = false),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: active ? Border.all(color: AppColors.primaryBlue) : null,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (active)
                  const Icon(
                    Icons.check,
                    color: AppColors.primaryYellow,
                    size: 16,
                  ),
                if (active) const SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(
                    color: active
                        ? AppColors.primaryYellow
                        : AppColors.primaryBlue.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Upload Foto Bukti (Opsional)",
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.secondaryBlue, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 48,
                color: AppColors.secondaryBlue,
              ),
              Text(
                "Foto Kelengkapan",
                style: TextStyle(
                  color: AppColors.secondaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRewardSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryYellow,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.card_giftcard, size: 20, color: AppColors.primaryBlue),
              SizedBox(width: 8),
              Text(
                "Tawarkan Imbalan (Opsional)",
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              hintText: "Misal: Pulsa 50ribu atau makan siang",
              hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 13),
              filled: true,
              fillColor: Colors.white.withOpacity(0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ],
      ),
    );
  }
}
