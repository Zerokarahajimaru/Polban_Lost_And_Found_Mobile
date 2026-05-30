class ReportModel {
  final String id;
  final String? userId; 
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
  final String? claimantName; 
  final String? claimantId;   
  final DateTime? resolvedAt;

  ReportModel({
    required this.id,
    this.userId,
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
    this.claimantName,
    this.claimantId,
    this.resolvedAt,
  });

  factory ReportModel.fromMap(Map<dynamic, dynamic> map) {
    // Determine image URL - handle both 'imageUrl' and 'images' (list from backend)
    String img = map['imageUrl']?.toString() ?? '';
    if (img.isEmpty && map['images'] != null && (map['images'] as List).isNotEmpty) {
      img = (map['images'] as List).first.toString();
    }

    return ReportModel(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? map['user_id']?.toString(),
      title: map['nama_barang']?.toString() ?? map['title']?.toString() ?? '',
      description: map['deskripsi_barang']?.toString() ?? map['description']?.toString() ?? '',
      category: map['kategori_barang']?.toString() ?? map['category']?.toString() ?? '',
      location: map['lokasi_kehilangan']?.toString() ?? map['location']?.toString() ?? '',
      contact: map['kontak']?.toString() ?? map['contact']?.toString(),
      reward: map['reward']?.toString(),
      status: map['status_postingan']?.toString() ?? map['status']?.toString() ?? 'draft',
      imageUrl: img,
      localImagePath: map['local_image_path']?.toString(),
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      claimantName: map['claimantName']?.toString() ?? map['claimant_name']?.toString(),
      claimantId: map['claimantId']?.toString() ?? map['claimant_id']?.toString(),
      resolvedAt: DateTime.tryParse(map['resolvedAt']?.toString() ?? map['resolved_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
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
      'claimantName': claimantName,
      'claimantId': claimantId,
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }
}
