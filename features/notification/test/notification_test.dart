import 'package:core_module/core_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Import halaman asli menggunakan relative path mundur ke folder lib
import '../lib/src/views/notification_page.dart';

// Import file mock menggunakan relative path folder test yang sama
import 'notification_test.mocks.dart';

void main() {
  late FakeNotificationController fakeNotificationController;
  late FakeSessionController fakeSessionController;
  late UserModel mockUser;

  setUp(() {
    fakeNotificationController = FakeNotificationController();
    fakeSessionController = FakeSessionController();

    // Inisialisasi model pengguna dengan argumen wajib core_module
    mockUser = UserModel(
      id: 'user_jtk_123',
      name: 'Budi',
      email: 'budi@proyek4.polban.ac.id',
      role: 'user',
    );

    fakeSessionController.currentUser = mockUser;
    fakeNotificationController.isLoading = false;
  });

  // Helper pembungkus Provider
  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionController>.value(
            value: fakeSessionController),
        ChangeNotifierProvider<NotificationController>.value(
            value: fakeNotificationController),
      ],
      child: const MaterialApp(
        home: NotifikasiPage(),
      ),
    );
  }

  // Pengaman Utama: Set ukuran layar virtual agar tidak melempar Exception Rendering
  void configureMockScreenSize(WidgetTester tester) {
    final surface = tester.view;
    surface.physicalSize =
        const Size(1080, 1920); // Mensimulasikan ukuran HP Android/iOS nyata
    surface.devicePixelRatio = 1.0;

    addTearDown(() {
      surface.resetPhysicalSize();
      surface.resetDevicePixelRatio();
    });
  }

  group('NotificationPage White-Box Tests (Separated Architecture)', () {
    // ---------------------------------------------------------------------------
    // TC-027 — Daftar notifikasi berhasil dimuat untuk user
    // ---------------------------------------------------------------------------
    testWidgets(
      'WB-N-01: TC-027 — Memastikan loadNotificationsForUser dipanggil saat inisialisasi & data tampil',
      (WidgetTester tester) async {
        configureMockScreenSize(tester);

        // Arrange
        fakeNotificationController.notifications = [
          NotificationModel(
            id: 'n001',
            title: 'Laporan Ditemukan',
            message: 'Dompet Anda telah ditemukan oleh Andi.',
            type: 'claim',
            isRead: false,
            createdAt: DateTime.now(),
          ),
        ];

        // Act
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Assert
        expect(fakeNotificationController.loadNotificationsForUserCalls,
            isNotEmpty);
        expect(
          fakeNotificationController.loadNotificationsForUserCalls,
          contains(fakeSessionController),
        );
        expect(find.text('Laporan Ditemukan'), findsOneWidget);
      },
    );

    // ---------------------------------------------------------------------------
    // TC-025 — Menandai notifikasi sebagai dibaca
    // ---------------------------------------------------------------------------
    testWidgets(
      'WB-N-02: TC-025 — Menekan item notifikasi memicu markAsRead pada controller',
      (WidgetTester tester) async {
        configureMockScreenSize(tester);

        // Arrange
        fakeNotificationController.notifications = [
          NotificationModel(
            id: 'n002',
            title: 'Info Kehilangan',
            message: 'Ada laporan baru di dekat lokasi Anda.',
            type: 'report',
            isRead: false,
            createdAt: DateTime.now(),
          ),
        ];

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        expect(find.text('Info Kehilangan'), findsOneWidget);

        // Act
        await tester.tap(find.text('Info Kehilangan'));
        await tester.pump();

        // Assert
        expect(fakeNotificationController.markAsReadCalls.length, equals(1));
        expect(
            fakeNotificationController.markAsReadCalls.first, equals('n002'));
      },
    );

    // ---------------------------------------------------------------------------
    // TC-026 — Hapus notifikasi via swipe
    // ---------------------------------------------------------------------------
    testWidgets(
      'WB-N-03: TC-026 — Melakukan swipe kiri (endToStart) memicu deleteNotification',
      (WidgetTester tester) async {
        configureMockScreenSize(tester);

        // Arrange
        fakeNotificationController.notifications = [
          NotificationModel(
            id: 'n003',
            title: 'Pemberitahuan Sistem',
            message: 'Akun Anda berhasil diverifikasi.',
            type: 'system',
            isRead: true,
            createdAt: DateTime.now(),
          ),
        ];

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        expect(find.text('Pemberitahuan Sistem'), findsOneWidget);

        // Act
        await tester.drag(find.byType(Dismissible), const Offset(-500.0, 0.0));
        await tester.pumpAndSettle();

        // Assert
        expect(fakeNotificationController.deleteNotificationCalls.length,
            equals(1));
        expect(fakeNotificationController.deleteNotificationCalls.first,
            equals('n003'));
      },
    );
  });
}
