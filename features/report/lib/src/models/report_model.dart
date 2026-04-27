import 'package:equatable/equatable.dart';

class ReportModel extends Equatable {
  const ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.createdAt,
    required this.status,
    this.contact,
    this.reward,
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String location;
  final DateTime createdAt;
  final String status;
  final String? contact;
  final String? reward;

  factory ReportModel.fromMap(Map<dynamic, dynamic> map) {
    String finalId;
    if (map['_id'] != null) {
      finalId = map['_id'] is Map ? map['_id']['\$oid'] as String : map['_id'] as String;
    } else {
      finalId = 'pending_${DateTime.now().millisecondsSinceEpoch}';
    }

    return ReportModel(
      id: finalId,
      title: map['title'] as String? ?? 'Tanpa Judul',
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      location: map['location'] as String? ?? 'Lokasi tidak diketahui',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String).toLocal()
          : DateTime.now().toLocal(),
      status: map['status'] as String? ?? 'pending',
      contact: map['contact'] as String?,
      reward: map['reward'] as String?,
    );
  }

  Map<String, dynamic> toPostMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'status': status,
      'contact': contact,
      'reward': reward,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'contact': contact,
      'reward': reward,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        location,
        createdAt,
        status,
        contact,
        reward,
      ];
}