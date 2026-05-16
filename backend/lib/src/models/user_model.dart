import 'package:mongo_dart/mongo_dart.dart';

enum UserRole { teknisi, user }

class UserModel {
  final ObjectId id;
  final String name;
  final String email;
  final String password; // harus di-hash di produksi
  final UserRole role;
  final String statusAkun; // 'active' atau 'banned'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.statusAkun = 'active',
  });

  /// Parse role dari berbagai format yang mungkin ada di database.
  static UserRole _parseRole(String? raw) {
    if (raw == null) return UserRole.user;
    final normalized = raw.toLowerCase().trim();
    // Terima: "teknisi", "Teknisi", "administration", "admin"
    if (normalized == 'teknisi' ||
        normalized == 'administration' ||
        normalized == 'admin') {
      return UserRole.teknisi;
    }
    return UserRole.user;
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['_id'] as ObjectId,
      name: map['name']?.toString() ??
          map['nama_lengkap']?.toString() ??
          '',
      email: map['email']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      role: _parseRole(map['role']?.toString()),
      statusAkun: map['status_akun']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role.name,
      'status_akun': statusAkun,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.toHexString(),
      'name': name,
      'email': email,
      'role': role.name, // "teknisi" atau "user"
      'status_akun': statusAkun,
    };
  }
}
