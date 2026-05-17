import 'package:core_module/core_module.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:report/report.dart';
// import 'package:home/home.dart';
import 'package:inventaris/inventaris.dart';

void main() async {
  // Ensure that Flutter bindings are initialized before any async operations.
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService().init();

  CloudinaryService().init(
    cloudName: 'dd9ziyeaj',
    uploadPreset: 'Lost_found_polban',
  );

  // ini ip laptop soalnya di tes pake hp fisik, jadi harus pake ip laptop, nanti bisa diubah lagi sesuai kebutuhan
  NetworkService().init(baseUrl: 'http://192.168.1.5:8082');

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
      // Use the Provider wrapper for the home page so controllers are available.
          home: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => InventarisController()),
            ],
            child: const InventarisPage(),
          ),
    );
  }
}