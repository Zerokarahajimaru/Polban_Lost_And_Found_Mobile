import 'package:core_module/core_module.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:go_router/go_router.dart';
import 'package:home/home.dart';
import 'package:login/login.dart';
import 'package:provider/provider.dart';
import 'package:report/report.dart';
import 'package:teknisi_dashboard/teknisi_dashboard.dart';

import 'main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // INIT LOCALE INDONESIA
  await initializeDateFormatting('id_ID', null);

  // INIT HIVE
  await HiveService().init();

  // INIT CLOUDINARY
  CloudinaryService().init(
    cloudName: 'dd9ziyeaj',
    uploadPreset: 'Lost_found_polban',
  );

  // INIT API — port 8888 sesuai backend/.env
  NetworkService().init(
    baseUrl: 'http://127.0.0.1:8888',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SessionController(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReportController(),
        ),
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
        final location = state.uri.toString();
        final isLoggingIn = location == '/login';

        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }

        if (isLoggedIn && isLoggingIn) {
          // Redirect berdasarkan role
          if (sessionController.isTeknisi) {
            return '/teknisi-dashboard';
          }
          return '/home';
        }

        return null;
      },

      routes: [
        // LOGIN
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),

        // DASHBOARD TEKNISI
        GoRoute(
          path: '/teknisi-dashboard',
          builder: (context, state) => const TeknisiDashboardPage(),
        ),

        // USER SHELL 
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainScaffold(child: navigationShell);
          },
          branches: [
            // HOME — index 0
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => HomePage(),
                ),
              ],
            ),
            // MY REPORTS — index 1
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/my-reports',
                  builder: (context, state) => const MyReportsProvider(),
                ),
              ],
            ),
            // PROFILE — index 2
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

        // CREATE REPORT 
        GoRoute(
          path: '/create-report',
          builder: (context, state) => const CreateReportProvider(),
        ),
      ],
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'Polban Lost and Found',
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        useMaterial3: true,
      ),
    );
  }
}
