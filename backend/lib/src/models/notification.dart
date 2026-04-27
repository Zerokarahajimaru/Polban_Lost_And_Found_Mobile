class NotificationModel {
  final String? id;
  final String userId;
  final String judul;
  final String pesan;
  final bool isRead;
  final String tipeNotif;
  final DateTime createdAt;

  NotificationModel({
    this.id,
    required this.userId,
    required this.judul,
    required this.pesan,
    this.isRead = false,
    required this.tipeNotif,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'judul': judul,
    'pesan': pesan,
    'is_read': isRead,
    'tipe_notif': tipeNotif,
    'created_at': createdAt.toIso8601String(),
  };
}
