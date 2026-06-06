class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'report', 'claim', 'system'
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'metadata': metadata,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id']?.toString() ?? '',
      title: (map['judul'] ?? map['title'])?.toString() ?? '',
      message: (map['pesan'] ?? map['message'])?.toString() ?? '',
      type: (map['tipe_notif'] ?? map['type'])?.toString() ?? 'system',
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      isRead: map['is_read'] ?? map['isRead'] ?? false,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }
}
