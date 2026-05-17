class AdminStatModel {
  final int totalReports;
  final int totalLost;
  final int foundReports;
  final int totalClaimed;
  final Map<String, int> reportsByCategory;
  final Map<String, int> reportsByLocation;

  AdminStatModel({
    required this.totalReports,
    required this.totalLost,
    required this.foundReports,
    required this.totalClaimed,
    required this.reportsByCategory,
    required this.reportsByLocation,
  });

  /// Factory untuk mengubah data JSON dari Backend (Dio Response) menjadi Objek Dart
  factory AdminStatModel.fromJson(Map<String, dynamic> json) {
    return AdminStatModel(
      totalReports: json['totalReports'] ?? 0,
      totalLost: json['totalLost'] ?? 0,
      foundReports: json['foundReports'] ?? 0,
      totalClaimed: json['totalClaimed'] ?? 0,
      reportsByCategory: Map<String, int>.from(json['reportsByCategory'] ?? {}),
      reportsByLocation: Map<String, int>.from(json['reportsByLocation'] ?? {}),
    );
  }
}