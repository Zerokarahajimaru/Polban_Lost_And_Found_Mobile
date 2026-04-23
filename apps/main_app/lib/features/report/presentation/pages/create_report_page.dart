import 'dart:io';
import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';
import 'package:image_picker/image_picker.dart';

class CreateReportPage extends StatefulWidget {
  const CreateReportPage({super.key});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  bool isLost = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _rewardController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _selectedCategory;
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryBlue),
              title: const Text("Ambil Foto Kamera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primaryBlue),
              title: const Text("Pilih dari Galeri"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _isFormValid() {
    bool basicValid = _nameController.text.isNotEmpty &&
        _descController.text.isNotEmpty &&
        _selectedCategory != null &&
        _imageFile != null;

    if (isLost) {
      return basicValid && _phoneController.text.isNotEmpty;
    }
    return basicValid;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descController.dispose();
    _rewardController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHeader(title: "Buat Laporan"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            _buildTabSelector(),
            const SizedBox(height: 24),
            _buildPhotoPicker(),
            const SizedBox(height: 20),
            CustomTextField(
              label: "Nama Barang",
              hint: "Misal: KTM atas nama Lu Guang",
              isRequired: true,
              controller: _nameController,
              onChanged: (_) => setState(() {}),
            ),
            if (isLost) ...[
              CustomTextField(
                label: "Nomor WhatsApp (Aktif)",
                hint: "08xxxxxxxxx",
                isRequired: true,
                keyboardType: TextInputType.phone,
                controller: _phoneController,
                onChanged: (_) => setState(() {}),
              ),
            ],
            CustomDropdown(
              label: "Kategori",
              items: const [
                "Dokumen",
                "Elektronik",
                "Kunci",
                "Dompet",
                "Pakaian",
                "Lainnya",
              ],
              isRequired: true,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            CustomTextField(
              label: "Lokasi (Opsional)",
              hint: "Lokasi Terakhir Diingat",
              controller: _locationController,
            ),
            CustomTextField(
              label: "Deskripsi Barang",
              hint: "Detail Ciri Khusus Barang",
              isRequired: true,
              maxLines: 4,
              controller: _descController,
              onChanged: (_) => setState(() {}),
            ),
            if (isLost) _buildRewardSection(),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isFormValid() ? AppColors.primaryBlue : Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
<<<<<<< HEAD
                onPressed: () {
                  // Logika submit (data dummy)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Laporan berhasil dibuat (Dummy)"),
                    ),
                  );
                },
=======
                onPressed: _isFormValid()
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Laporan berhasil dibuat!")));
                      }
                    : null,
>>>>>>> 7231402bef47d7910ac874587a3851df66839908
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: AppColors.primaryYellow,
            shape: const CircleBorder(
              side: BorderSide(color: AppColors.primaryBlue, width: 4),
            ),
<<<<<<< HEAD
            onPressed: () {
              // Kosongkan atau refresh halaman
            },
            child: const Icon(
              Icons.add,
              color: AppColors.primaryBlue,
              size: 35,
            ),
=======
            onPressed: () {},
            child:
                const Icon(Icons.add, color: AppColors.primaryBlue, size: 35),
>>>>>>> 7231402bef47d7910ac874587a3851df66839908
          ),
          const SizedBox(height: 4),
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
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: CustomBottomNav(
          currentIndex: 2,
          onTap: (index) {},
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
<<<<<<< HEAD
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
=======
        const Text("Upload Foto Bukti (Wajib)",
            style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _showPickerOptions,
          child: Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.secondaryBlue, width: 2),
              borderRadius: BorderRadius.circular(15),
              image: _imageFile != null
                  ? DecorationImage(
                      image: FileImage(_imageFile!), fit: BoxFit.cover)
                  : null,
            ),
            child: _imageFile == null
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined,
                          size: 48, color: AppColors.secondaryBlue),
                      Text("Ambil Foto atau dari Galeri",
                          style: TextStyle(
                              color: AppColors.secondaryBlue,
                              fontWeight: FontWeight.bold)),
                    ],
                  )
                : null,
>>>>>>> 7231402bef47d7910ac874587a3851df66839908
          ),
        ),
      ],
    );
  }

  Widget _buildRewardSection() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryYellow,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          const Row(
            children: [
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
            controller: _rewardController,
            decoration: InputDecoration(
              hintText: "Misal: Pulsa 50ribu atau makan siang",
              hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
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