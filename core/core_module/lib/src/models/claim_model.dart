import 'package:core_module/core_module.dart';

class ClaimModel {
  final String id;
  final String reportId;
  final String reportTitle;
  final String claimantName;
  final String claimantId; // NIM
  final String claimantEmail;
  final String? reportImageUrl;
  final String status; // 'pending', 'verified', 'rejected'
  final DateTime createdAt;

  const ClaimModel({
    required this.id,
    required this.reportId,
    required this.reportTitle,
    required this.claimantName,
    required this.claimantId,
    required this.claimantEmail,
    this.reportImageUrl,
    required this.status,
    required this.createdAt,
  });

  factory ClaimModel.fromJson(Map<String, dynamic> json) {
    String rawId = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    
    // Normalize ObjectId("...") to just "..."
    if (rawId.startsWith('ObjectId("') && rawId.endsWith('")')) {
      rawId = rawId.substring(10, rawId.length - 2);
    }

    return ClaimModel(
      id: rawId,
      reportId: json['reportId']?.toString() ?? '',
      reportTitle: json['reportTitle']?.toString() ?? '',
      claimantName: json['claimantName']?.toString() ?? '',
      claimantId: json['claimantId']?.toString() ?? '',
      claimantEmail: json['claimantEmail']?.toString() ?? '',
      reportImageUrl: json['reportImageUrl']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'reportTitle': reportTitle,
      'claimantName': claimantName,
      'claimantId': claimantId,
      'claimantEmail': claimantEmail,
      'reportImageUrl': reportImageUrl,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
