import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isNotifOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          padding: const EdgeInsets.only(top: 40, left: 20, right: 20),
          decoration: const BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Profil Pengguna", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              Stack(
                children: [
                  const Icon(Icons.notifications_outlined, color: AppColors.primaryYellow, size: 30),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: const Text("3", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.primaryYellow, borderRadius: BorderRadius.circular(30)),
                  child: const Icon(Icons.person, size: 80, color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 15),
                const Text("Cheng Xiaoshi", style: TextStyle(color: AppColors.primaryBlue, fontSize: 24, fontWeight: FontWeight.w900)),
                const Text("xiaoshi@polban.ac.id", style: TextStyle(color: Colors.blueAccent, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(20)),
                  child: const Text("MAHASISWA", style: TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.blue.shade100, width: 1.5),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_none, color: AppColors.primaryBlue),
                  title: const Text("NOTIFIKASI APP", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w900, fontSize: 14)),
                  trailing: Switch(
                    value: isNotifOn,
                    onChanged: (val) => setState(() => isNotifOn = val),
                    activeColor: Colors.greenAccent,
                  ),
                ),
                const Divider(indent: 20, endIndent: 20),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("KELUAR PORTAL", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w900, fontSize: 14)),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            backgroundColor: AppColors.primaryYellow,
            shape: const CircleBorder(side: BorderSide(color: AppColors.primaryBlue, width: 4)),
            onPressed: () {},
            child: const Icon(Icons.add, color: AppColors.primaryBlue, size: 35),
          ),
          const SizedBox(height: 4),
          const Text("Lapor", style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: CustomBottomNav(
          currentIndex: 4,
          onTap: (index) {
            if (index != 4) Navigator.pop(context);
          },
        ),
      ),
    );
  }
}