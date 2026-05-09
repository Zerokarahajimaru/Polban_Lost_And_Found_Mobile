/// Model untuk laporan postingan (melaporkan post yang tidak sesuai/bermasalah)
class ReportPostModel {
  final String? id; // ID laporan dari server
  final String postId; // ID postingan yang dilaporkan
  final String reporterUserId; // ID user yang melapor
  final String reason; // Alasan pelaporan
  final String description; // Deskripsi detail pelaporan
  final String status; // 'pending', 'reviewed', 'resolved', 'dismissed'
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final List<String>? attachments; // Path atau URL evidence photo/screenshot

  ReportPostModel({
    this.id,
    required this.postId,
    required this.reporterUserId,
    required this.reason,
    required this.description,
    this.status = 'pending',
    required this.createdAt,
    this.resolvedAt,
    this.attachments,
  });

  /// Convert ReportPostModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'reporterUserId': reporterUserId,
      'reason': reason,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'attachments': attachments,
    };
  }

  /// Create ReportPostModel from Map
  factory ReportPostModel.fromMap(Map<String, dynamic> map) {
    return ReportPostModel(
      id: map['id'] as String?,
      postId: map['postId'] as String,
      reporterUserId: map['reporterUserId'] as String,
      reason: map['reason'] as String,
      description: map['description'] as String,
      status: map['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(map['createdAt'] as String),
      resolvedAt: map['resolvedAt'] != null
          ? DateTime.parse(map['resolvedAt'] as String)
          : null,
      attachments: (map['attachments'] as List?)?.cast<String>(),
    );
  }

  /// Create a copy with updated fields
  ReportPostModel copyWith({
    String? id,
    String? postId,
    String? reporterUserId,
    String? reason,
    String? description,
    String? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
    List<String>? attachments,
  }) {
    return ReportPostModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      reporterUserId: reporterUserId ?? this.reporterUserId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      attachments: attachments ?? this.attachments,
    );
  }
}
