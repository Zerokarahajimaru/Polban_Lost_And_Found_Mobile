import 'package:mongo_dart/mongo_dart.dart';

class ModerationReporter {
  final String name;
  final String nim;
  final String reason;

  ModerationReporter({
    required this.name,
    required this.nim,
    required this.reason,
  });

  factory ModerationReporter.fromMap(Map<String, dynamic> map) {
    return ModerationReporter(
      name: map['name']?.toString() ?? '',
      nim: map['nim']?.toString() ?? '',
      reason: map['reason']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'nim': nim,
        'reason': reason,
      };
}

class ModerationReportModel {
  final String? id;
  final String postId;
  final String postTitle;
  final String reportReason;
  final String uploaderName;
  final String? postImageUrl;
  final List<ModerationReporter> reporters;
  final String status; // 'pending', 'takenDown', 'ignored'
  final DateTime reportedAt;

  ModerationReportModel({
    this.id,
    required this.postId,
    required this.postTitle,
    required this.reportReason,
    required this.uploaderName,
    this.postImageUrl,
    required this.reporters,
    required this.status,
    required this.reportedAt,
  });

  factory ModerationReportModel.fromMap(Map<String, dynamic> map) {
    return ModerationReportModel(
      id: (map['_id'] as ObjectId?)?.toHexString() ?? map['id']?.toString(),
      postId: map['postId']?.toString() ?? '',
      postTitle: map['postTitle']?.toString() ?? '',
      reportReason: map['reportReason']?.toString() ?? '',
      uploaderName: map['uploaderName']?.toString() ?? '',
      postImageUrl: map['postImageUrl']?.toString(),
      reporters: (map['reporters'] as List<dynamic>? ?? [])
          .map((r) =>
              ModerationReporter.fromMap(r as Map<String, dynamic>))
          .toList(),
      status: map['status']?.toString() ?? 'pending',
      reportedAt: DateTime.tryParse(map['reportedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': ObjectId.fromHexString(id!),
      'postId': postId,
      'postTitle': postTitle,
      'reportReason': reportReason,
      'uploaderName': uploaderName,
      if (postImageUrl != null) 'postImageUrl': postImageUrl,
      'reporters': reporters.map((r) => r.toMap()).toList(),
      'status': status,
      'reportedAt': reportedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'postTitle': postTitle,
      'reportReason': reportReason,
      'uploaderName': uploaderName,
      'postImageUrl': postImageUrl,
      'reporters': reporters.map((r) => r.toMap()).toList(),
      'status': status,
      'reportedAt': reportedAt.toIso8601String(),
    };
  }
}
