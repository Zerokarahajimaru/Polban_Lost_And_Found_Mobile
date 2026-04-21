import 'package:flutter/material.dart';
import 'package:main_app/features/report/presentation/pages/create_report_page.dart';

import 'package:core_module/core_module.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan label 'Debug' di pojok
      title: 'Polban Lost and Found',
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue,
        useMaterial3: true,
      ),
      home: const CreateReportPage(),
    );
  }
}
