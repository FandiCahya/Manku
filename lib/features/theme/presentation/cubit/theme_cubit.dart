import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final SharedPreferences prefs;

  ThemeCubit(this.prefs) : super(_loadTheme(prefs));

  static ThemeMode _loadTheme(SharedPreferences prefs) {
    final themeIndex = prefs.getInt('theme_mode');
    if (themeIndex == null) return ThemeMode.system;
    return ThemeMode.values[themeIndex];
  }

  void updateTheme(ThemeMode mode) {
    prefs.setInt('theme_mode', mode.index);
    emit(mode);
  }
}
