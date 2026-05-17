import 'package:core_module/core_module.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider'; // Tambahkan import provider
import 'package:home/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService().init();

  CloudinaryService().init(
    cloudName: 'dd9ziyeaj',
    uploadPreset: 'Lost_found_polban',
  );

  //ubah sesuai IP
  NetworkService().init(baseUrl: 'http://192.168.1.14:8082');

  runApp(
    ChangeNotifierProvider(
      create: (_) => AdminStatController(),
      child: const MyApp(),
    ),
  );
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
      home: const HomePageProvider(),
    );
  }
}