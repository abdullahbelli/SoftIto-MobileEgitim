import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Rotiva tema modunu (Açık, Koyu, Sistem) yöneten ve kalıcı saklayan controller.
class ThemeController extends ChangeNotifier {
  static const String _themePrefKey = 'rotiva_theme_mode';
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    // Sistem modu için varsayılan kontrol
    return false;
  }

  /// Başlangıçta SharedPreferences üzerinden kayıtlı temayı yükler.
  Future<void> loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themePrefKey);
      if (savedTheme != null) {
        if (savedTheme == 'light') {
          _themeMode = ThemeMode.light;
        } else if (savedTheme == 'dark') {
          _themeMode = ThemeMode.dark;
        } else {
          _themeMode = ThemeMode.system;
        }
        notifyListeners();
      }
    } catch (_) {
      // Hata durumunda varsayılan sistem modunda kalır.
    }
  }

  /// Temayı değiştirir ve kalıcı olarak kaydeder.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      String modeStr = 'system';
      if (mode == ThemeMode.light) modeStr = 'light';
      if (mode == ThemeMode.dark) modeStr = 'dark';
      await prefs.setString(_themePrefKey, modeStr);
    } catch (_) {
      // SharedPreferences erişim hatası yok sayılır
    }
  }

  /// Açık ve Koyu tema arasında hızlı geçiş yapar.
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}
