import 'dart:io';
import 'package:core_module/core_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:report/src/controllers/report_controller.dart';

class CreateReportProvider extends StatelessWidget {
  final ReportModel? existingReport;
  const CreateReportProvider({super.key, this.existingReport});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportController(),
      child: CreateReportPage(existingReport: existingReport),
    );
  }
}

class CreateReportPage extends StatefulWidget {
  final ReportModel? existingReport;
  const CreateReportPage({super.key, this.existingReport});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  bool isLost = true;
  File? _imageFile;
  String? _selectedCategory;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descController = TextEditingController();
  final _rewardController = TextEditingController();
  final _locationController = TextEditingController();
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final session = context.read<SessionController>();
    if (!session.isTeknisi) {
      isLost = true;
    }

    if (widget.existingReport != null) {
      final report = widget.existingReport!;
      _nameController.text = report.title;
      _descController.text = report.description;
      _locationController.text = report.location;
      _phoneController.text = report.contact ?? '';
      _rewardController.text = report.reward ?? '';
      _selectedCategory = report.category;
      // Only allow Teknisi to edit found items
      isLost = session.isTeknisi ? (report.status != 'found') : true;
    }
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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
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
              leading:
                  const Icon(Icons.photo_library, color: AppColors.primaryBlue),
              title: const Text("Pilih dari Galeri"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              }),
        ]),
      ),
    );
  }

  Future<void> _onFinalize() async {
    final session = context.read<SessionController>();
    if (!session.isTeknisi && !isLost) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Anda tidak memiliki izin untuk membuat laporan barang temuan."),
          backgroundColor: Colors.red));
      return;
    }

    if (!_isFormValid(isFinalizing: true)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Harap isi semua kolom yang wajib diisi (*)"),
          backgroundColor: Colors.red));
      return;
    }

    if (isLost && _phoneController.text.isNotEmpty) {
      final phoneRegex = RegExp(r'^08[0-9]{8,11}$');
      if (!phoneRegex.hasMatch(_phoneController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Nomor WhatsApp tidak valid. Contoh: 081234567890"),
            backgroundColor: Colors.red));
        return;
      }
    }
    
    // Immediately pop the screen to give the user instant feedback.
    Navigator.pop(context, true);

    // Trigger the finalize operation in the background without awaiting it.
    // The previous screen will listen for controller updates and refresh itself.
    context.read<ReportController>().finalizeReport(
      reportData: {
        'title': _nameController.text,
        'description': _descController.text,
        'location': _locationController.text,
        'contact': _phoneController.text,
        'category': _selectedCategory,
        'reward': _rewardController.text,
        'status': isLost ? 'lost' : 'found',
        'createdAt': widget.existingReport?.createdAt.toIso8601String(),
        'imageUrl': widget.existingReport?.imageUrl,
      },
      imageFile: _imageFile,
      existingId: widget.existingReport?.id,
    );
  }

  Future<void> _onSaveDraft() async {
    final session = context.read<SessionController>();
    if (!session.isTeknisi && !isLost) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Anda tidak memiliki izin untuk membuat laporan barang temuan."),
          backgroundColor: Colors.red));
      return;
    }

    if (_nameController.text.isEmpty && _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Isi setidaknya judul atau deskripsi untuk menyimpan draft."),
          backgroundColor: Colors.orange));
      return;
    }

    // Immediately pop the screen to give the user instant feedback.
    Navigator.pop(context, true);

    // Trigger the save operation in the background without awaiting it.
    // The previous screen will listen for controller updates and refresh itself.
    context.read<ReportController>().saveAsDraft(
      reportData: {
        'title': _nameController.text,
        'description': _descController.text,
        'location': _locationController.text,
        'contact': _phoneController.text,
        'category': _selectedCategory,
        'reward': _rewardController.text,
        'status': 'draft',
        'createdAt': widget.existingReport?.createdAt.toIso8601String(),
      },
      localImagePath: _imageFile?.path ?? widget.existingReport?.localImagePath,
      existingId: widget.existingReport?.id,
    );
  }

  bool _isFormValid({bool isFinalizing = false}) {
    bool basicValid = _nameController.text.isNotEmpty &&
        _descController.text.isNotEmpty &&
        _selectedCategory != null;
    if (isFinalizing && widget.existingReport == null) {
      basicValid = basicValid && _imageFile != null;
    }
    if (isLost) {
      return basicValid && _phoneController.text.isNotEmpty;
    }
    return basicValid;
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final isEditing = widget.existingReport != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomHeader(title: isEditing ? "Edit Laporan" : "Buat Laporan"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          children: [
            _buildTabSelector(isEditing: isEditing, isTeknisi: session.isTeknisi),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Text("Nomor WhatsApp (Aktif)",
                        style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                    Text(" *", style: TextStyle(color: Colors.red))
                  ]),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    maxLength: 13,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: "08xxxxxxxxx",
                      counterText: "",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                              color: AppColors.secondaryBlue, width: 2)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
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
                  "Lainnya"
                ],
                value: _selectedCategory,
                isRequired: true,
                onChanged: (value) =>
                    setState(() => _selectedCategory = value)),
            CustomTextField(
                label: "Lokasi (Opsional)",
                hint: "Lokasi Terakhir Diingat",
                controller: _locationController,
                onChanged: (_) => setState(() {})),
            CustomTextField(
                label: "Deskripsi Barang",
                hint: "Detail Ciri Khusus Barang",
                isRequired: true,
                maxLines: 4,
                controller: _descController,
                onChanged: (_) => setState(() {})),
            if (isLost) _buildRewardSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionButtons(false),
    );
  }

  Widget _buildActionButtons(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : _onSaveDraft,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryBlue),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Simpan Draft",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : _onFinalize,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text("Finalisasi & Kirim",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector({required bool isEditing, required bool isTeknisi}) {
    return AbsorbPointer(
      absorbing: isEditing,
      child: Opacity(
        opacity: isEditing ? 0.5 : 1.0,
        child: Container(
            decoration: BoxDecoration(
                color: AppColors.secondaryBlue.withOpacity(0.3),
                borderRadius: BorderRadius.circular(30)),
            child: Row(children: [
              _tabButton("Barang Hilang", isLost,
                  () => setState(() => isLost = true)),
              if (isTeknisi)
                _tabButton("Barang Temuan", !isLost,
                    () => setState(() => isLost = false))
            ])),
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
                    borderRadius: BorderRadius.circular(30)),
                child: Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                      if (active)
                        const Icon(Icons.check,
                            color: AppColors.primaryYellow, size: 16),
                      if (active) const SizedBox(width: 8),
                      Text(text,
                          style: TextStyle(
                              color: active
                                  ? AppColors.primaryYellow
                                  : AppColors.primaryBlue.withOpacity(0.5),
                              fontWeight: FontWeight.bold))
                    ])))));
  }

  Widget _buildPhotoPicker() {
    ImageProvider? imageProvider;
    if (_imageFile != null) {
      imageProvider = FileImage(_imageFile!);
    } else if (widget.existingReport != null) {
      if (widget.existingReport!.localImagePath != null &&
          widget.existingReport!.localImagePath!.isNotEmpty) {
        imageProvider = FileImage(File(widget.existingReport!.localImagePath!));
      } else if (widget.existingReport!.imageUrl.isNotEmpty) {
        imageProvider = NetworkImage(widget.existingReport!.imageUrl);
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(
        children: [
          Text("Upload Foto Bukti",
              style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          Text(" *", style: TextStyle(color: Colors.red)),
        ],
      ),
      const SizedBox(height: 8),
      GestureDetector(
          onTap: _showPickerOptions,
          child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.secondaryBlue, width: 2),
                  borderRadius: BorderRadius.circular(15),
                  image: imageProvider != null
                      ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                      : null),
              child: imageProvider == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                          Icon(Icons.camera_alt_outlined,
                              size: 48, color: AppColors.secondaryBlue),
                          Text("Ambil Foto atau dari Galeri",
                              style: TextStyle(
                                  color: AppColors.secondaryBlue,
                                  fontWeight: FontWeight.bold))
                        ])
                  : null))
    ]);
  }

  Widget _buildRewardSection() {
    return Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppColors.primaryYellow,
            borderRadius: BorderRadius.circular(15)),
        child: Column(children: [
          const Row(children: [
            Icon(Icons.card_giftcard, size: 20, color: AppColors.primaryBlue),
            SizedBox(width: 8),
            Text("Tawarkan Imbalan (Opsional)",
                style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12))
          ]),
          const SizedBox(height: 10),
          TextField(
              controller: _rewardController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                  hintText: "Misal: 50000",
                  hintStyle:
                      const TextStyle(color: AppColors.textGrey, fontSize: 13),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.6),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16)))
        ]));
  }
}
