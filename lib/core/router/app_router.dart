import 'package:flutter/material.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/home/presentation/home_page.dart';

/// Centralized route definitions for the app.
class AppRouter {
  AppRouter._();

  static const String login    = '/login';
  static const String register = '/register';
  static const String home     = '/home';

  static Map<String, WidgetBuilder> get routes => {
    login:    (_) => const LoginPage(),
    register: (_) => const RegisterPage(),
    home:     (_) => const HomePage(),
  };
}
