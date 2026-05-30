import 'package:mongo_dart/mongo_dart.dart';

class Claim {
  final String? id;
  final String reportId;
  final String reportTitle;
  final String claimantName;
  final String claimantId;
  final String claimantEmail;
  final String? reportImageUrl;
  final String status;
  final DateTime createdAt;

  const Claim({
    this.id,
    required this.reportId,
    required this.reportTitle,
    required this.claimantName,
    required this.claimantId,
    required this.claimantEmail,
    this.reportImageUrl,
    required this.status,
    required this.createdAt,
  });

  factory Claim.fromMap(Map<String, dynamic> map) {
    String? idStr;
    final idVal = map['_id'] ?? map['id'];
    if (idVal is ObjectId) {
      idStr = idVal.toHexString();
    } else {
      idStr = idVal?.toString();
    }

    return Claim(
      id: idStr,
      reportId: (map['reportId'] ?? map['report_id'])?.toString() ?? '',
      reportTitle: (map['reportTitle'] ?? map['report_title'])?.toString() ?? '',
      claimantName: (map['claimantName'] ?? map['claimant_name'])?.toString() ?? '',
      claimantId: (map['claimantId'] ?? map['claimant_id'])?.toString() ?? '',
      claimantEmail: (map['claimantEmail'] ?? map['claimant_email'])?.toString() ?? '',
      reportImageUrl: (map['reportImageUrl'] ?? map['report_image_url'])?.toString(),
      status: map['status']?.toString() ?? 'pending',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? map['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
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
