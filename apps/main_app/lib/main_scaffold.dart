import 'package:core_module/core_module.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final sessionController = context.watch<SessionController>();
    final isTeknisi = sessionController.isTeknisi;

    return Scaffold(
      body: child,
      floatingActionButton: isTeknisi 
          ? null 
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  backgroundColor: AppColors.primaryYellow,
                  shape: const CircleBorder(
                      side: BorderSide(color: AppColors.primaryBlue, width: 4)),
                  onPressed: () => GoRouter.of(context).push('/create-report'),
                  child: const Icon(Icons.add, color: AppColors.primaryBlue, size: 35),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Lapor',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
              padding: EdgeInsets.zero,
              notchMargin: 8,
              shape: const CircularNotchedRectangle(),
              child: CustomBottomNav(
                currentIndex: _calculateSelectedIndex(context),
                isTeknisi: isTeknisi,
                onTap: (index) => _onItemTapped(index, context, isTeknisi),
              ),
            ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/my-reports')) {
      return 1;
    }
    if (location.startsWith('/claim-queue') || location.startsWith('/user-claims')) {
      return 3;
    }
    if (location.startsWith('/profile')) {
      return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context, bool isTeknisi) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/home');
        break;
      case 1:
        GoRouter.of(context).go('/my-reports');
        break;
      case 3:
        if (isTeknisi) {
          GoRouter.of(context).go('/claim-queue');
        } else {
          GoRouter.of(context).go('/user-claims');
        }
        break;
      case 4:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}
