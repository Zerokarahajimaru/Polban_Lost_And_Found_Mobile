import 'package:core_module/core_module.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/register_controller.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: ChangeNotifierProvider(
        create: (_) => RegisterController(),
        child: const _RegisterView(),
      ),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _performRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      NotificationBanner.show(context, 'Semua field harus diisi.', isError: true);
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      NotificationBanner.show(context, 'Format email tidak valid.', isError: true);
      return;
    }

    if (password != confirmPassword) {
      NotificationBanner.show(context, 'Konfirmasi password tidak cocok.', isError: true);
      return;
    }

    final controller = context.read<RegisterController>();
    final success = await controller.register(
      name: name,
      email: email,
      password: password,
    );

    if (mounted) {
      if (success) {
        NotificationBanner.show(context, 'Registrasi berhasil! Silakan login.', isError: false);
        context.go('/login');
      } else {
        NotificationBanner.show(context, controller.message, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<RegisterController>();
    final isLoading = controller.state == NotifierState.loading;

    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.kPaddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "HIMAKOM L&F",
              style: theme.textTheme.headlineLarge?.copyWith(
                color: AppColors.primaryYellow,
                fontSize: 36,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              "Portal Lost & Found Himakom",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(AppTheme.kPaddingLarge),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.kRadiusLarge),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  CustomTextField(
                    label: "Nama Lengkap",
                    hint: "Masukkan nama lengkap",
                    controller: _nameController,
                  ),
                  CustomTextField(
                    label: "Email Kampus",
                    hint: "contoh@polban.ac.id",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  CustomTextField(
                    label: "Password",
                    hint: "••••••••",
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  CustomTextField(
                    label: "Konfirmasi Password",
                    hint: "••••••••",
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  const SizedBox(height: AppTheme.kPaddingSmall),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: AppColors.primaryBlue,
                    ),
                    onPressed: isLoading ? null : _performRegister,
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("DAFTAR AKUN"),
                  ),
                  const SizedBox(height: AppTheme.kPadding),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      "Sudah punya akun? Masuk",
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
