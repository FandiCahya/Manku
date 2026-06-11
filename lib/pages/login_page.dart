import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/constants/colors.dart';
import '../constants/api_config.dart';
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  String _loadingMessage = 'Signing in...';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silakan masukkan email dan password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Signing in...';
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Save tokens and user data
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
          SnackBar(content: Text(data['message'] ?? 'Login berhasil!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        try {
          final data = jsonDecode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['error'] ?? 'Login gagal. Cek email dan password Anda.')),
          );
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login gagal.')),
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

  Future<void> _handleGoogleLogin() async {
    // Google Sign-In tidak didukung di Windows Desktop
    if (!kIsWeb && Platform.isWindows) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In hanya tersedia di Android, iOS, dan Web. Jalankan di emulator atau HP.'),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingMessage = 'Connecting with Google...';
    });

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        clientId: kIsWeb ? ApiConfig.googleClientId : null,
        serverClientId: kIsWeb ? null : ApiConfig.googleClientId,
        scopes: ['email', 'profile', 'openid'],
      ).signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return; // User canceled the sign-in
      }

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Di Flutter Web, terkadang signIn() hanya mengembalikan accessToken.
      // Kita coba panggil signInSilently() untuk mendapatkan idToken.
      if (kIsWeb && googleAuth.idToken == null) {
        final GoogleSignInAccount? silentUser = await GoogleSignIn(
          clientId: ApiConfig.googleClientId,
          scopes: ['email', 'profile', 'openid'],
        ).signInSilently();
        if (silentUser != null) {
          googleAuth = await silentUser.authentication;
        }
      }

      debugPrint('idToken: ${googleAuth.idToken}');
      debugPrint('accessToken: ${googleAuth.accessToken}');

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

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        debugPrint('Google Login Error - Status: ${response.statusCode}');
        debugPrint('Google Login Error - Body: ${response.body}');
        try {
          final data = jsonDecode(response.body);
          final errorMsg = data['error'] ?? data['detail'] ?? data['message'] ?? response.body;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('[${response.statusCode}] $errorMsg'),
              duration: Duration(seconds: 6),
            ),
          );
        } catch (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('[${response.statusCode}] ${response.body}')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          // ── Main Login Form ────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 48),
                  // Logo or Icon
                  Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: context.colors.primary,
                  ),
                  SizedBox(height: 24),
                  // Welcome Text
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: context.colors.onBackground,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sign in to manage your finances',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: 48),

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
                  SizedBox(height: 8),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text('Forgot Password?'),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: context.colors.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Sign In',
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

                  // Google Login Button
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleLogin,
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
                      'Sign in with Google',
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

                  // Register Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: context.colors.onSurfaceVariant),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegisterPage(),
                            ),
                          );
                        },
                        child: Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Loading Overlay ────────────────────────────────────────────
          AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: _isLoading
                ? _LoadingOverlay(message: _loadingMessage)
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// ── Loading Overlay Widget ─────────────────────────────────────────────────────
class _LoadingOverlay extends StatefulWidget {
  final String message;
  const _LoadingOverlay({required this.message});

  @override
  State<_LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<_LoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: context.colors.background.withOpacity(0.75),
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 44),
              margin: EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerLowest.withOpacity(0.95),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.primary.withOpacity(0.12),
                    blurRadius: 40,
                    spreadRadius: 4,
                    offset: Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: context.colors.outlineVariant.withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pulsing Icon + Spinner Stack
                  SizedBox(
                    width: 88,
                    height: 88,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer spinning ring
                        SizedBox(
                          width: 88,
                          height: 88,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              context.colors.primary.withOpacity(0.25),
                            ),
                          ),
                        ),
                        // Colored arc
                        SizedBox(
                          width: 88,
                          height: 88,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              context.colors.primary,
                            ),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        // Pulsing center icon
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: context.colors.primaryContainer.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.account_balance_wallet,
                              color: context.colors.primary,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28),

                  // Title
                  Text(
                    'Please wait',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: context.colors.onBackground,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Contextual message
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.colors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: 20),

                  // Animated dots
                  _AnimatedDots(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated Dots ──────────────────────────────────────────────────────────────
class _AnimatedDots extends StatefulWidget {
  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final phase = ((t - delay) % 1.0 + 1.0) % 1.0;
            final opacity = phase < 0.5
                ? (phase * 2).clamp(0.3, 1.0)
                : ((1.0 - phase) * 2).clamp(0.3, 1.0);
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.primary.withOpacity(opacity),
              ),
            );
          }),
        );
      },
    );
  }
}
