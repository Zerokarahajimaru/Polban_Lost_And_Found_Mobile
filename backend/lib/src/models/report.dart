// This file now contains a clean, resolved version of the ReportModel,
// including the 'kontak' field and removing 'warnaBarang'.

class ReportModel {
  final String? id;
  final String userId;
  final String namaBarang;
  final String kategoriBarang;
  final String statusPostingan; // Draft, Available, Finished, Inactive, Takedown
  final String deskripsiBarang;
  final String lokasiKehilangan;
  final String kontak;
  final int reportCount;
  final DateTime lastActivityAt;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> images;
  final BountyModel? bounty;

  ReportModel({
    this.id,
    required this.userId,
    required this.namaBarang,
    required this.kategoriBarang,
    required this.statusPostingan,
    required this.deskripsiBarang,
    required this.lokasiKehilangan,
    required this.kontak,
    this.reportCount = 0,
    required this.lastActivityAt,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
    this.bounty,
  });

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'nama_barang': namaBarang,
        'kategori_barang': kategoriBarang,
        'status_postingan': statusPostingan,
        'deskripsi_barang': deskripsiBarang,
        'lokasi_kehilangan': lokasiKehilangan,
        'kontak': kontak,
        'report_count': reportCount,
        'last_activity_at': lastActivityAt.toIso8601String(),
        'is_synced': isSynced,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'images': images,
        'bounty': bounty?.toMap(),
      };

  factory ReportModel.fromMap(Map<String, dynamic> map) => ReportModel(
        id: map['_id']?.toString(),
        userId: map['user_id'].toString(),
        namaBarang: (map['nama_barang'] ?? '').toString(),
        kategoriBarang: (map['kategori_barang'] ?? '').toString(),
        statusPostingan: (map['status_postingan'] ?? 'Draft').toString(),
        deskripsiBarang: (map['deskripsi_barang'] ?? '').toString(),
        lokasiKehilangan: (map['lokasi_kehilangan'] ?? '').toString(),
        kontak: (map['kontak'] ?? '').toString(),
        reportCount: (map['report_count'] ?? 0) as int,
        lastActivityAt: DateTime.parse(
          map['last_activity_at']?.toString() ??
              DateTime.now().toIso8601String(),
        ),
        isSynced: (map['is_synced'] ?? false) as bool,
        createdAt: DateTime.parse(
          map['created_at']?.toString() ?? DateTime.now().toIso8601String(),
        ),
        updatedAt: DateTime.parse(
          map['updated_at']?.toString() ?? DateTime.now().toIso8601String(),
        ),
        images: List<String>.from(map['images'] as List? ?? []),
        bounty: map['bounty'] != null
            ? BountyModel.fromMap(map['bounty'] as Map<String, dynamic>)
            : null,
      );
}

class BountyModel {
  final int amount;
  final String description;

  BountyModel({required this.amount, required this.description});

  Map<String, dynamic> toMap() => {
        'bounty_amount': amount,
        'bounty_description': description,
      };

  factory BountyModel.fromMap(Map<String, dynamic> map) => BountyModel(
        amount: (map['bounty_amount'] ?? 0) as int,
        description: (map['bounty_description'] ?? '').toString(),
      );
}