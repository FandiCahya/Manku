import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/colors.dart';
import '../constants/api_config.dart';
import 'home_page.dart';
import 'package:pinput/pinput.dart';

class OtpPage extends StatefulWidget {
  final String email;

  OtpPage({super.key, required this.email});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tolong masukkan kode OTP')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.verifyOtpEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'code': otp,
        }),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Save tokens
        final prefs = await SharedPreferences.getInstance();
        if (data['tokens'] != null) {
          await prefs.setString('access_token', data['tokens']['access']);
          await prefs.setString('refresh_token', data['tokens']['refresh']);
        }
        if (data['user'] != null) {
          await prefs.setString('user_name', data['user']['name'] ?? '');
          await prefs.setString('user_email', data['user']['email'] ?? '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Verifikasi berhasil!')),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
        );
      } else {
        try {
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['error'] ?? 'Verifikasi gagal. Cek kode Anda.')),
          );
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verifikasi gagal.')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan koneksi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16),
              Text(
                'Verifikasi OTP',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: context.colors.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 8),
              Text(
                'Masukkan kode OTP yang dikirim ke\n${widget.email}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
              ),
              SizedBox(height: 48),
              
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
                onCompleted: (pin) {
                  _handleVerifyOtp();
                },
              ),
              SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _handleVerifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    )
                  : Text(
                      'Verifikasi',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}
