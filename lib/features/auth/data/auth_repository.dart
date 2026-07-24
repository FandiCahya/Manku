import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/api_config.dart';
import '../../../core/network/api_client.dart';
import '../domain/auth_models.dart';

/// Repository for all authentication HTTP calls using Dio client.
/// Presentation layer should only call this class — never call network clients directly.
class AuthRepository {
  AuthRepository._();

  // ── Email / Password Login ─────────────────────────────────────────────────
  static Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.post<Map<String, dynamic>>(
        ApiConfig.loginEndpoint,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        final tokens = TokenModel.fromJson(
          data['tokens'] as Map<String, dynamic>,
        );
        final user = data['user'] != null
            ? UserModel.fromJson(data['user'] as Map<String, dynamic>)
            : null;
        await _persistSession(tokens: tokens, user: user);
        return AuthResult(
          tokens: tokens,
          user: user,
          message: data['message'] as String?,
        );
      }
      throw Exception('Login gagal (${response.statusCode})');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Login gagal');
    }
  }

  // ── Register ───────────────────────────────────────────────────────────────
  static Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.post<Map<String, dynamic>>(
        ApiConfig.registerEndpoint,
        data: {
          'first_name': name,
          'email': email,
          'password': password,
        },
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        return response.data!['message'] as String?;
      }
      throw Exception('Registrasi gagal (${response.statusCode})');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Registrasi gagal');
    }
  }

  // ── OTP Verify ─────────────────────────────────────────────────────────────
  static Future<AuthResult> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      final response = await ApiClient.dio.post<Map<String, dynamic>>(
        ApiConfig.verifyOtpEndpoint,
        data: {'email': email, 'code': code},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        final tokens = TokenModel.fromJson(
          data['tokens'] as Map<String, dynamic>,
        );
        final user = data['user'] != null
            ? UserModel.fromJson(data['user'] as Map<String, dynamic>)
            : null;
        await _persistSession(tokens: tokens, user: user);
        return AuthResult(
          tokens: tokens,
          user: user,
          message: data['message'] as String?,
        );
      }
      throw Exception('Verifikasi gagal (${response.statusCode})');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Verifikasi gagal');
    }
  }

  // ── Google Sign-In ─────────────────────────────────────────────────────────
  static Future<AuthResult?> googleSignIn() async {
    GoogleSignInAuthentication? googleAuth;
    GoogleSignInAccount? googleUser;

    googleUser = await GoogleSignIn(
      clientId: kIsWeb ? ApiConfig.googleClientId : null,
      serverClientId: kIsWeb ? null : ApiConfig.googleClientId,
      scopes: ['email', 'profile', 'openid'],
    ).signIn();

    if (googleUser == null) return null; // User cancelled

    googleAuth = await googleUser.authentication;

    // On web, silently refresh to get idToken if missing
    if (kIsWeb && googleAuth.idToken == null) {
      final silentUser = await GoogleSignIn(
        clientId: ApiConfig.googleClientId,
        scopes: ['email', 'profile', 'openid'],
      ).signInSilently();
      if (silentUser != null) {
        googleAuth = await silentUser.authentication;
      }
    }

    debugPrint('Google idToken: ${googleAuth.idToken}');
    debugPrint('Google accessToken: ${googleAuth.accessToken}');

    try {
      final response = await ApiClient.dio.post<Map<String, dynamic>>(
        ApiConfig.googleLoginEndpoint,
        data: {
          'access_token': googleAuth.accessToken ?? '',
          'id_token': googleAuth.idToken ?? '',
        },
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        final data = response.data!;
        final tokens = TokenModel.fromJson(
          data['tokens'] as Map<String, dynamic>,
        );

        // Prefer Google profile data over backend response
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', tokens.access);
        await prefs.setString('refresh_token', tokens.refresh);
        await prefs.setString(
          'user_name',
          googleUser.displayName ??
              ((data['user'] as Map<String, dynamic>?)?['name'] as String?) ??
              'User',
        );
        await prefs.setString('user_email', googleUser.email);
        if (googleUser.photoUrl != null) {
          await prefs.setString('user_photo', googleUser.photoUrl!);
          debugPrint('📸 Saved Google photo URL: ${googleUser.photoUrl}');
        } else {
          debugPrint('⚠️ Google photo URL is null');
        }

        final user = UserModel(
          name: googleUser.displayName ?? '',
          email: googleUser.email,
          photoUrl: googleUser.photoUrl,
        );

        return AuthResult(
          tokens: tokens,
          user: user,
          message: data['message'] as String?,
        );
      }
      throw Exception('Google Login gagal (${response.statusCode})');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Google Login gagal');
    }
  }

  // ── Session helpers ────────────────────────────────────────────────────────
  static Future<void> _persistSession({
    required TokenModel tokens,
    UserModel? user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', tokens.access);
    await prefs.setString('refresh_token', tokens.refresh);
    if (user != null) {
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_email', user.email);
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_photo');
  }

  // ── Utility ────────────────────────────────────────────────────────────────
  static Exception _handleDioError(DioException error, String fallbackMessage) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final errMsg = responseData['error'] ??
          responseData['detail'] ??
          responseData['message'];
      if (errMsg != null) {
        return Exception(errMsg.toString());
      }
    }
    return Exception(
      '$fallbackMessage (${error.response?.statusCode ?? 'Koneksi error'})',
    );
  }
  static Future<Map<String, dynamic>> updateProfile({
    required String firstName,
    required String email,
  }) async {
    try {
      final response = await ApiClient.dio.put<Map<String, dynamic>>(
        ApiConfig.profileUpdateEndpoint,
        data: {'first_name': firstName, 'email': email},
      );
      if (response.statusCode == 200 && response.data != null) {
        // Update stored user details if needed
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', firstName);
        await prefs.setString('user_email', email);
        return response.data!;
      }
      throw Exception('Update profil gagal');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Update profil gagal');
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await ApiClient.dio.post<Map<String, dynamic>>(
        ApiConfig.changePasswordEndpoint,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data!;
      }
      throw Exception('Ganti password gagal');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Ganti password gagal');
    }
  }

  static Future<Map<String, dynamic>> toggle2FA(bool isEnabled) async {
    try {
      final response = await ApiClient.dio.post<Map<String, dynamic>>(
        ApiConfig.toggle2FAEndpoint,
        data: {'is_2fa_enabled': isEnabled},
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data!;
      }
      throw Exception('Toggle 2FA gagal');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Toggle 2FA gagal');
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await ApiClient.dio.get<Map<String, dynamic>>(
        ApiConfig.profileUpdateEndpoint,
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data!;
      }
      throw Exception('Gagal mengambil profil');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Gagal mengambil profil');
    }
  }
}
