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
        onNotificationTap: () {
          // Placeholder for notification tap
        },
      ),
      body: Consumer<ClaimController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.claims.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.claims.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada antrean klaim",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadClaims,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.claims.length,
              itemBuilder: (context, index) {
                return _buildClaimCard(context, controller.claims[index]);
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
          color: const Color(0xFFF5F5F5), // Light grey
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Left: Image
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
            // Right: Text Details
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
                  Text(
                    claim.claimantName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Badge Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9C4), // Yellow pudar
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      claim.status.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Color(0xFFF57C00), // Orange/Dark Yellow
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}