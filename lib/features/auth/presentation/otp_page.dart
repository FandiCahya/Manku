import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';
import '../../../core/constants/colors.dart';
import 'cubit/auth_cubit.dart';
import 'cubit/auth_state.dart';
import '../../home/presentation/home_page.dart';

class OtpPage extends StatefulWidget {
  final String email;

  const OtpPage({required this.email, super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _otpController = TextEditingController();

  void _handleVerifyOtp() {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      _showSnack('Tolong masukkan kode OTP');
      return;
    }

    context.read<AuthCubit>().verifyOtp(email: widget.email, code: otp);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _showSnack('Verifikasi berhasil!');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<void>(builder: (_) => const HomePage()),
            (route) => false,
          );
        } else if (state is AuthFailure) {
          _showSnack(state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: context.colors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: context.colors.onBackground),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Verifikasi OTP',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: context.colors.onBackground,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Masukkan kode OTP yang dikirim ke\n${widget.email}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 48),

                  Pinput(
                    length: 6,
                    controller: _otpController,
                    defaultPinTheme: PinTheme(
                      width: 56,
                      height: 60,
                      textStyle: TextStyle(
                        fontSize: 24,
                        color: context.colors.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceContainerLowest,
                        border: Border.all(color: context.colors.outlineVariant),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 56,
                      height: 60,
                      textStyle: TextStyle(
                        fontSize: 24,
                        color: context.colors.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceContainerLowest,
                        border: Border.all(color: context.colors.primary, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    submittedPinTheme: PinTheme(
                      width: 56,
                      height: 60,
                      textStyle: TextStyle(
                        fontSize: 24,
                        color: context.colors.onBackground,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: BoxDecoration(
                        color: context.colors.surfaceContainerLowest,
                        border: Border.all(color: context.colors.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onCompleted: (_) => _handleVerifyOtp(),
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: isLoading ? null : _handleVerifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: context.colors.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Verifikasi',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}
