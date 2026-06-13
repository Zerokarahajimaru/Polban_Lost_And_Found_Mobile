import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:core_module/core_module.dart';
import 'package:home/home.dart';
import 'package:claim/claim.dart';
import 'package:report/report.dart';
import 'package:main_app/main.dart';

void main() {
  testWidgets('App loads and displays LoginPage', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SessionController()),
          ChangeNotifierProvider(create: (_) => ReportController()),
          ChangeNotifierProvider(create: (_) => ClaimController()),
          ChangeNotifierProvider(create: (_) => NotificationController()),
          ChangeNotifierProvider(create: (_) => HomeController()),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('HIMAKOM L&F'), findsOneWidget);
    expect(find.text('Portal Lost & Found Himakom'), findsOneWidget);
  });
}
