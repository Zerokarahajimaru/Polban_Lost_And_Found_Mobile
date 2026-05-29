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
    return Claim(
      id: map['_id']?.toString() ?? map['id']?.toString(),
      reportId: map['reportId'] as String,
      reportTitle: map['reportTitle'] as String,
      claimantName: map['claimantName'] as String,
      claimantId: map['claimantId'] as String,
      claimantEmail: map['claimantEmail'] as String,
      reportImageUrl: map['reportImageUrl'] as String?,
      status: map['status'] as String,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
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
