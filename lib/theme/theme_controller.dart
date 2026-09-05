import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

/// Holds the manager's light/dark preference, persists it, and keeps
/// [AppColors.dark] in sync so every screen (theme-driven or not) follows it.
class ThemeController {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  final ValueNotifier<bool> isDarkMode = ValueNotifier(false);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final dark = prefs.getBool('dark_mode') ?? false;
    AppColors.dark = dark;
    isDarkMode.value = dark;
  }

  Future<void> setDarkMode(bool value) async {
    AppColors.dark = value;
    isDarkMode.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
  }
}
