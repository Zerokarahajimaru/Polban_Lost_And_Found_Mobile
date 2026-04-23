import 'package:hive/hive.dart';

part 'report_model.g.dart';

@HiveType(typeId: 0)
class ReportModel extends HiveObject {
  ReportModel({
    this.id,
    required this.userId,
    required this.namaBarang,
    required this.kategoriBarang,
    required this.statusPostingan,
    required this.deskripsiBarang,
    required this.lokasiKehilangan,
    required this.warnaBarang,
    required this.kontak,
    required this.reportCount,
    required this.lastActivityAt,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
    required this.images,
    this.bounty,
  });

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      id: map['_id'] as String?,
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

  @HiveField(0)
  String? id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String namaBarang;

  @HiveField(3)
  String kategoriBarang;

  @HiveField(4)
  String statusPostingan;

  @HiveField(5)
  String deskripsiBarang;

  @HiveField(6)
  String lokasiKehilangan;

  @HiveField(7)
  String warnaBarang;

  @HiveField(8)
  String kontak;

  @HiveField(9)
  int reportCount;

  @HiveField(10)
  DateTime lastActivityAt;

  @HiveField(11)
  DateTime createdAt;

  @HiveField(12)
  DateTime updatedAt;

  @HiveField(13)
  bool isSynced;

  @HiveField(14)
  List<String> images;

  @HiveField(15)
  BountyModel? bounty;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
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

  ReportModel copyWith({
    String? id,
    String? userId,
    String? namaBarang,
    String? kategoriBarang,
    String? statusPostingan,
    String? deskripsiBarang,
    String? lokasiKehilangan,
    String? warnaBarang,
    String? kontak,
    int? reportCount,
    DateTime? lastActivityAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    List<String>? images,
    BountyModel? bounty,
  }) {
    return ReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      namaBarang: namaBarang ?? this.namaBarang,
      kategoriBarang: kategoriBarang ?? this.kategoriBarang,
      statusPostingan: statusPostingan ?? this.statusPostingan,
      deskripsiBarang: deskripsiBarang ?? this.deskripsiBarang,
      lokasiKehilangan: lokasiKehilangan ?? this.lokasiKehilangan,
      warnaBarang: warnaBarang ?? this.warnaBarang,
      kontak: kontak ?? this.kontak,
      reportCount: reportCount ?? this.reportCount,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      images: images ?? this.images,
      bounty: bounty ?? this.bounty,
    );
  }
}

@HiveType(typeId: 1)
class BountyModel extends HiveObject {
  BountyModel({
    required this.amount,
    required this.currency,
  });

  factory BountyModel.fromMap(Map<String, dynamic> map) {
    return BountyModel(
      amount: map['amount'] as double,
      currency: map['currency'] as String,
    );
  }

  @HiveField(0)
  double amount;

  @HiveField(1)
  String currency;

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'currency': currency,
    };
  }
}