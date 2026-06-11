import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../data/auth_repository.dart';
import '../../domain/auth_models.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final name = prefs.getString('user_name');
      final email = prefs.getString('user_email');
      final photoUrl = prefs.getString('user_photo');

      if (accessToken != null && email != null) {
        emit(AuthAuthenticated(
          user: UserModel(
            name: name ?? 'User',
            email: email,
            photoUrl: photoUrl,
          ),
        ));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading(message: 'Signing in...'));
    try {
      final result = await AuthRepository.login(email: email, password: password);
      final user = result.user ?? UserModel(name: 'User', email: email);
      
      // Update local cache if missing
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_email', user.email);
      if (user.photoUrl != null) {
        await prefs.setString('user_photo', user.photoUrl!);
      }

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> loginWithGoogle() async {
    emit(const AuthLoading(message: 'Connecting with Google...'));
    try {
      final result = await AuthRepository.googleSignIn();
      if (result == null) {
        emit(AuthUnauthenticated()); // User cancelled
        return;
      }
      final user = result.user ?? const UserModel(name: 'Google User', email: '');
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading(message: 'Creating account...'));
    try {
      await AuthRepository.register(name: name, email: email, password: password);
      // After registration, send user to OTP page (if required)
      // The current flow sends a verification OTP to the user's email.
      emit(AuthOtpSent(email: email));
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> verifyOtp({
    required String email,
    required String code,
  }) async {
    emit(const AuthLoading(message: 'Verifying code...'));
    try {
      final result = await AuthRepository.verifyOtp(email: email, code: code);
      final user = result.user ?? UserModel(name: 'User', email: email);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_email', user.email);

      emit(AuthAuthenticated(user: user));
    } catch (e) {
      emit(AuthFailure(error: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> logout() async {
    emit(const AuthLoading(message: 'Logging out...'));
    try {
      await AuthRepository.logout();
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthFailure(error: e.toString()));
    }
  }
}
