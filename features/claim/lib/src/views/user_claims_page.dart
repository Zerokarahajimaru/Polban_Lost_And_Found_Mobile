import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';
import 'package:provider/provider.dart';
import 'package:report/report.dart';
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
    final claimController = context.watch<ClaimController>();
    final myClaims = claimController.claims.where((c) => c.claimantId == userId).toList();

    return Scaffold(
      backgroundColor: AppColors.softGrey,
      appBar: null,
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const CustomHeader(
                title: "Klaim Saya",
                showBackButton: false,
                extraHeight: 60,
              ),
              Positioned(
                bottom: -35,
                left: 20,
                right: 20,
                child: _buildStatsCard(myClaims.length),
              ),
            ],
          ),

          Expanded(
            child: Consumer<ClaimController>(
              builder: (context, controller, child) {
                if (controller.isLoading && myClaims.isEmpty) {
                  return Column(
                    children: [
                      const SizedBox(height: 60),
                      Expanded(child: ShimmerLoading.list(itemCount: 4)),
                    ],
                  );
                }

                if (myClaims.isEmpty) {
                  return _buildEmptyState();
                }

                return Column(
                  children: [
                    const SizedBox(height: 60), 
                    Expanded(
                      child: RefreshIndicator(
                        displacement: 20,
                        onRefresh: controller.loadClaims,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(AppTheme.kPadding, 0, AppTheme.kPadding, 20),
                          itemCount: myClaims.length,
                          itemBuilder: (context, index) {
                            return _buildUserClaimCard(myClaims[index]);
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(int total) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5))
          ]),
      child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColors.primaryYellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15)),
                child: const Icon(Icons.inventory_2_outlined,
                    color: AppColors.primaryBlue)),
            const SizedBox(width: 15),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("TOTAL KLAIM",
                      style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold)),
                  Text("$total Pengajuan",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue))
                ])
          ]),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
          ),
          const SizedBox(height: 24),
          const Text(
            "Belum Ada Klaim",
            style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            "Ajukan klaim pada barang temuan yang\nmungkin milik Anda.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildUserClaimCard(ClaimModel claim) {
    bool isVerified = claim.status == 'verified';
    bool isRejected = claim.status == 'rejected';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportDetailPage(
              item: claim, 
              isFromUserClaim: true,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRejected ? Colors.red.withOpacity(0.03) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isRejected ? Colors.red.withOpacity(0.2) : Colors.white),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
          ]
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.softGrey,
                borderRadius: BorderRadius.circular(15),
                image: claim.reportImageUrl != null && claim.reportImageUrl!.isNotEmpty
                    ? DecorationImage(image: NetworkImage(claim.reportImageUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: claim.reportImageUrl == null || claim.reportImageUrl!.isEmpty ? const Icon(Icons.image_outlined, color: Colors.grey) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    claim.reportTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16,
                      color: isRejected ? Colors.grey : AppColors.primaryBlue,
                      decoration: isRejected ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildStatusBadge(claim.status),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "Diajukan pada: ${claim.createdAt.day}/${claim.createdAt.month}/${claim.createdAt.year}",
                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    
    switch (status.toLowerCase()) {
      case 'verified':
        color = Colors.green;
        text = "DISETUJUI";
        break;
      case 'rejected':
        color = Colors.red;
        text = "DITOLAK";
        break;
      default:
        color = Colors.orange;
        text = "PROSES";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 8, letterSpacing: 0.5),
      ),
    );
  }
}
