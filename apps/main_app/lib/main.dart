import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:core_module/core_module.dart'; 
import 'package:main_app/features/report/presentation/pages/create_report_page.dart';
import 'package:main_app/features/report/presentation/pages/my_reports_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  
  final hiveService = HiveService();
  await hiveService.init();
  
  Hive.registerAdapter(ReportModelAdapter());
  Hive.registerAdapter(BountyModelAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Polban Lost and Found',
      theme: ThemeData(
        primaryColor: AppColors.primaryBlue, 
        useMaterial3: true
      ),
      home: MyReportsPage(),
    );
  }
}