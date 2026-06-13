import 'package:core_module/core_module.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home/src/controllers/home_controller.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:report/src/controllers/report_controller.dart';

import 'home_test.mocks.dart';

@GenerateMocks([ReportController])
void main() {
  // ---------------------------------------------------------------------------
  // GROUP A — HomePage Display (Empty State & Tab Filtering)
  // Mencakup TC-008, TC-009, TC-010
  // ---------------------------------------------------------------------------
  group('HomeController Tests', () {
    group('GROUP A — HomePage Display (Empty State & Tab Filtering)', () {
      late MockReportController mockReportController;
      late HomeController homeController;

      setUp(() {
        mockReportController = MockReportController();
        homeController = HomeController();
      });

      tearDown(() {
        homeController.dispose();
      });

      test(
        'WB-H-01: TC-008 — Empty state saat tidak ada laporan di server',
        () {
          // Arrange
          when(mockReportController.reports).thenReturn([]);
          when(mockReportController.isLoading).thenReturn(false);

          // Act
          final filteredReports =
              homeController.filterReports(mockReportController.reports);

          // Assert
          expect(filteredReports, isEmpty);
          expect(mockReportController.reports, isEmpty);
        },
      );

      test(
        'WB-H-02: TC-009 — Hanya laporan berstatus "lost" yang muncul di tab Kehilangan',
        () {
          // Arrange — data campuran: lost, found, resolved
          final reports = [
            _createReportModel(id: 'r001', title: 'KTM atas nama Budi', status: 'lost'),
            _createReportModel(id: 'r002', title: 'Dompet Merah', status: 'found'),
            _createReportModel(id: 'r003', title: 'Kunci Motor', status: 'resolved'),
          ];
          when(mockReportController.reports).thenReturn(reports);

          // Act
          homeController.setActiveTab(HomeTab.kehilangan);
          final filteredReports =
              homeController.filterReports(mockReportController.reports);

          // Assert — hanya r001 yang lolos
          expect(filteredReports.length, equals(1));
          expect(filteredReports.first.id, equals('r001'));
          expect(filteredReports.first.status.toLowerCase(), equals('lost'));
        },
      );

      test(
        'WB-H-03: TC-010 — Hanya laporan berstatus "found" yang muncul di tab Penemuan',
        () {
          // Arrange
          final reports = [
            _createReportModel(id: 'r001', title: 'KTM atas nama Budi', status: 'lost'),
            _createReportModel(id: 'r002', title: 'Dompet Merah', status: 'found'),
            _createReportModel(id: 'r003', title: 'Tas Putih', status: 'found'),
          ];
          when(mockReportController.reports).thenReturn(reports);

          // Act
          homeController.setActiveTab(HomeTab.penemuan);
          final filteredReports =
              homeController.filterReports(mockReportController.reports);

          // Assert — r002 dan r003
          expect(filteredReports.length, equals(2));
          expect(
            filteredReports.every((r) => r.status.toLowerCase() == 'found'),
            isTrue,
          );
        },
      );

      test(
        'WB-H-04: Status "resolved", "blocked", "under_review" disembunyikan dari public feed',
        () {
          // Arrange
          final reports = [
            _createReportModel(id: 'r001', title: 'Laporan Aktif', status: 'lost'),
            _createReportModel(id: 'r002', title: 'Laporan Resolved', status: 'resolved'),
            _createReportModel(id: 'r003', title: 'Laporan Blocked', status: 'blocked'),
            _createReportModel(id: 'r004', title: 'Laporan Under Review', status: 'under_review'),
          ];
          when(mockReportController.reports).thenReturn(reports);

          // Act
          homeController.setActiveTab(HomeTab.kehilangan);
          final filteredReports =
              homeController.filterReports(mockReportController.reports);

          // Assert — hanya r001 yang lolos
          expect(filteredReports.length, equals(1));
          expect(filteredReports.first.id, equals('r001'));
          expect(
            filteredReports.any((r) => r.status.toLowerCase() == 'resolved'),
            isFalse,
          );
          expect(
            filteredReports.any((r) => r.status.toLowerCase() == 'blocked'),
            isFalse,
          );
          expect(
            filteredReports.any((r) => r.status.toLowerCase() == 'under_review'),
            isFalse,
          );
        },
      );

      test(
        'WB-H-05: setActiveTab() memanggil notifyListeners dan state berpindah dengan benar',
        () {
          // Arrange
          final tabChanges = <HomeTab>[];
          homeController.addListener(() => tabChanges.add(homeController.activeTab));

          // Act
          homeController.setActiveTab(HomeTab.penemuan);
          homeController.setActiveTab(HomeTab.kehilangan);

          // Assert
          expect(tabChanges.length, equals(2));
          expect(tabChanges.first, equals(HomeTab.penemuan));
          expect(tabChanges.last, equals(HomeTab.kehilangan));
        },
      );

      test(
        'WB-H-05b: setActiveTab() dengan tab yang sama tidak memanggil notifyListeners',
        () {
          // Arrange — default sudah kehilangan
          var notifyCount = 0;
          homeController.addListener(() => notifyCount++);

          // Act — set ke nilai yang sama
          homeController.setActiveTab(HomeTab.kehilangan);

          // Assert — tidak ada notifikasi karena tidak ada perubahan
          expect(notifyCount, equals(0));
        },
      );
    });

    // ---------------------------------------------------------------------------
    // GROUP B — Search Functionality
    // Mencakup TC-011, TC-012
    // ---------------------------------------------------------------------------
    group('GROUP B — Search Functionality', () {
      late MockReportController mockReportController;
      late HomeController homeController;

      setUp(() {
        mockReportController = MockReportController();
        homeController = HomeController();
      });

      tearDown(() {
        homeController.dispose();
      });

      test(
        'WB-H-06: TC-011 — Search berhasil memfilter laporan berdasarkan judul',
        () {
          // Arrange
          final reports = [
            _createReportModel(id: 'r001', title: 'KTM atas nama Budi', status: 'lost'),
            _createReportModel(id: 'r002', title: 'Dompet Merah', status: 'lost'),
            _createReportModel(id: 'r003', title: 'Kunci Motor', status: 'found'),
          ];
          when(mockReportController.reports).thenReturn(reports);

          // Act
          homeController.setActiveTab(HomeTab.kehilangan);
          homeController.updateSearchQuery('KTM');
          final filteredReports =
              homeController.filterReports(mockReportController.reports);

          // Assert — hanya r001 yang judulnya mengandung "ktm"
          expect(filteredReports.length, equals(1));
          expect(filteredReports.first.id, equals('r001'));
          expect(
            filteredReports.first.title.toLowerCase().contains('ktm'),
            isTrue,
          );
        },
      );

      test(
        'WB-H-07: TC-012 — Search dengan keyword tidak ditemukan → empty state',
        () {
          // Arrange
          final reports = [
            _createReportModel(id: 'r001', title: 'KTM atas nama Budi', status: 'lost'),
            _createReportModel(id: 'r002', title: 'Dompet Merah', status: 'lost'),
          ];
          when(mockReportController.reports).thenReturn(reports);

          // Act
          homeController.setActiveTab(HomeTab.kehilangan);
          homeController.updateSearchQuery('xyznotfound');
          final filteredReports =
              homeController.filterReports(mockReportController.reports);

          // Assert
          expect(filteredReports, isEmpty);
        },
      );

      test(
        'WB-H-08: Search query bersifat case-insensitive (ktm = KTM = KtM)',
        () {
          // Arrange
          final reports = [
            _createReportModel(id: 'r001', title: 'KTM atas nama Budi', status: 'lost'),
          ];
          when(mockReportController.reports).thenReturn(reports);
          homeController.setActiveTab(HomeTab.kehilangan);

          // Act & Assert — semua variasi huruf harus match
          homeController.updateSearchQuery('ktm');
          expect(homeController.filterReports(mockReportController.reports).length, equals(1));

          homeController.updateSearchQuery('KTM');
          expect(homeController.filterReports(mockReportController.reports).length, equals(1));

          homeController.updateSearchQuery('KtM');
          expect(homeController.filterReports(mockReportController.reports).length, equals(1));
        },
      );

      test(
        'WB-H-09: Search juga mencari di field location, bukan hanya title',
        () {
          // Arrange
          final reports = [
            _createReportModel(
              id: 'r001',
              title: 'Laporan A',
              location: 'Aula Polban',
              status: 'lost',
            ),
            _createReportModel(
              id: 'r002',
              title: 'Laporan B',
              location: 'Kantin Utama',
              status: 'lost',
            ),
          ];
          when(mockReportController.reports).thenReturn(reports);

          // Act
          homeController.setActiveTab(HomeTab.kehilangan);
          homeController.updateSearchQuery('aula');
          final filteredReports =
              homeController.filterReports(mockReportController.reports);

          // Assert — hanya r001 yang lokasinya mengandung "aula"
          expect(filteredReports.length, equals(1));
          expect(filteredReports.first.id, equals('r001'));
          expect(
            filteredReports.first.location.toLowerCase().contains('aula'),
            isTrue,
          );
        },
      );

      test(
        'WB-H-10: updateSearchQuery() memanggil notifyListeners',
        () {
          // Arrange
          var notified = false;
          homeController.addListener(() => notified = true);

          // Act
          homeController.updateSearchQuery('test');

          // Assert
          expect(notified, isTrue);
        },
      );

      test(
        'WB-H-10b: updateSearchQuery() melakukan trim whitespace sebelum menyimpan',
        () {
          // Act
          homeController.updateSearchQuery('  KTM  ');

          // Assert — query tersimpan sudah di-trim dan lowercase
          expect(homeController.searchQuery, equals('ktm'));
        },
      );
    });

    // ---------------------------------------------------------------------------
    // GROUP C — Category Filter
    // ---------------------------------------------------------------------------
    group('GROUP C — Category Filter', () {
      late MockReportController mockReportController;
      late HomeController homeController;

      setUp(() {
        mockReportController = MockReportController();
        homeController = HomeController();
      });

      tearDown(() {
        homeController.dispose();
      });

      test(
        'WB-H-11: Kategori "Semua" menampilkan semua laporan tanpa filter kategori',
        () {
          // Arrange — laporan dengan kategori berbeda-beda
          final reports = [
            _createReportModel(id: 'r001', title: 'KTM', status: 'lost', category: 'Dokumen'),
            _createReportModel(id: 'r002', title: 'Dompet', status: 'lost', category: 'Dompet'),
            _createReportModel(id: 'r003', title: 'Kunci', status: 'lost', category: 'Lainnya'),
          ];
          when(mockReportController.reports).thenReturn(reports);

          // Act
          homeController.setActiveTab(HomeTab.kehilangan);
          homeController.setCategory('Semua');
          final filteredReports =
              homeController.filterReports(mockReportController.reports);

          // Assert — semua 3 laporan lolos
          expect(filteredReports.length, equals(3));
        },
      );

      test(
        'WB-H-12: Kategori "Dokumen" hanya menampilkan laporan berkategori Dokumen',
        () {
          // Arrange
          final reports = [
            _createReportModel(id: 'r001', title: 'KTM', status: 'lost', category: 'Dokumen'),
            _createReportModel(id: 'r002', title: 'Kartu Pelajar', status: 'lost', category: 'Dokumen'),
            _createReportModel(id: 'r003', title: 'Dompet', status: 'lost', category: 'Dompet'),
          ];
          when(mockReportController.reports).thenReturn(reports);

          // Act
          homeController.setActiveTab(HomeTab.kehilangan);
          homeController.setCategory('Dokumen');
          final filteredReports =
              homeController.filterReports(mockReportController.reports);

          // Assert — hanya r001 dan r002
          expect(filteredReports.length, equals(2));
          expect(
            filteredReports.every((r) => r.category.toLowerCase() == 'dokumen'),
            isTrue,
          );
        },
      );

      test(
        'WB-H-13: Filter kategori bersifat case-insensitive ("Dokumen" == "dokumen")',
        () {
          // Arrange
          final reports = [
            _createReportModel(id: 'r001', title: 'KTM', status: 'lost', category: 'Dokumen'),
            _createReportModel(id: 'r002', title: 'Dompet', status: 'lost', category: 'Dompet'),
          ];
          when(mockReportController.reports).thenReturn(reports);

          // Act
          homeController.setActiveTab(HomeTab.kehilangan);
          homeController.setCategory('dokumen'); // lowercase
          final filteredReports =
              homeController.filterReports(mockReportController.reports);

          // Assert — tetap match meski berbeda kapital
          expect(filteredReports.length, equals(1));
          expect(filteredReports.first.id, equals('r001'));
        },
      );

      test(
        'WB-H-13b: setCategory() memanggil notifyListeners',
        () {
          // Arrange
          var notified = false;
          homeController.addListener(() => notified = true);

          // Act
          homeController.setCategory('Dokumen');

          // Assert
          expect(notified, isTrue);
        },
      );

      test(
        'WB-H-13c: setCategory() dengan nilai yang sama tidak memanggil notifyListeners',
        () {
          // Arrange — default sudah "Semua"
          var notifyCount = 0;
          homeController.addListener(() => notifyCount++);

          // Act
          homeController.setCategory('Semua');

          // Assert
          expect(notifyCount, equals(0));
        },
      );
    });

    // ---------------------------------------------------------------------------
    // GROUP D — Multi-Filter (Kombinasi Tab + Kategori + Search)
    // Mencakup TC-013
    // ---------------------------------------------------------------------------
    group('GROUP D — Multi-Filter (Kombinasi Tab + Kategori + Search)', () {
      late MockReportController mockReportController;
      late HomeController homeController;

      setUp(() {
        mockReportController = MockReportController();
        homeController = HomeController();
      });

      tearDown(() {
        homeController.dispose();
      });

      test(
        'WB-H-14: TC-013 — Filter kombinasi kategori "Dokumen" dan keyword "KTM" → tepat satu hasil',
        () {
          // Arrange
          final reports = [
            _createReportModel(id: 'r001', title: 'KTM atas nama Budi', status: 'lost', category: 'Dokumen'),
            _createReportModel(id: 'r002', title: 'KTM atas nama Andi', status: 'lost', category: 'Lainnya'),
            _createReportModel(id: 'r003', title: 'Dompet Merah', status: 'lost', category: 'Dokumen'),
          ];
          when(mockReportController.reports).thenReturn(reports);

          // Act
          homeController.setActiveTab(HomeTab.kehilangan);
          homeController.setCategory('Dokumen');
          homeController.updateSearchQuery('KTM');
          final filteredReports =
              homeController.filterReports(mockReportController.reports);

          // Assert — hanya r001 yang memenuhi keduanya (kategori Dokumen DAN judul mengandung KTM)
          expect(filteredReports.length, equals(1));
          expect(filteredReports.first.id, equals('r001'));
          expect(filteredReports.first.title.toLowerCase().contains('ktm'), isTrue);
        },
      );

      test(
        'WB-H-15: Multi-filter tab + kategori tanpa search → hanya laporan yang match tab dan kategori',
        () {
          // Arrange
          final reports = [
            _createReportModel(id: 'r001', title: 'KTM', status: 'lost', category: 'Dokumen'),
            _createReportModel(id: 'r002', title: 'Kartu Pelajar', status: 'lost', category: 'Dokumen'),
            _createReportModel(id: 'r003', title: 'Dompet', status: 'found', category: 'Dokumen'),
          ];
          when(mockReportController.reports).thenReturn(reports);

          // Act
          homeController.setActiveTab(HomeTab.kehilangan);
          homeController.setCategory('Dokumen');
          final filteredReports =
              homeController.filterReports(mockReportController.reports);

          // Assert — r001, r002 (lost + Dokumen). r003 terfilter karena status=found
          expect(filteredReports.length, equals(2));
          expect(
            filteredReports.every((r) => r.status.toLowerCase() == 'lost'),
            isTrue,
          );
        },
      );

      test(
        'WB-H-16: Filter sangat ketat (tab + kategori + search) yang tidak match → empty state',
        () {
          // Arrange
          final reports = [
            _createReportModel(id: 'r001', title: 'KTM', status: 'lost', category: 'Dokumen'),
            _createReportModel(id: 'r002', title: 'Dompet', status: 'found', category: 'Dompet'),
          ];
          when(mockReportController.reports).thenReturn(reports);

          // Act — cari di tab penemuan + kategori Dokumen + keyword xyz → tidak ada yang cocok
          homeController.setActiveTab(HomeTab.penemuan);
          homeController.setCategory('Dokumen');
          homeController.updateSearchQuery('xyz');
          final filteredReports =
              homeController.filterReports(mockReportController.reports);

          // Assert
          expect(filteredReports, isEmpty);
        },
      );
    });

    // ---------------------------------------------------------------------------
    // GROUP E — Sorting Functionality
    // ---------------------------------------------------------------------------
    group('GROUP E — Sorting Functionality', () {
      late HomeController homeController;

      setUp(() {
        homeController = HomeController();
      });

      tearDown(() {
        homeController.dispose();
      });

      test(
        'WB-H-17: Sort "terbaru" (default) — laporan terbaru muncul paling atas',
        () {
          // Arrange
          final now = DateTime.now();
          final reports = [
            _createReportModel(
              id: 'r001',
              title: 'Laporan Lama',
              status: 'lost',
              createdAt: now.subtract(const Duration(days: 2)),
            ),
            _createReportModel(
              id: 'r002',
              title: 'Laporan Baru',
              status: 'lost',
              createdAt: now,
            ),
            _createReportModel(
              id: 'r003',
              title: 'Laporan Kemarin',
              status: 'lost',
              createdAt: now.subtract(const Duration(days: 1)),
            ),
          ];

          // Act
          homeController.setActiveTab(HomeTab.kehilangan);
          homeController.setActiveSort(HomeSort.terbaru);
          final filteredReports = homeController.filterReports(reports);

          // Assert — urutan: r002 (baru) → r003 (kemarin) → r001 (lama)
          expect(filteredReports.length, equals(3));
          expect(filteredReports[0].id, equals('r002'));
          expect(filteredReports[1].id, equals('r003'));
          expect(filteredReports[2].id, equals('r001'));
        },
      );

      test(
        'WB-H-18: Sort "abjadAZ" — laporan diurutkan A-Z berdasarkan judul',
        () {
          // Arrange
          final reports = [
            _createReportModel(id: 'r001', title: 'Zebra', status: 'lost'),
            _createReportModel(id: 'r002', title: 'Apple', status: 'lost'),
            _createReportModel(id: 'r003', title: 'Mango', status: 'lost'),
          ];

          // Act
          homeController.setActiveTab(HomeTab.kehilangan);
          homeController.setActiveSort(HomeSort.abjadAZ);
          final filteredReports = homeController.filterReports(reports);

          // Assert — Apple → Mango → Zebra
          expect(filteredReports.length, equals(3));
          expect(filteredReports[0].title, equals('Apple'));
          expect(filteredReports[1].title, equals('Mango'));
          expect(filteredReports[2].title, equals('Zebra'));
        },
      );

      test(
        'WB-H-19: Sort "imbalanTerbesar" — laporan dengan reward lebih besar muncul lebih atas',
        () {
          // Arrange
          final reports = [
            _createReportModel(id: 'r001', title: 'Low Reward', status: 'lost', reward: '10000'),
            _createReportModel(id: 'r002', title: 'High Reward', status: 'lost', reward: '500000'),
            _createReportModel(id: 'r003', title: 'Mid Reward', status: 'lost', reward: '100000'),
          ];

          // Act
          homeController.setActiveTab(HomeTab.kehilangan);
          homeController.setActiveSort(HomeSort.imbalanTerbesar);
          final filteredReports = homeController.filterReports(reports);

          // Assert — r002 (500k) → r003 (100k) → r001 (10k)
          expect(filteredReports.length, equals(3));
          expect(filteredReports[0].id, equals('r002'));
          expect(filteredReports[1].id, equals('r003'));
          expect(filteredReports[2].id, equals('r001'));
        },
      );

      test(
        'WB-H-19b: Sort "imbalanTerbesar" dengan reward null diperlakukan sebagai 0',
        () {
          // Arrange
          final reports = [
            _createReportModel(id: 'r001', title: 'No Reward', status: 'lost', reward: null),
            _createReportModel(id: 'r002', title: 'Has Reward', status: 'lost', reward: '50000'),
          ];

          // Act
          homeController.setActiveTab(HomeTab.kehilangan);
          homeController.setActiveSort(HomeSort.imbalanTerbesar);
          final filteredReports = homeController.filterReports(reports);

          // Assert — r002 (50k) lebih atas dari r001 (0/null)
          expect(filteredReports[0].id, equals('r002'));
          expect(filteredReports[1].id, equals('r001'));
        },
      );

      test(
        'WB-H-20: setActiveSort() memanggil notifyListeners',
        () {
          // Arrange
          var notified = false;
          homeController.addListener(() => notified = true);

          // Act
          homeController.setActiveSort(HomeSort.abjadAZ);

          // Assert
          expect(notified, isTrue);
        },
      );

      test(
        'WB-H-20b: setActiveSort() dengan nilai yang sama tidak memanggil notifyListeners',
        () {
          // Arrange — default sudah HomeSort.terbaru
          var notifyCount = 0;
          homeController.addListener(() => notifyCount++);

          // Act
          homeController.setActiveSort(HomeSort.terbaru);

          // Assert
          expect(notifyCount, equals(0));
        },
      );
    });

    // ---------------------------------------------------------------------------
    // GROUP F — Filter Reset
    // ---------------------------------------------------------------------------
    group('GROUP F — Filter Reset', () {
      late HomeController homeController;

      setUp(() {
        homeController = HomeController();
      });

      tearDown(() {
        homeController.dispose();
      });

      test(
        'WB-H-21: resetFilters() mengembalikan semua filter ke nilai default',
        () {
          // Arrange — ubah semua filter dari default
          homeController.setCategory('Dokumen');
          homeController.updateSearchQuery('test');
          homeController.setActiveSort(HomeSort.abjadAZ);

          // Act
          homeController.resetFilters();

          // Assert — kembali ke default
          expect(homeController.searchQuery, isEmpty);
          expect(homeController.selectedCategory, equals('Semua'));
          expect(homeController.activeSort, equals(HomeSort.terbaru));
        },
      );

      test(
        'WB-H-22: resetFilters() memanggil notifyListeners',
        () {
          // Arrange
          homeController.setCategory('Dokumen'); // supaya ada perubahan yang di-reset
          var notified = false;
          homeController.addListener(() => notified = true);

          // Act
          homeController.resetFilters();

          // Assert
          expect(notified, isTrue);
        },
      );

      test(
        'WB-H-22b: Setelah resetFilters(), filterReports() mengembalikan semua laporan aktif',
        () {
          // Arrange
          final reports = [
            _createReportModel(id: 'r001', title: 'Alpha', status: 'lost', category: 'Dokumen'),
            _createReportModel(id: 'r002', title: 'Beta', status: 'lost', category: 'Lainnya'),
          ];
          homeController.setCategory('Dokumen');
          homeController.updateSearchQuery('Alpha');
          homeController.setActiveTab(HomeTab.kehilangan);

          // Act
          homeController.resetFilters();
          final filteredReports = homeController.filterReports(reports);

          // Assert — setelah reset, semua laporan lost kembali muncul
          expect(filteredReports.length, equals(2));
        },
      );
    });

    // ---------------------------------------------------------------------------
    // GROUP G — Unsync Count (Offline/Pending Posts)
    // ---------------------------------------------------------------------------
    group('GROUP G — Unsync Count (Offline/Pending Posts)', () {
      late HomeController homeController;

      setUp(() {
        homeController = HomeController();
      });

      tearDown(() {
        homeController.dispose();
      });

      test(
        'WB-H-23: getUnsyncedCount() menghitung laporan dengan prefix "pending_"',
        () {
          // Arrange
          final reports = [
            _createReportModel(id: 'pending_1', title: 'Pending 1', status: 'lost'),
            _createReportModel(id: 'pending_2', title: 'Pending 2', status: 'lost'),
            _createReportModel(id: 'r003', title: 'Synced', status: 'lost'),
          ];

          // Act
          final unsyncedCount = homeController.getUnsyncedCount(reports);

          // Assert
          expect(unsyncedCount, equals(2));
        },
      );

      test(
        'WB-H-24: getUnsyncedCount() return 0 jika tidak ada laporan pending',
        () {
          // Arrange
          final reports = [
            _createReportModel(id: 'r001', title: 'Report 1', status: 'lost'),
            _createReportModel(id: 'r002', title: 'Report 2', status: 'lost'),
          ];

          // Act
          final unsyncedCount = homeController.getUnsyncedCount(reports);

          // Assert
          expect(unsyncedCount, equals(0));
        },
      );

      test(
        'WB-H-25: getUnsyncedCount() return 0 saat list kosong',
        () {
          // Act
          final unsyncedCount = homeController.getUnsyncedCount([]);

          // Assert
          expect(unsyncedCount, equals(0));
        },
      );

      test(
        'WB-H-26: ID yang mengandung "pending_" di tengah tidak dihitung sebagai unsynced',
        () {
          // Arrange — hanya prefix yang valid, bukan substring di tengah
          final reports = [
            _createReportModel(id: 'pending_001', title: 'Valid Pending', status: 'lost'),
            _createReportModel(id: 'report_pending_xyz', title: 'Not Pending', status: 'lost'),
          ];

          // Act
          final unsyncedCount = homeController.getUnsyncedCount(reports);

          // Assert — hanya pending_001 yang valid (startsWith 'pending_')
          expect(unsyncedCount, equals(1));
        },
      );
    });
  });
}


// =============================================================================
// Helper — Membuat ReportModel dengan nilai default yang realistis
// =============================================================================

/// Membuat [ReportModel] dengan field yang diperlukan oleh [HomeController].
/// Field [category] dan [reward] wajib ada agar filter & sort bekerja dengan benar.
ReportModel _createReportModel({
  required String id,
  required String title,
  String description = 'Deskripsi test',
  String imageUrl = 'https://example.com/image.jpg',
  String location = 'Polban, Bandung',
  String status = 'lost',
  String category = 'Lainnya',
  String? reward,
  DateTime? createdAt,
  String? localImagePath,
}) {
  return ReportModel(
    id: id,
    title: title,
    description: description,
    imageUrl: imageUrl,
    location: location,
    createdAt: createdAt ?? DateTime.now(),
    status: status,
    category: category,
    reward: reward,
    localImagePath: localImagePath,
  );
}