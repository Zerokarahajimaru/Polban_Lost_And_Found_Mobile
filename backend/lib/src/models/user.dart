class UserModel {
  final String? id;
  final String namaLengkap;
  final String email;
  final String password; // Hash ini di backend!
  final String role; // 'user' atau 'administration'
  final String statusAkun; // 'active' atau 'banned'
  final DateTime? banUntil;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.namaLengkap,
    required this.email,
    required this.password,
    required this.role,
    required this.statusAkun,
    this.banUntil,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    '_id': id,
    'nama_lengkap': namaLengkap,
    'email': email,
    'password': password,
    'role': role,
    'status_akun': statusAkun,
    'ban_until': banUntil?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };

factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['_id']?.toString(),
    // Pastikan String dengan casting atau fallback ?? ''
    namaLengkap: (map['nama_lengkap'] ?? '').toString(),
    email: (map['email'] ?? '').toString(),
    password: (map['password'] ?? '').toString(),
    role: (map['role'] ?? 'user').toString(),
    statusAkun: (map['status_akun'] ?? 'active').toString(),
    
    // Safety check untuk DateTime yang bisa null (banUntil)
    banUntil: map['ban_until'] != null
        ? DateTime.parse(map['ban_until'].toString())
        : null,
        
    // Safety check untuk DateTime yang wajib ada (createdAt)
    createdAt: DateTime.parse(
        map['created_at']?.toString() ?? DateTime.now().toIso8601String()
    ),
  );
}
