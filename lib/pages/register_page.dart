import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/constants/colors.dart';
import '../constants/api_config.dart';
import 'home_page.dart';
import 'otp_page.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'first_name': name,
          'email': email,
          'password': password,
        }),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Registration successful!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OtpPage(email: email)),
        );
      } else {
        try {
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['error'] ?? 'Registration failed.')),
          );
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed.')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error')),
      );
    }
  }

  Future<void> _handleGoogleRegister() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        clientId: kIsWeb ? ApiConfig.googleClientId : null,
        serverClientId: ApiConfig.googleClientId,
      ).signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return; // User canceled the sign-in
      }

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (kIsWeb && googleAuth.idToken == null) {
        final GoogleSignInAccount? silentUser = await GoogleSignIn(
          clientId: ApiConfig.googleClientId,
        ).signInSilently();
        if (silentUser != null) {
          googleAuth = await silentUser.authentication;
        }
      }

      final response = await http.post(
        Uri.parse(ApiConfig.googleLoginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'access_token': googleAuth.accessToken,
          'id_token': googleAuth.idToken ?? '',
        }),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        final prefs = await SharedPreferences.getInstance();
        if (data['tokens'] != null) {
          await prefs.setString('access_token', data['tokens']['access']);
          await prefs.setString('refresh_token', data['tokens']['refresh']);
        }
        
        // Simpan data dari Google SignIn (Prioritas utama)
        await prefs.setString('user_name', googleUser.displayName ?? data['user']?['name'] ?? 'User');
        await prefs.setString('user_email', googleUser.email);
        if (googleUser.photoUrl != null) {
          await prefs.setString('user_photo', googleUser.photoUrl!);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Google Login berhasil!')),
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
            SnackBar(content: Text(data['error'] ?? 'Google Login gagal.')),
          );
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Google Login gagal.')),
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
              // Welcome Text
              Text(
                'Create Account',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: context.colors.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 8),
              Text(
                'Sign up to get started',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
              ),
              SizedBox(height: 48),
              
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: context.colors.surfaceContainerLowest,
                ),
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: context.colors.surfaceContainerLowest,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              
              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: context.colors.surfaceContainerLowest,
                ),
              ),
              SizedBox(height: 32),
              
              // Register Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
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
                      'Sign Up',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
              ),
              SizedBox(height: 24),
              
              // Divider
              Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: context.colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              SizedBox(height: 24),
              
              // Google Register Button
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleGoogleRegister,
                icon: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                  height: 24,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.g_mobiledata,
                    size: 32,
                    color: Colors.red,
                  ),
                ),
                label: Text(
                  'Sign up with Google',
                  style: TextStyle(
                    fontSize: 16,
                    color: context.colors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: context.colors.outlineVariant),
                  backgroundColor: context.colors.surfaceContainerLowest,
                ),
              ),
              SizedBox(height: 48),
              
              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(color: context.colors.onSurfaceVariant),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Sign In'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
