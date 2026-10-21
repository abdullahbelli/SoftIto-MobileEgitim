import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/app_constants.dart';
import 'app_theme.dart';

/// SharedPreferences provider'ı (main'de override edilecek)
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences başlatılmadı');
});

/// Tema Modu (Aydınlık / Karanlık / Sistem) yöneticisi
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;

  ThemeModeNotifier(this._prefs) : super(ThemeMode.system) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final saved = _prefs.getString(AppConstants.prefsKeyThemeMode);
    if (saved == 'light') {
      state = ThemeMode.light;
    } else if (saved == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    String val = 'system';
    if (mode == ThemeMode.light) val = 'light';
    if (mode == ThemeMode.dark) val = 'dark';
    await _prefs.setString(AppConstants.prefsKeyThemeMode, val);
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

/// Vurgu Rengi Yöneticisi
class AccentColorNotifier extends StateNotifier<Color> {
  final SharedPreferences _prefs;

  AccentColorNotifier(this._prefs) : super(AppTheme.defaultAccentColor) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final hexString = _prefs.getString(AppConstants.prefsKeyAccentColor);
    if (hexString != null) {
      final value = int.tryParse(hexString, radix: 16);
      if (value != null) {
        state = Color(value);
      }
    }
  }

  Future<void> setAccentColor(Color color) async {
    state = color;
    await _prefs.setString(
      AppConstants.prefsKeyAccentColor,
      color.toARGB32().toRadixString(16),
    );
  }
}

final accentColorProvider = StateNotifierProvider<AccentColorNotifier, Color>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AccentColorNotifier(prefs);
});
