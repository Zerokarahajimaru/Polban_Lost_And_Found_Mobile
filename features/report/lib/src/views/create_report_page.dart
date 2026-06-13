import 'dart:io';
import 'dart:ui';
import 'package:core_module/core_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:report/src/controllers/report_controller.dart';

class CreateReportProvider extends StatelessWidget {
  final ReportModel? existingReport;
  const CreateReportProvider({super.key, this.existingReport});

  @override
  Widget build(BuildContext context) {
    return CreateReportPage(existingReport: existingReport);
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
  late ReportController _reportController;
  bool _isFinalizing = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descController = TextEditingController();
  final _rewardController = TextEditingController();
  final _locationController = TextEditingController();
  final _picker = ImagePicker();

  final List<Map<String, dynamic>> _categories = [
    {"name": "Dokumen", "icon": Icons.description_outlined},
    {"name": "Elektronik", "icon": Icons.devices_outlined},
    {"name": "Kunci", "icon": Icons.vpn_key_outlined},
    {"name": "Dompet", "icon": Icons.account_balance_wallet_outlined},
    {"name": "Pakaian", "icon": Icons.checkroom_outlined},
    {"name": "Lainnya", "icon": Icons.more_horiz_outlined}
  ];

  @override
  void initState() {
    super.initState();
    _reportController = context.read<ReportController>();
    _reportController.addListener(_handleControllerUpdates);

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
      isLost = session.isTeknisi ? (report.status != 'found') : true;
    }
  }

  void _handleControllerUpdates() {
    if (!mounted) return;
    // General messages not triggered by finalizing can stay here if needed
    // But we clear it to avoid stale messages
    if (_reportController.message.isNotEmpty && !_isFinalizing) {
       _reportController.clearMessage();
    }
  }

  @override
  void dispose() {
    _reportController.removeListener(_handleControllerUpdates);
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
    final currentUser = session.currentUser;
    
    setState(() => _isFinalizing = true);

    try {
      File? imageToFinalize;
      if (_imageFile != null) {
        // [14] Image Compressor before upload
        imageToFinalize = await ImageCompressService.compressImage(_imageFile!);
      } else if (widget.existingReport?.localImagePath != null &&
          widget.existingReport!.localImagePath!.isNotEmpty) {
        imageToFinalize = File(widget.existingReport!.localImagePath!);
      }

      final oldImageExists = widget.existingReport?.imageUrl != null && widget.existingReport!.imageUrl.isNotEmpty;
      if (!_isFormValid(isFinalizing: true, hasImage: imageToFinalize != null || oldImageExists)) {
        // [NOTE] We don't reset _isFinalizing here so error messages stay visible
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Harap lengkapi semua field yang wajib diisi dan unggah foto."),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      await context.read<ReportController>().finalizeReport(
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
        imageFile: imageToFinalize,
        existingId: widget.existingReport?.id,
        userId: currentUser?.id,
      );

      if (mounted) {
        final failed = _reportController.lastOperationFailed;
        final msg = _reportController.message;
        if (!failed) {
          _isFinalizing = false;
          _reportController.clearMessage();
          final session = context.read<SessionController>();

          StatusDialog.show(
            context,
            title: "Berhasil!",
            confirmLabel: "OK",
            message: "Laporan anda telah berhasil dibuat dan simpan di database",
            onConfirm: () {
              if (session.isTeknisi) {
                context.go('/teknisi-home');
              } else {
                context.go('/my-reports');
              }
            },
          );
        } else {
          StatusDialog.show(
            context,
            isSuccess: false,
            title: "Gagal",
            message: msg,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFinalizing = false);
        StatusDialog.show(
          context,
          isSuccess: false,
          title: "Error",
          message: "Terjadi kesalahan saat memproses laporan: $e",
        );
      }
    }
  }

  Future<void> _onSaveDraft() async {
    final session = context.read<SessionController>();
    final currentUser = session.currentUser;

    if (_nameController.text.isEmpty && _descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Isi setidaknya judul atau deskripsi untuk menyimpan draft."),
          backgroundColor: Colors.orange));
      return;
    }

