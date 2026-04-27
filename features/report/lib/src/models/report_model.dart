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
    required this.category,
    this.localImagePath,
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
  final String category;
  final String? localImagePath;
  final String? contact;
  final String? reward;

  factory ReportModel.fromMap(Map<dynamic, dynamic> map) {
    final imagesList = map['images'] as List<dynamic>? ?? [];
    final title = map['title'] as String? ?? map['nama_barang'] as String? ?? 'Tanpa Judul';

    String finalId;
    if (map['_id'] != null) {
      finalId = map['_id'] is Map ? map['_id']['\$oid'] as String : map['_id'].toString();
    } else {
      finalId = 'pending_${DateTime.now().millisecondsSinceEpoch}';
    }

    return ReportModel(
      id: finalId,
      title: title,
      description: map['description'] as String? ?? map['deskripsi_barang'] as String? ?? '',
      imageUrl: imagesList.isNotEmpty ? imagesList.first as String : '',
      location: map['location'] as String? ?? map['lokasi_kehilangan'] as String? ?? 'Lokasi tidak diketahui',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String).toLocal()
          : DateTime.now().toLocal(),
      status: map['status'] as String? ?? map['status_postingan'] as String? ?? 'pending',
      category: map['category'] as String? ?? 'Lainnya',
      localImagePath: map['local_image_path'] as String?,
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
      'category': category,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'images': [imageUrl],
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'local_image_path': localImagePath,
      'contact': contact,
      'reward': reward,
      'category': category,
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
        category,
        localImagePath,
        contact,
        reward,
      ];
}