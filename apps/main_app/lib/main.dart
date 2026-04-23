import 'package:flutter/material.dart';
import 'package:main_app/features/report/presentation/pages/create_report_page.dart';
import 'package:firebase_core/firebase_core.dart'; // Import firebase_core
import 'firebase_options.dart'; // Assuming this file exists and contains DefaultFirebaseOptions

import 'package:core_module/core_module.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import hive_flutter for initFlutter

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive
  final hiveService = HiveService();
  await hiveService.init();
  // Register adapters
  Hive.registerAdapter(ReportModelAdapter());
  Hive.registerAdapter(BountyModelAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menghilangkan label 'Debug' di pojok
      title: 'Polban Lost and Found',
      theme: ThemeData(primaryColor: AppColors.primaryBlue, useMaterial3: true),
      home: const CreateReportPage(),
    );
  }
}