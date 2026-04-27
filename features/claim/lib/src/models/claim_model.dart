import 'package:equatable/equatable.dart';

class ClaimModel extends Equatable {
  const ClaimModel({
    required this.id,
    required this.reportId,    // ID barang yang mau diklaim
    required this.userId,      // ID user yang mengklaim
    required this.description, // Alasan/bukti deskriptif
    required this.status,      // pending, approved, rejected
    this.proofImageUrl,        // Opsional: Foto bukti kepemilikan
    required this.createdAt,
  });

  final String id;
  final String reportId;
  final String userId;
  final String description;
  final String status;
  final String? proofImageUrl;
  final DateTime createdAt;

  factory ClaimModel.fromMap(Map<String, dynamic> map) {
    return ClaimModel(
      id: map['_id'] is Map ? map['_id']['\$oid'] as String : map['_id'] as String,
      reportId: map['reportId'] as String,
      userId: map['userId'] as String,
      description: map['description'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      proofImageUrl: map['proofImageUrl'] as String?,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt'] as String).toLocal()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toPostMap() {
    return {
      'reportId': reportId,
      'userId': userId,
      'description': description,
      'status': status,
      'proofImageUrl': proofImageUrl,
    };
  }

  @override
  List<Object?> get props => [id, reportId, userId, description, status, proofImageUrl, createdAt];
}