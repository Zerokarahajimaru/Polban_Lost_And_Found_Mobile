import 'dart:io';

import 'package:core_module/core_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TC-005 - Session Management', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('history_test_hive_');
      Hive.init(tempDir.path);
      await Hive.openBox<Map>(HiveService.reportsBoxName);
      await Hive.openBox(HiveService.settingsBoxName);
    });

    tearDown(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('Data user dibersihkan saat logout', () {
      final sessionController = SessionController();
      final user = UserModel(
        id: 'user_jtk_123',
        name: 'Budi',
        email: 'budi@proyek4.polban.ac.id',
        role: 'user',
      );

      sessionController.login(user);

      expect(sessionController.currentUser, user);
      expect(sessionController.isLoggedIn, isTrue);
      expect(sessionController.isUser, isTrue);

      sessionController.logout();

      expect(sessionController.currentUser, isNull);
      expect(sessionController.isLoggedIn, isFalse);
      expect(sessionController.isUser, isFalse);
      expect(sessionController.isTeknisi, isFalse);
    });
  });

  group('TC-037 - Navigation', () {
    testWidgets('Bottom navigation bar mengubah halaman ke Riwayat',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: _BottomNavTestHarness()));

      expect(find.text('Beranda Page'), findsOneWidget);
      expect(find.text('Riwayat Page'), findsNothing);
      expect(find.text('Laporanku'), findsOneWidget);

      await tester.tap(find.text('Laporanku'));
      await tester.pump();

      expect(find.text('Beranda Page'), findsNothing);
      expect(find.text('Riwayat Page'), findsOneWidget);
    });
  });
}

class _BottomNavTestHarness extends StatefulWidget {
  const _BottomNavTestHarness();

  @override
  State<_BottomNavTestHarness> createState() => _BottomNavTestHarnessState();
}

class _BottomNavTestHarnessState extends State<_BottomNavTestHarness> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(selectedIndex == 1 ? 'Riwayat Page' : 'Beranda Page'),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
