import 'dart:io';

import 'package:core_module/core_module.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:report/src/controllers/report_controller.dart';

// Wrap the original page in a provider
class CreateReportProvider extends StatelessWidget {
  const CreateReportProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportController(),
      child: const CreateReportPage(),
    );
  }
}

class CreateReportPage extends StatefulWidget {
  const CreateReportPage({super.key});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  // UI-specific state remains here
  bool isLost = true;
  File? _imageFile;
  String? _selectedCategory;

  // Text controllers are part of the view's state
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descController = TextEditingController();
  final _rewardController = TextEditingController();
  final _locationController = TextEditingController();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Listen to controller state changes to show snackbars
    final controller = context.read<ReportController>();
    controller.addListener(_handleStateChanges);
  }

  void _handleStateChanges() {
    final controller = context.read<ReportController>();
    if (controller.state == NotifierState.error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(controller.message)));
    } else if (controller.message == 'Laporan berhasil dibuat!') {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(controller.message)));
      _clearForm();
    }
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _descController.clear();
    _rewardController.clear();
    _locationController.clear();
    setState(() {
      _imageFile = null;
      _selectedCategory = null;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => SafeArea(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                ListTile(
                    leading: const Icon(Icons.camera_alt, color: AppColors.primaryBlue),
                    title: const Text("Ambil Foto Kamera"),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    }),
                ListTile(
                    leading: const Icon(Icons.photo_library, color: AppColors.primaryBlue),
                    title: const Text("Pilih dari Galeri"),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    }),
              ]),
            ));
  }

  Future<void> _submitLaporan() async {
    if (!_isFormValid()) return;
    
    context.read<ReportController>().createReport(
          title: _nameController.text,
          description: _descController.text,
          location: _locationController.text,
          contact: _phoneController.text,
          category: _selectedCategory!,
          imageFile: _imageFile!,
          reward: _rewardController.text,
          status: isLost ? 'lost' : 'found',
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
    context.read<ReportController>().removeListener(_handleStateChanges);
    _nameController.dispose();
    _phoneController.dispose();
    _descController.dispose();
    _rewardController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the controller's state for UI changes
    final controller = context.watch<ReportController>();
    final isLoading = controller.state == NotifierState.loading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHeader(title: "Buat Laporan"),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                    onChanged: (_) => setState(() {})),
                if (isLost) ...[
                  CustomTextField(
                      label: "Nomor WhatsApp (Aktif)",
                      hint: "08xxxxxxxxx",
                      isRequired: true,
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                      onChanged: (_) => setState(() {})),
                ],
                CustomDropdown(
                    label: "Kategori",
                    items: const ["Dokumen", "Elektronik", "Kunci", "Dompet", "Pakaian", "Lainnya"],
                    isRequired: true,
                    onChanged: (value) => setState(() => _selectedCategory = value)),
                CustomTextField(
                    label: "Lokasi (Opsional)",
                    hint: "Lokasi Terakhir Diingat",
                    controller: _locationController),
                CustomTextField(
                    label: "Deskripsi Barang",
                    hint: "Detail Ciri Khusus Barang",
                    isRequired: true,
                    maxLines: 4,
                    controller: _descController,
                    onChanged: (_) => setState(() {})),
                if (isLost) _buildRewardSection(),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _isFormValid() ? AppColors.primaryBlue : Colors.grey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    onPressed: _isFormValid() && !isLoading ? _submitLaporan : null,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("SUBMIT LAPORAN",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          // Modal loading indicator
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      controller.message,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
              backgroundColor: AppColors.primaryYellow,
              shape: const CircleBorder(side: BorderSide(color: AppColors.primaryBlue, width: 4)),
              onPressed: () {},
              child: const Icon(Icons.add, color: AppColors.primaryBlue, size: 35)),
          const SizedBox(height: 4),
          const Text("Lapor",
              style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
          padding: EdgeInsets.zero,
          notchMargin: 8,
          shape: const CircularNotchedRectangle(),
          child: CustomBottomNav(currentIndex: 2, onTap: (index) {})),
    );
  }

  // ---UNCHANGED UI HELPER WIDGETS---
  Widget _buildTabSelector() {
    return Container(
        decoration: BoxDecoration(
            color: AppColors.secondaryBlue.withOpacity(0.3),
            borderRadius: BorderRadius.circular(30)),
        child: Row(children: [
          _tabButton("Barang Hilang", isLost, () => setState(() => isLost = true)),
          _tabButton("Barang Temuan", !isLost, () => setState(() => isLost = false)),
        ]));
  }

  Widget _tabButton(String text, bool active, VoidCallback onTap) {
    return Expanded(
        child: GestureDetector(
            onTap: onTap,
            child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                    color: active ? AppColors.primaryBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(30)),
                child: Center(
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  if (active) const Icon(Icons.check, color: AppColors.primaryYellow, size: 16),
                  if (active) const SizedBox(width: 8),
                  Text(text,
                      style: TextStyle(
                          color:
                              active ? AppColors.primaryYellow : AppColors.primaryBlue.withOpacity(0.5),
                          fontWeight: FontWeight.bold)),
                ])))));
  }

  Widget _buildPhotoPicker() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Upload Foto Bukti (Wajib)",
          style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
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
                      ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                      : null),
              child: _imageFile == null
                  ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.camera_alt_outlined, size: 48, color: AppColors.secondaryBlue),
                      Text("Ambil Foto atau dari Galeri",
                          style: TextStyle(color: AppColors.secondaryBlue, fontWeight: FontWeight.bold))
                    ])
                  : null))
    ]);
  }

  Widget _buildRewardSection() {
    return Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(16),
        decoration:
            BoxDecoration(color: AppColors.primaryYellow, borderRadius: BorderRadius.circular(15)),
        child: Column(children: [
          const Row(children: [
            Icon(Icons.card_giftcard, size: 20, color: AppColors.primaryBlue),
            SizedBox(width: 8),
            Text("Tawarkan Imbalan (Opsional)",
                style: TextStyle(
                    color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12))
          ]),
          const SizedBox(height: 10),
          TextField(
              controller: _rewardController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  hintText: "Misal: 50000",
                  hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 13),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.6),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16)))
        ]));
  }
}