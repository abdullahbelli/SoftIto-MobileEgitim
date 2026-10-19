import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uygulama temasını yöneten reaktif kontrolcü.
/// Durum değişiklikleri `ValueNotifier<ThemeMode>` ile dinlenir ve
/// kullanıcının tercihi `SharedPreferences` aracılığıyla kalıcı olarak saklanır.
class ThemeController {
  static const String _themePrefKey = 'user_theme_mode';

  final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  final SharedPreferences? _prefs;

  ThemeController([this._prefs]);

  /// Kaydedilmiş tema tercihini yerel depolamadan yükler.
  Future<void> init() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themePrefKey);

    if (savedTheme == 'dark') {
      themeMode.value = ThemeMode.dark;
    } else if (savedTheme == 'light') {
      themeMode.value = ThemeMode.light;
    } else {
      themeMode.value = ThemeMode.light;
    }
  }

  /// Temayı açık ve koyu arasında değiştirir.
  Future<void> toggleTheme() async {
    final nextMode =
        themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(nextMode);
  }

  /// Belirli bir tema modunu ayarlar ve kalıcı olarak kaydeder.
  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setString(
      _themePrefKey,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  /// Kaynakları serbest bırakır.
  void dispose() {
    themeMode.dispose();
  }
}