    String? finalLocalImagePath = _imageFile?.path ?? widget.existingReport?.localImagePath;

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
        'imageUrl': '',
      },
      localImagePath: finalLocalImagePath,
      existingId: widget.existingReport?.id,
      userId: currentUser?.id,
    );
    
    StatusDialog.show(
      context,
      title: "Draft Disimpan",
      message: "Laporan Anda telah disimpan sebagai draft.",
      onConfirm: () => Navigator.pop(context),
    );
  }

  bool _isFormValid({bool isFinalizing = false, bool hasImage = false}) {
    bool basicValid = _nameController.text.isNotEmpty &&
        _descController.text.isNotEmpty &&
        _selectedCategory != null;
    if (isFinalizing) {
      basicValid = basicValid && hasImage;
    }
    if (isLost) {
      final phone = _phoneController.text;
      return basicValid && phone.length >= 4 && phone.length <= 18;
    }
    return basicValid;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = context.watch<SessionController>();
    final isEditing = widget.existingReport != null;
    final controller = context.watch<ReportController>();
    final isLoading = controller.isLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomHeader(title: isEditing ? "Edit Laporan" : "Buat Laporan"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.kPadding,
          AppTheme.kPadding,
          AppTheme.kPadding,
          120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabSelector(isEditing: isEditing, isTeknisi: session.isTeknisi),
            const SizedBox(height: AppTheme.kPaddingLarge),
            ReportProgressStepper(
              status: 'draft', 
              isLost: isLost,
              isEdit: isEditing,
            ),
            const SizedBox(height: AppTheme.kPaddingLarge),
            _buildPhotoPicker(),
            const SizedBox(height: AppTheme.kPaddingLarge),
            
            CustomTextField(
              label: "Nama Barang",
              hint: "Misal: KTM atas nama Lu Guang",
              isRequired: true,
              controller: _nameController,
              onChanged: (_) => setState(() {}),
            ),
            if (_isFinalizing && _nameController.text.isEmpty) _buildErrorText("Judul laporan wajib diisi"),

            if (isLost) ...[
              CustomTextField(
                label: "Nomor WhatsApp (Aktif)",
                hint: "Contoh: +628123456789 atau 08123456789",
                isRequired: true,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\+?[0-9]*')),
                  LengthLimitingTextInputFormatter(18),
                ],
                onChanged: (_) => setState(() {}),
              ),
              if (_isFinalizing && (_phoneController.text.length < 4 || _phoneController.text.length > 18)) 
                _buildErrorText("Nomor WhatsApp harus 4-18 karakter"),
            ],

            _buildLabel("Kategori", isRequired: true),
            _buildCategoryChips(),
            if (_isFinalizing && _selectedCategory == null) _buildErrorText("Silakan pilih kategori barang"),
            const SizedBox(height: AppTheme.kPadding),

            CustomTextField(
              label: "Lokasi Terakhir (Opsional)",
              hint: "Misal: Kantin atau Gedung P",
              controller: _locationController,
              onChanged: (_) => setState(() {}),
            ),
            
            CustomTextField(
              label: "Deskripsi Barang",
              hint: "Contoh: Casing warna biru, ada stiker kucing.",
              isRequired: true,
              maxLines: 4,
              controller: _descController,
              onChanged: (_) => setState(() {}),
            ),
            if (_isFinalizing && _descController.text.isEmpty) _buildErrorText("Deskripsi wajib diisi"),
            
            if (isLost) _buildRewardSection(),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionButtons(isLoading),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.kPaddingSmall),
      child: Row(
        children: [
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isRequired)
            const Text(
              " *",
              style: TextStyle(color: AppColors.error),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: AppTheme.kPaddingSmall),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final theme = Theme.of(context);
    return Wrap(
      spacing: AppTheme.kPaddingSmall,
      runSpacing: AppTheme.kPaddingSmall,
      children: _categories.map((cat) {
        final isSelected = _selectedCategory == cat["name"];
        return ChoiceChip(
          avatar: Icon(cat["icon"], 
            size: 16, 
            color: isSelected ? Colors.white : AppColors.primaryBlue
          ),
          label: Text(cat["name"]),
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _selectedCategory = selected ? cat["name"] : null);
          },
          selectedColor: AppColors.primaryBlue,
          labelStyle: theme.textTheme.labelSmall?.copyWith(
            color: isSelected ? Colors.white : AppColors.primaryBlue,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.kRadiusLarge),
            side: BorderSide(
              color: isSelected ? AppColors.primaryBlue : AppColors.mediumGrey,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.kPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : _onSaveDraft,
              child: const Text("DRAFT"),
            ),
          ),
          const SizedBox(width: AppTheme.kPadding),
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading ? null : _onFinalize,
              child: isLoading
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text("KIRIM"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector({required bool isEditing, required bool isTeknisi}) {
    return AbsorbPointer(
      absorbing: isEditing,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.mediumGrey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppTheme.kRadiusLarge),
        ),
        child: Row(
          children: [
            _tabButton("KEHILANGAN", isLost, () => setState(() => isLost = true)),
            if (isTeknisi)
              _tabButton("PENEMUAN", !isLost, () => setState(() => isLost = false))
          ],
        ),
      ),
    );
  }

  Widget _tabButton(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.kRadiusLarge),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: active ? AppColors.primaryYellow : AppColors.textGrey,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
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

    final hasError = (_imageFile == null && 
        (widget.existingReport?.imageUrl.isEmpty ?? true) && 
        (widget.existingReport?.localImagePath?.isEmpty ?? true)) && _isFinalizing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel("Upload Foto Bukti", isRequired: true),
        GestureDetector(
          onTap: _showPickerOptions,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.softGrey,
              border: Border.all(
                color: hasError ? AppColors.error : AppColors.mediumGrey, 
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(AppTheme.kRadius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.kRadius - 2),
              child: imageProvider != null
                  ? Stack(
                      children: [
                        Positioned.fill(child: Image(image: imageProvider, fit: BoxFit.cover)),
                        Positioned.fill(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(color: Colors.black.withOpacity(0.1)),
                          ),
                        ),
                        Center(child: Image(image: imageProvider, fit: BoxFit.contain)),
                        Positioned(
                          right: AppTheme.kPaddingSmall,
                          top: AppTheme.kPaddingSmall,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(Icons.edit_rounded, color: AppColors.primaryBlue, size: 18),
                              onPressed: _showPickerOptions,
                            ),
                          ),
                        )
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined, 
                          size: 40, 
                          color: hasError ? AppColors.error : AppColors.textGrey
                        ),
                        const SizedBox(height: AppTheme.kPaddingSmall),
                        Text(
                          "Ambil Foto Barang",
                          style: TextStyle(
                            color: hasError ? AppColors.error : AppColors.textGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
            ),
          ),
        ),
        if (hasError) _buildErrorText("Foto barang wajib diunggah"),
      ],
    );
  }

  Widget _buildRewardSection() {
    return Container(
      margin: const EdgeInsets.only(top: AppTheme.kPadding),
      padding: const EdgeInsets.all(AppTheme.kPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryYellow.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.kRadius),
        border: Border.all(color: AppColors.primaryYellow.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.card_giftcard_rounded, size: 20, color: AppColors.primaryBlue),
              SizedBox(width: AppTheme.kPaddingSmall),
              Text(
                "Tawarkan Imbalan (Opsional)",
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              )
            ],
          ),
          const SizedBox(height: AppTheme.kPaddingSmall),
          TextField(
            controller: _rewardController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: "Misal: 50000",
              fillColor: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
