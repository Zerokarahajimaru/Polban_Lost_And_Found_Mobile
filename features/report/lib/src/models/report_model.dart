import 'package:equatable/equatable.dart';

/// The client-side data model for a Report.
class ReportModel extends Equatable {
  const ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.category, // Added for filtering and categorization
    this.reward,           // Optional: provided if the user offers an incentive
    required this.createdAt,
    required this.status,
    this.localImagePath, // Added for offline image preview
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String location;
  
  /// The category of the reported item (e.g., Electronics, Documents).
  final String category; 
  
  /// The reward offered for the item, if any.
  final String? reward;   
  
  final DateTime createdAt;
  final String status;
  final String? localImagePath; // Path to the image on the local device

  factory ReportModel.fromMap(Map<dynamic, dynamic> map) {
    final imagesList = map['images'] as List<dynamic>? ?? [];
    final title =
        map['title'] as String? ?? map['nama_barang'] as String? ?? 'Tanpa Judul';

    String finalId;
    if (map['_id'] != null) {
      finalId =
          map['_id'] is Map ? map['_id']['\$oid'] as String : map['_id'].toString();
    } else {
      // For pending items, we construct a temporary ID.
      // The key from Hive is the source of truth, but this works for model creation.
      finalId = 'pending_${DateTime.now().millisecondsSinceEpoch}';
    }

    return ReportModel(
      id: finalId,
      title: title,
      description: map['description'] as String? ??
          map['deskripsi_barang'] as String? ??
          '',
      // Use the network URL if available, otherwise it's an empty string.
      imageUrl: imagesList.isNotEmpty ? imagesList.first as String : '',
      location: map['location'] as String? ??
          map['lokasi_kehilangan'] as String? ??
          'Lokasi tidak diketahui',
      category: map['category'] as String? ?? map['kategori_barang'] as String? ?? 'Lainnya',
      reward: map['reward'] as String? ?? map['bounty']?.toString(),
      
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String).toLocal()
          : DateTime.now().toLocal(),
      status:
          map['status'] as String? ?? map['status_postingan'] as String? ?? 'pending',
      // Read the local image path, which only exists for pending items.
      localImagePath: map['local_image_path'] as String?,
    );
  }

  Map<String, dynamic> toPostMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'category': category, // Added for backend consistency
      'reward': reward,     // Optional field for backend
      'status': status,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'images': [imageUrl],
      'location': location,
      'category': category, // Saved locally for filtering
      'reward': reward,     // Saved locally
      'createdAt': createdAt.toIso8601String(),
      'status': status,
      'local_image_path': localImagePath,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        location,
        category,
        reward,
        createdAt,
        status,
        localImagePath,
      ];
}