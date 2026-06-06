import 'package:flutter/material.dart';
import 'package:core_module/core_module.dart';
import 'package:provider/provider.dart';
import '../controllers/login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginController(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _performLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      NotificationBanner.show(context, 'Email dan password tidak boleh kosong.', isError: true);
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      NotificationBanner.show(context, 'Format email tidak valid.', isError: true);
      return;
    }

    final loginController = context.read<LoginController>();
    final sessionController = context.read<SessionController>();

    final success = await loginController.login(email, password);

    if (mounted && success) {
      sessionController.login(loginController.loggedInUser!);
    }

    if (mounted && loginController.state == NotifierState.error) {
      NotificationBanner.show(context, loginController.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<LoginController>();
    final isLoading = controller.state == NotifierState.loading;

    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: SingleChildScrollView(
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
              const SizedBox(height: 48),
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
                    const SizedBox(height: AppTheme.kPaddingSmall),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: AppColors.primaryBlue,
                      ),
                      onPressed: isLoading ? null : _performLogin,
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("MASUK PORTAL"),
                    ),
                    const SizedBox(height: AppTheme.kPadding),
                    TextButton(
                      onPressed: () => _showResetPasswordDialog(context),
                      child: Text(
                        "Lupa password?",
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetPasswordDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppTheme.kPaddingLarge),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(AppTheme.kRadiusLarge),
            border: Border.all(color: AppColors.secondaryBlue.withOpacity(0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.secondaryBlue,
                radius: 28,
                child: Icon(Icons.email_outlined, color: AppColors.primaryBlue, size: 28),
              ),
              const SizedBox(height: AppTheme.kPadding),
              Text(
                "RESET PASSWORD",
                style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: AppTheme.kPaddingSmall),
              Text(
                "Masukkan email Anda untuk menerima tautan pemulihan kata sandi",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: AppTheme.kPaddingLarge),
              const CustomTextField(
                label: "Email",
                hint: "contoh@polban.ac.id",
              ),
              const SizedBox(height: AppTheme.kPaddingLarge),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("BATAL", style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                  const SizedBox(width: AppTheme.kPadding),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: AppColors.primaryBlue,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("KIRIM"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}