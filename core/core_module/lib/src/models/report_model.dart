class ReportModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String? contact;
  final String? reward;
  final String status;
  final String imageUrl;
  final String? localImagePath;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    this.contact,
    this.reward,
    required this.status,
    required this.imageUrl,
    this.localImagePath,
    required this.createdAt,
  });

  // Handles data from both server (snake_case) and local cache (camelCase).
  factory ReportModel.fromMap(Map<dynamic, dynamic> map) {
    return ReportModel(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      title: map['nama_barang']?.toString() ?? map['title']?.toString() ?? '',
      description: map['deskripsi_barang']?.toString() ?? map['description']?.toString() ?? '',
      category: map['kategori_barang']?.toString() ?? map['category']?.toString() ?? '',
      location: map['lokasi_kehilangan']?.toString() ?? map['location']?.toString() ?? '',
      contact: map['kontak']?.toString() ?? map['contact']?.toString(),
      reward: map['reward']?.toString(),
      status: map['status_postingan']?.toString() ?? map['status']?.toString() ?? 'draft',
      imageUrl: map['imageUrl']?.toString() ?? '',
      localImagePath: map['local_image_path']?.toString(),
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  // Creates a map suitable for caching.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'contact': contact,
      'reward': reward,
      'status': status,
      'imageUrl': imageUrl,
      'localImagePath': localImagePath,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}