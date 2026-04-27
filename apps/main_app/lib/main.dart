import 'package:core_module/core_module.dart';
import 'package:flutter/material.dart';
// import 'package:report/report.dart';
import 'package:home/home.dart';

void main() async {
  // Ensure that Flutter bindings are initialized before any async operations.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all core services.
  // 1. Hive for local caching
  await HiveService().init();

  // 2. Cloudinary for image uploads
  // TODO: IMPORTANT! Fill in your Cloudinary credentials here.
  CloudinaryService().init(
    cloudName: 'dd9ziyeaj',
    uploadPreset: 'Lost_found_polban',
  );

  // 3. Network service for API communication
  // This base URL points to the backend running on your local machine.
  // We use port 8081 to avoid conflict with the Apache server on 8080.
  NetworkService().init(baseUrl: 'http://127.0.0.1:8081');

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
        primaryColor: AppColors.primaryBlue, // Assuming AppColors is in core_module
        useMaterial3: true,
      ),
      // Use the Provider wrapper for MyReportsPage
      home: const HomePage(),
    );
  }
}