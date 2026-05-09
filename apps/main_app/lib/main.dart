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
  // This base URL points to the backend running on the local network.
  // Use the backend host IP and port that the server exposes.
  NetworkService().init(baseUrl: 'http://192.168.1.14:8081');

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
        useMaterial3: true,
      ),
      // Use the Provider wrapper for the home page so HomeController and ReportController are available.
      home: const HomePageProvider(),
    );
  }
}