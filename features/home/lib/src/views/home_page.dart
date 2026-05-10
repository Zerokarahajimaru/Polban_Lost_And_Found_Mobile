import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomHeader(
        title: 'Beranda',
        showBackButton: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_work_outlined,
              size: 100,
              color: AppColors.secondaryBlue,
            ),
            SizedBox(height: 20),
            Text(
              'Selamat Datang di Portal L&F',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
             Text(
              'Gunakan navigasi di bawah untuk melihat laporan atau profil Anda.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
