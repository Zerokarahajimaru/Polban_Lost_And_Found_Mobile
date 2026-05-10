import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isNotifOn = true;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final user = session.currentUser;

    // A fallback for the unlikely case that a user gets here without being logged in.
    if (user == null) {
      return const Center(child: Text("Tidak ada data pengguna."));
    }

    return Column(
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
              Text(user.name, style: const TextStyle(color: AppColors.primaryBlue, fontSize: 24, fontWeight: FontWeight.w900)),
              Text(user.email, style: const TextStyle(color: Colors.blueAccent, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(20)),
                child: Text(user.role.toUpperCase(), style: const TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold, fontSize: 12)),
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
                onTap: () async {
                  final bool? confirmLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Konfirmasi Keluar'),
                      content: const Text('Apakah Anda yakin ingin keluar dari portal?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Keluar', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (confirmLogout == true && context.mounted) {
                    context.read<SessionController>().logout();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}