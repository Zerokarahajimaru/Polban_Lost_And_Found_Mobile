<<<<<<< HEAD
import 'package:backend/src/models/bounty.dart';
import 'package:mongo_dart/mongo_dart.dart';

class ReportModel {
=======
class ReportModel {
  final String? id;
  final String userId;
  final String namaBarang;
  final String kategoriBarang;
  final String
  statusPostingan; // Draft, Available, Finished, Inactive, Takedown
  final String deskripsiBarang;
  final String lokasiKehilangan;
  final String warnaBarang;
  final int reportCount;
  final DateTime lastActivityAt;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> images;
  final BountyModel? bounty;

>>>>>>> 7231402bef47d7910ac874587a3851df66839908
  ReportModel({
    this.id,
    required this.userId,
    required this.namaBarang,
    required this.kategoriBarang,
    required this.statusPostingan,
    required this.deskripsiBarang,
    required this.lokasiKehilangan,
    required this.warnaBarang,
<<<<<<< HEAD
    required this.kontak,
    required this.reportCount,
    required this.lastActivityAt,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
=======
    this.reportCount = 0,
    required this.lastActivityAt,
    this.isSynced = false,
    required this.createdAt,
    required this.updatedAt,
>>>>>>> 7231402bef47d7910ac874587a3851df66839908
    required this.images,
    this.bounty,
  });

<<<<<<< HEAD
  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: (map['_id'] as ObjectId?)?.toHexString(),
      userId: map['userId'] as String,
      namaBarang: map['nama_barang'] as String,
      kategoriBarang: map['kategori_barang'] as String,
      statusPostingan: map['status_postingan'] as String,
      deskripsiBarang: map['deskripsi_barang'] as String,
      lokasiKehilangan: map['lokasi_kehilangan'] as String,
      warnaBarang: map['warna_barang'] as String,
      kontak: map['kontak'] as String,
      reportCount: map['report_count'] as int,
      lastActivityAt: DateTime.parse(map['last_activity_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isSynced: map['is_synced'] as bool,
      images: List<String>.from(map['images'] as List<dynamic>),
      bounty:
          map['bounty'] != null ? BountyModel.fromMap(map['bounty'] as Map<String, dynamic>) : null,
    );
  }

  final String? id;
  final String userId;
  final String namaBarang;
  final String kategoriBarang;
  final String statusPostingan;
  final String deskripsiBarang;
  final String lokasiKehilangan;
  final String warnaBarang;
  final String kontak;
  final int reportCount;
  final DateTime lastActivityAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  final List<String> images;
  final BountyModel? bounty;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': ObjectId.fromHexString(id!),
      'userId': userId,
      'nama_barang': namaBarang,
      'kategori_barang': kategoriBarang,
      'status_postingan': statusPostingan,
      'deskripsi_barang': deskripsiBarang,
      'lokasi_kehilangan': lokasiKehilangan,
      'warna_barang': warnaBarang,
      'kontak': kontak,
      'report_count': reportCount,
      'last_activity_at': lastActivityAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_synced': isSynced,
      'images': images,
      if (bounty != null) 'bounty': bounty!.toMap(),
    };
  }
}
=======
  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'nama_barang': namaBarang,
    'kategori_barang': kategoriBarang,
    'status_postingan': statusPostingan,
    'deskripsi_barang': deskripsiBarang,
    'lokasi_kehilangan': lokasiKehilangan,
    'warna_barang': warnaBarang,
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
    warnaBarang: (map['warna_barang'] ?? '').toString(),
    reportCount: (map['report_count'] ?? 0) as int,
    lastActivityAt: DateTime.parse(
      map['last_activity_at']?.toString() ?? DateTime.now().toIso8601String(),
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
>>>>>>> 7231402bef47d7910ac874587a3851df66839908
