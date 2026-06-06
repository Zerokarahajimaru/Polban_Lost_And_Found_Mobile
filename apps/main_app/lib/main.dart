import 'package:claim/claim.dart';
import 'package:core_module/core_module.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:home/home.dart';
import 'package:login/login.dart';
import 'package:notification/notification.dart';
import 'package:post/post.dart';
import 'package:provider/provider.dart';
import 'package:report/report.dart';
import 'package:teknisi_dashboard/teknisi_dashboard.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await HiveService().init();
  CloudinaryService().init(
    cloudName: 'dd9ziyeaj',
    uploadPreset: 'Lost_found_polban',
  );
  NetworkService().init(baseUrl: 'http://localhost:8081');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionController()),
        ChangeNotifierProvider(create: (_) => ReportController()),
        ChangeNotifierProvider(create: (_) => ClaimController()),
        ChangeNotifierProvider(create: (_) => NotificationController()),
        ChangeNotifierProvider(create: (_) => HomeController()), // Moved to top-level
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionController = context.watch<SessionController>();

    final router = GoRouter(
      initialLocation: '/login',
      refreshListenable: sessionController,
      redirect: (BuildContext context, GoRouterState state) {
        final isLoggedIn = sessionController.isLoggedIn;
        final isLoggingIn = state.uri.toString() == '/login';

        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }
        
        if (isLoggedIn && isLoggingIn) {
          return sessionController.isTeknisi ? '/teknisi-home' : '/home';
        }

        // If a teknisi tries to access /home, redirect to /teknisi-home
        if (isLoggedIn && sessionController.isTeknisi && state.uri.toString() == '/home') {
          return '/teknisi-home';
        }
        
        // If a regular user tries to access /teknisi-home, redirect to /home
        if (isLoggedIn && !sessionController.isTeknisi && state.uri.toString() == '/teknisi-home') {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/teknisi-home',
          builder: (context, state) => const TeknisiDashboardPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainScaffold(child: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => HomePageProvider(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/my-reports',
                  builder: (context, state) => const MyReportsProvider(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/user-claims',
                  builder: (context, state) => const UserClaimsPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfilePage(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/create-report',
          builder: (context, state) => const CreateReportProvider(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotifikasiPage(),
        ),
        GoRoute(
          path: '/report-post',
          builder: (context, state) => ReportPostPageProvider(item: state.extra),
        ),
        GoRoute(
          path: '/claim-queue',
          builder: (context, state) => const ClaimQueuePage(),
        ),
        GoRoute(
          path: '/verification',
          builder: (context, state) => VerificationPage(claim: state.extra as ClaimModel),
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'Polban Lost and Found',
      theme: AppTheme.lightTheme,
    );
  }
}
