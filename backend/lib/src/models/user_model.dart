import 'package:mongo_dart/mongo_dart.dart';

enum UserRole { teknisi, user }

class UserModel {
  final ObjectId id;
  final String name;
  final String email;
  final String password; // Should be hashed
  final UserRole role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role.name,
    };
  }

  // Safe to send to the client
  Map<String, dynamic> toJson() {
    return {
      'id': id.toHexString(),
      'name': name,
      'email': email,
      'role': role.name,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['_id'] as ObjectId,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      role: UserRole.values.firstWhere((e) => e.name == map['role']),
    );
  }
}