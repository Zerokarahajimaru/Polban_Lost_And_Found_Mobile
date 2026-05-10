import 'package:core_module/core_module.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:home/home.dart';
import 'package:login/login.dart';
import 'package:provider/provider.dart';
import 'package:report/report.dart';
import 'main_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService().init();
  CloudinaryService().init(
    cloudName: 'dd9ziyeaj',
    uploadPreset: 'Lost_found_polban',
  );
  NetworkService().init(baseUrl: 'http://127.0.0.1:8081');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionController()),
        // Provide the ReportController here to be shared across tabs
        ChangeNotifierProvider(create: (_) => ReportController()),
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
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
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
                  builder: (context, state) => HomePage(),
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
      ],
    );

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      title: 'Polban Lost and Found',
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        useMaterial3: true,
      ),
    );
  }
}