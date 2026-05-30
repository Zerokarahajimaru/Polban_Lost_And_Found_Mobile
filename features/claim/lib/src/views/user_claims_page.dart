import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';
import 'package:provider/provider.dart';
import '../controllers/claim_controller.dart';

class UserClaimsPage extends StatefulWidget {
  const UserClaimsPage({super.key});

  @override
  State<UserClaimsPage> createState() => _UserClaimsPageState();
}

class _UserClaimsPageState extends State<UserClaimsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClaimController>().loadClaims();
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final userId = session.currentUser?.id;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomHeader(
        title: "Klaim Saya",
        showBackButton: false,
      ),
      body: Consumer<ClaimController>(
        builder: (context, controller, child) {
          final myClaims = controller.claims.where((c) => c.claimantId == userId).toList();

          if (controller.isLoading && myClaims.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (myClaims.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text(
                    "Anda belum mengajukan klaim.",
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadClaims,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myClaims.length,
              itemBuilder: (context, index) {
                final claim = myClaims[index];
                return _buildUserClaimCard(claim);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserClaimCard(ClaimModel claim) {
    bool isVerified = claim.status == 'verified';
    bool isRejected = claim.status == 'rejected';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
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
                  ? DecorationImage(image: NetworkImage(claim.reportImageUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: claim.reportImageUrl == null ? const Icon(Icons.image_outlined, color: Colors.grey) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  claim.reportTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Status: ${claim.status.toUpperCase()}",
                  style: TextStyle(
                    color: isVerified ? Colors.green : (isRejected ? Colors.red : Colors.orange),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Diajukan pada: ${claim.createdAt.day}/${claim.createdAt.month}/${claim.createdAt.year}",
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
