import 'package:core_module/core_module.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:login/login.dart';
import 'package:report/report.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    navigatorKey: _rootNavigatorKey,
    routes: [
      // Main application shell
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return HomePage(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const Center(child: Text('Home Content')), // Placeholder for real home
          ),
          GoRoute(
            path: '/reports',
            builder: (context, state) => const MyReportsProvider(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
      // Top-level routes that don't need the shell (e.g., login)
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
    ],
    // Redirect logic
    redirect: (BuildContext context, GoRouterState state) {
      final hiveService = HiveService();
      final bool loggedIn = hiveService.isLoggedIn();
      final bool loggingIn = state.matchedLocation == '/login';

      if (!loggedIn && !loggingIn) {
        return '/login'; // If not logged in and not on the login page, redirect to login
      }
      if (loggedIn && loggingIn) {
        return '/home'; // If logged in and on the login page, redirect to home
      }

      return null; // No redirect needed
    },
  );
}

// This will be the new Main Navigation Hub
class HomePage extends StatefulWidget {
  final Widget child;
  const HomePage({super.key, required this.child});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/reports')) {
      return 1;
    }
    if (location.startsWith('/claim')) {
      return 2;
    }
    if (location.startsWith('/profile')) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/home');
        break;
      case 1:
        GoRouter.of(context).go('/reports');
        break;
      case 2:
        // Placeholder for claim page
        GoRouter.of(context).go('/claim');
        break;
      case 3:
        GoRouter.of(context).go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryYellow,
        shape: const CircleBorder(
            side: BorderSide(color: AppColors.primaryBlue, width: 4)),
        onPressed: () {
          // TODO: Implement FAB action, maybe navigate to a 'create' page
        },
        child: Icon(Icons.add, color: AppColors.primaryBlue, size: 35),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: CustomBottomNav(
          currentIndex: _calculateSelectedIndex(context),
          onTap: (index) => _onItemTapped(index, context),
        ),
      ),
    );
  }
}
