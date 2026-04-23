class LogModel {
  final String? id;
  final String userId;
  final String targetId; // ID Report atau ID User lain
  final String aksi;
  final DateTime actionPerformedAt;

  LogModel({
    this.id,
    required this.userId,
    required this.targetId,
    required this.aksi,
    required this.actionPerformedAt,
  });

  Map<String, dynamic> toMap() => {
    'user_id': userId,
    'target_id': targetId,
    'aksi': aksi,
    'action_performed_at': actionPerformedAt.toIso8601String(),
  };
}
