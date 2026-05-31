import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../controllers/claim_controller.dart';
import 'verification_page.dart';

class ClaimQueuePage extends StatefulWidget {
  const ClaimQueuePage({super.key});

  @override
  State<ClaimQueuePage> createState() => _ClaimQueuePageState();
}

class _ClaimQueuePageState extends State<ClaimQueuePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClaimController>().loadClaims();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomHeader(
        title: "Antrean Klaim Barang",
        showBackButton: true,
        onNotificationTap: () {},
      ),
      body: Consumer<ClaimController>(
        builder: (context, controller, child) {
          // ONLY SHOW PENDING CLAIMS IN THE QUEUE
          final pendingClaims = controller.claims.where((c) => c.status == 'pending').toList();

          if (controller.isLoading && pendingClaims.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (pendingClaims.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Antrean Kosong",
                    style: TextStyle(color: Colors.grey[600], fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Belum ada klaim baru yang masuk.",
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadClaims,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingClaims.length,
              itemBuilder: (context, index) {
                return _buildClaimCard(context, pendingClaims[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildClaimCard(BuildContext context, ClaimModel claim) {
    return InkWell(
      onTap: () {
        context.push('/verification', extra: claim);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                image: claim.reportImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(claim.reportImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: claim.reportImageUrl == null
                  ? Icon(Icons.image_outlined, color: Colors.grey[400])
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    claim.reportTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: AppColors.primaryBlue),
                      const SizedBox(width: 4),
                      Text(
                        claim.claimantName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9C4), // Yellow
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "MENUNGGU VERIFIKASI",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 8,
                        color: Color(0xFFF57C00),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
