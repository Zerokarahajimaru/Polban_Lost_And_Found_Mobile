import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';
import 'package:provider/provider.dart';
import 'package:report/report.dart';
import '../controllers/claim_controller.dart';

class VerificationPage extends StatelessWidget {
  final ClaimModel claim;
  const VerificationPage({super.key, required this.claim});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHeader(
        title: "Verifikasi Serah Terima",
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildHeroImage(),
            const SizedBox(height: 20),
            
            const Text(
              "Data Pemohon Klaim",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF424242),
              ),
            ),
            const SizedBox(height: 12),
            _buildDataPemohonCard(),
            
            const SizedBox(height: 32),
            
            const Center(
              child: Text(
                "Pastikan wajah pemohon sesuai dengan KTM/Profil sebelum menyerahkan barang.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
            
            const SizedBox(height: 32),

            Consumer<ClaimController>(
              builder: (context, controller, child) {
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: controller.isLoading 
                      ? null 
                      : () async {
                          final success = await controller.finalizeVerification(claim.id);
                          
                          if (success && context.mounted) {
                            final reportRepo = ReportRepository();
                            try {
                              await reportRepo.updateReportStatus(
                                id: claim.reportId,
                                status: 'resolved',
                                claimantName: claim.claimantName,
                                claimantId: claim.claimantId,
                              );
                              
                              if (context.mounted) {
                                context.read<ReportController>().getReports();
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Klaim diverifikasi & Laporan ditutup."),
                                    backgroundColor: Colors.green,
                                  )
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Berhasil verifikasi klaim, tapi gagal tutup laporan: $e"))
                                );
                              }
                            }
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(controller.message.isNotEmpty ? controller.message : "Gagal memverifikasi klaim."),
                                backgroundColor: Colors.red,
                              )
                            );
                          }
                        },
                    child: controller.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Selesaikan & Tutup Postingan",
                          style: TextStyle(
                            color: AppColors.primaryYellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.softGrey,
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.grey[300],
              width: double.infinity,
              height: double.infinity,
              child: claim.reportImageUrl != null
                ? Image.network(claim.reportImageUrl!, fit: BoxFit.cover)
                : const Icon(Icons.image_outlined, size: 50, color: Colors.grey),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Claim#${claim.id.length > 4 ? claim.id.substring(claim.id.length - 4).toUpperCase() : claim.id.toUpperCase()}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  claim.reportTitle,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataPemohonCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.person, color: AppColors.primaryYellow, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(claim.claimantName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryBlue)),
                  Text(claim.claimantId, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: Colors.grey),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.email, color: Colors.blueAccent, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Email Institusi", style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(claim.claimantEmail, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF424242))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
