import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';
import 'home_page.dart';

// ========================
// HALAMAN UTAMA (HOME) - PROVIDER WRAPPER
// ========================
class HomePageProvider extends StatelessWidget {
  const HomePageProvider({super.key});

  @override
  Widget build(BuildContext context) {
    // HomeController is now provided at the top level in main.dart
    return const HomePage();
  }
}
