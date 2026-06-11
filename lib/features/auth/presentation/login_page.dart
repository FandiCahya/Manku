import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/loading_overlay.dart';
import 'cubit/auth_cubit.dart';
import 'cubit/auth_state.dart';
import 'register_page.dart';
import 'otp_page.dart';
import '../../home/presentation/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ── Email / Password Login ──────────────────────────────────────────────────
  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnack('Silakan masukkan email dan password');
      return;
    }

    context.read<AuthCubit>().loginWithEmail(email: email, password: password);
  }

  // ── Google Login ────────────────────────────────────────────────────────────
  void _handleGoogleLogin() {
    if (!kIsWeb && Platform.isWindows) {
      _showSnack(
        'Google Sign-In hanya tersedia di Android, iOS, dan Web.',
        duration: 4,
      );
      return;
    }

    context.read<AuthCubit>().loginWithGoogle();
  }

  void _showSnack(String message, {int duration = 3}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: duration),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _showSnack('Login berhasil!');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(builder: (_) => const HomePage()),
          );
        } else if (state is AuthFailure) {
          _showSnack(state.error);
        } else if (state is AuthOtpSent) {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => OtpPage(email: state.email),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final loadingMessage = state is AuthLoading ? state.message : 'Signing in...';

        return Scaffold(
          backgroundColor: context.colors.background,
          body: Stack(
            children: [
              // Main login form
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 48),
                      Icon(
                        Icons.account_balance_wallet,
                        size: 80,
                        color: context.colors.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: context.colors.onBackground,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to manage your finances',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 48),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: context.colors.surfaceContainerLowest,
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: context.colors.surfaceContainerLowest,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text('Forgot Password?'),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Sign In button
                      ElevatedButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          foregroundColor: context.colors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: context.colors.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Google button
                      OutlinedButton.icon(
                        onPressed: isLoading ? null : _handleGoogleLogin,
                        icon: Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                          height: 24,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.g_mobiledata,
                            size: 32,
                            color: Colors.red,
                          ),
                        ),
                        label: Text(
                          'Sign in with Google',
                          style: TextStyle(
                            fontSize: 16,
                            color: context.colors.onBackground,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: context.colors.outlineVariant),
                          backgroundColor: context.colors.surfaceContainerLowest,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Register link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(color: context.colors.onSurfaceVariant),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                  builder: (_) => const RegisterPage()),
                            ),
                            child: const Text('Sign Up'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Loading overlay
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isLoading
                    ? LoadingOverlay(message: loadingMessage)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
