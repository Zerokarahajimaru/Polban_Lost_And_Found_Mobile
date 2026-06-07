import 'package:mongo_dart/mongo_dart.dart';

class NotificationModel {

  NotificationModel({
    this.id,
    required this.userId,
    required this.judul,
    required this.pesan,
    this.isRead = false,
    required this.tipeNotif,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: (map['_id'] as ObjectId?)?.toHexString() ?? map['id']?.toString(),
      userId: (map['user_id'] ?? map['userId'])?.toString() ?? '',
      judul: map['judul']?.toString() ?? '',
      pesan: map['pesan']?.toString() ?? '',
      isRead: (map['is_read'] as bool?) ?? (map['isRead'] as bool?) ?? false,
      tipeNotif: (map['tipe_notif'] ?? map['tipeNotif'])?.toString() ?? 'system',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
  final String? id;
  final String userId;
  final String judul;
  final String pesan;
  final bool isRead;
  final String tipeNotif; // 'claim', 'report', 'system'
  final DateTime createdAt;

  Map<String, dynamic> toMap() => {
    if (id != null) '_id': ObjectId.fromHexString(id!),
    'user_id': userId,
    'judul': judul,
    'pesan': pesan,
    'is_read': isRead,
    'tipe_notif': tipeNotif,
    'created_at': createdAt.toIso8601String(),
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'judul': judul,
    'pesan': pesan,
    'isRead': isRead,
    'tipeNotif': tipeNotif,
    'createdAt': createdAt.toIso8601String(),
  };
}
