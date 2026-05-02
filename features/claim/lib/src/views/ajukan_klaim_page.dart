import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';
import 'package:provider/provider.dart';
import '../controllers/claim_controller.dart';
import '../models/claim_model.dart';
import '../repositories/claim_repository.dart';

// ========================
// HALAMAN AJUKAN KLAIM - PROVIDER WRAPPER
// ========================
class AjukanKlaimPageProvider extends StatelessWidget {
  final String reportId;

  const AjukanKlaimPageProvider({
    required this.reportId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClaimController(
        repository: ClaimRepository(), // Pastikan repository sudah tersedia
      ),
      child: AjukanKlaimPage(reportId: reportId),
    );
  }
}

// ========================
// HALAMAN AJUKAN KLAIM
// ========================
class AjukanKlaimPage extends StatefulWidget {
  final String reportId;

  const AjukanKlaimPage({
    required this.reportId,
    super.key,
  });

  @override
  State<AjukanKlaimPage> createState() => _AjukanKlaimPageState();
}

class _AjukanKlaimPageState extends State<AjukanKlaimPage> {
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  @override
  void dispose() {
    _whatsappController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClaimController>(
      builder: (context, claimController, child) {
        return Scaffold(
          backgroundColor: Colors.white,

          // ---- APP BAR ----
          appBar: const CustomHeader(title: 'Ajukan Klaim'),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner Bukti Kepemilikan
                _buildBuktiBanner(),
                const SizedBox(height: 24),

                // Input Nomor WhatsApp
                CustomTextField(
                  controller: _whatsappController,
                  label: 'Nomor WhatsApp (Aktif)',
                  hint: '08xxxxxxxxx',
                  isRequired: true,
                  keyboardType: TextInputType.phone,
                ),

                // Input Deskripsi Bukti
                CustomTextField(
                  controller: _deskripsiController,
                  label: 'Deskripsi Bukti (Ciri Khusus)',
                  hint: 'Contoh: Ada retakan di pojok kanan bawah, berwarna biru muda',
                  isRequired: true,
                  maxLines: 5,
                ),

                // Upload Foto Bukti
                _buildLabel('Upload Foto Bukti (Opsional)', required: false),
                const SizedBox(height: 8),
                _buildPhotoPicker(),
                const SizedBox(height: 28),

                // Tombol Ajukan
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: claimController.state == ClaimState.loading
                        ? null
                        : () async {
                            // Validasi input
                            if (_whatsappController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Nomor WhatsApp harus diisi'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (_deskripsiController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Deskripsi bukti harus diisi'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            // Buat model claim
                            final claim = ClaimModel(
                              id: '', // Backend akan generate ID
                              reportId: widget.reportId,
                              userId: '', // TODO: Ambil dari user session
                              description: _deskripsiController.text,
                              status: 'pending',
                              proofImageUrl: null, // TODO: Upload foto jika ada
                              createdAt: DateTime.now(),
                            );

                            // Submit claim
                            final isSuccess = await claimController.sendClaim(claim);

                            if (isSuccess) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Row(
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: Colors.white, size: 20),
                                        SizedBox(width: 10),
                                        Text(
                                          'Pengajuan berhasil dikirimkan',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: AppColors.primaryBlue,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 16),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                                // Reset form
                                _whatsappController.clear();
                                _deskripsiController.clear();
                                // Navigasi kembali setelah 2 detik
                                Future.delayed(const Duration(seconds: 2), () {
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                });
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(claimController.errorMessage),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    child: claimController.state == ClaimState.loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primaryYellow),
                            ),
                          )
                        : const Text(
                            'Ajukan',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryYellow,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),
                  ),
                ),

                // Ruang untuk FAB
                const SizedBox(height: 100),
              ],
            ),
          ),

          // ---- FAB ----
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                backgroundColor: AppColors.primaryYellow,
                shape: const CircleBorder(
                  side: BorderSide(color: AppColors.primaryBlue, width: 4),
                ),
                onPressed: () {},
                child: const Icon(Icons.add, color: AppColors.primaryBlue, size: 35),
              ),
              const SizedBox(height: 4),
              const Text(
                'Lapor',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

          // ---- BOTTOM NAV ----
          bottomNavigationBar: BottomAppBar(
            padding: EdgeInsets.zero,
            notchMargin: 8,
            shape: const CircularNotchedRectangle(),
            child: CustomBottomNav(
              currentIndex: 3, // Tab Klaim aktif
              onTap: (index) {},
            ),
          ),
        );
      },
    );
  }

  // ========================
  // WIDGET: BANNER BUKTI KEPEMILIKAN
  // ========================
  Widget _buildBuktiBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon shield kuning
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primaryYellow, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: AppColors.primaryYellow,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BUKTI KEPEMILIKAN',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Data ini akan diteruskan ke teknisi.\nHarap masukkan nomor WA aktif!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========================
  // WIDGET: LABEL FIELD
  // ========================
  Widget _buildLabel(String text, {required bool required}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppColors.primaryBlue,
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
      ],
    );
  }

  // ========================
  // WIDGET: PHOTO PICKER
  // ========================
  Widget _buildPhotoPicker() {
    return GestureDetector(
      onTap: () {
        // Logika buka galeri / kamera
      },
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: AppColors.secondaryBlue,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              color: AppColors.secondaryBlue,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'Foto Kelengkapan',
              style: TextStyle(
                color: AppColors.secondaryBlue,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}