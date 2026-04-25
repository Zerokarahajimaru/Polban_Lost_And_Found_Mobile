import 'package:equatable/equatable.dart';

/// The client-side data model for a Report.
///
/// Uses [Equatable] to allow for value-based comparison, which is useful
/// in state management to determine if the UI needs to be updated.
class ReportModel extends Equatable {
  /// Creates a new [ReportModel].
  const ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.createdAt,
    required this.status,
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String location;
  final DateTime createdAt;
  final String status;

  /// Creates a [ReportModel] from a map (typically from JSON).
  ///
  /// This factory is robust and can handle both complete data from the server
  /// and partial data from locally cached pending reports.
  factory ReportModel.fromMap(Map<dynamic, dynamic> map) {
    String finalId;
    if (map['_id'] != null) {
      // Handle ID from MongoDB
      finalId = map['_id'] is Map ? map['_id']['\$oid'] as String : map['_id'] as String;
    } else {
      // Provide a default ID for pending items that don't have one
      finalId = 'pending_${DateTime.now().millisecondsSinceEpoch}';
    }

    return ReportModel(
      id: finalId,
      title: map['title'] as String? ?? 'Tanpa Judul',
      description: map['description'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      location: map['location'] as String? ?? 'Lokasi tidak diketahui',
      // Provide a default for createdAt if it's null (for pending items)
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String).toLocal()
          : DateTime.now().toLocal(),
      status: map['status'] as String? ?? 'pending',
    );
  }

  /// Converts this model to a map for POSTing to the backend.
  ///
  /// Excludes server-generated fields like `id` and `createdAt`.
  Map<String, dynamic> toPostMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'status': status,
    };
  }

  /// Converts this [ReportModel] object to a [Map<String, dynamic>] object,
  /// suitable for local storage (e.g., Hive).
  Map<String, dynamic> toMap() {
    return {
      '_id': id, // Use '_id' for consistency if this model originated from MongoDB
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        location,
        createdAt,
        status,
      ];
}