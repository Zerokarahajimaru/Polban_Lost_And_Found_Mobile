/// Satu pelapor untuk sebuah postingan.
class ModerationReporter {
  final String name;
  final String nim;
  final String reason;

  const ModerationReporter({
    required this.name,
    required this.nim,
    required this.reason,
  });

  /// Huruf pertama nama untuk ditampilkan sebagai avatar.
  String get avatarInitial =>
      name.isNotEmpty ? name[0].toUpperCase() : '?';

  factory ModerationReporter.fromMap(Map<String, dynamic> map) {
    return ModerationReporter(
      name: map['name']?.toString() ?? '',
      nim: map['nim']?.toString() ?? '',
      reason: map['reason']?.toString() ?? '',
    );
  }
}

enum ModerationStatus { pending, takenDown, ignored }

class ModerationReport {
  final String id;
  final String postTitle;
  final String reportReason;
  final List<ModerationReporter> reporters;
  final String? postImageUrl;
  final String uploaderName;
  final DateTime reportedAt;
  ModerationStatus status;

  ModerationReport({
    required this.id,
    required this.postTitle,
    required this.reportReason,
    required this.reporters,
    this.postImageUrl,
    required this.uploaderName,
    required this.reportedAt,
    this.status = ModerationStatus.pending,
  });

  int get reporterCount => reporters.length;

  // Dummy data
  static List<ModerationReport> dummyList() {
    return [
      ModerationReport(
        id: 'mod_001',
        postTitle: 'My kisah',
        reportReason: 'Spam/Iklan',
        uploaderName: 'Ahmad Fauzi',
        reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
        reporters: const [
          ModerationReporter(
            name: 'Farid',
            nim: '241511033',
            reason: 'Spam/Iklan',
          ),
        ],
      ),
      ModerationReport(
        id: 'mod_002',
        postTitle: 'Dompet Macan',
        reportReason: 'Penipuan/Barang Palsu',
        uploaderName: 'Liu Xiao',
        reportedAt: DateTime.now().subtract(const Duration(hours: 7)),
        reporters: const [
          ModerationReporter(
            name: 'Xia Fei',
            nim: '241511033',
            reason: 'Spam/Iklan',
          ),
          ModerationReporter(
            name: 'Vein',
            nim: '241511041',
            reason: 'Spam/Iklan',
          ),
          ModerationReporter(
            name: 'Tamam',
            nim: '241511070',
            reason: 'Spam/Iklan',
          ),
        ],
      ),
      ModerationReport(
        id: 'mod_003',
        postTitle: 'Jaket Kuning Polos',
        reportReason: 'Konten Tidak Sesuai',
        uploaderName: 'Riko Pratama',
        reportedAt: DateTime.now().subtract(const Duration(hours: 14)),
        reporters: const [
          ModerationReporter(
            name: 'Budi Santoso',
            nim: '241511050',
            reason: 'Konten Tidak Sesuai',
          ),
          ModerationReporter(
            name: 'Siti Rahayu',
            nim: '241511051',
            reason: 'Konten Tidak Sesuai',
          ),
        ],
      ),
    ];
  }

  factory ModerationReport.fromMap(Map<String, dynamic> map) {
    return ModerationReport(
      id: map['_id']?.toString() ?? map['id']?.toString() ?? '',
      postTitle: map['postTitle']?.toString() ?? '',
      reportReason: map['reportReason']?.toString() ?? '',
      postImageUrl: map['postImageUrl']?.toString(),
      uploaderName: map['uploaderName']?.toString() ?? '',
      reportedAt:
          DateTime.tryParse(map['reportedAt']?.toString() ?? '') ?? DateTime.now(),
      status: _parseStatus(map['status']?.toString()),
      reporters: (map['reporters'] as List<dynamic>? ?? [])
          .map((r) => ModerationReporter.fromMap(r as Map<String, dynamic>))
          .toList(),
    );
  }

  static ModerationStatus _parseStatus(String? raw) {
    switch (raw) {
      case 'takenDown':
        return ModerationStatus.takenDown;
      case 'ignored':
        return ModerationStatus.ignored;
      default:
        return ModerationStatus.pending;
    }
  }
}