import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/storage_service.dart';

/// Tema ve renk tercihlerini yöneten MVC Controller sınıfı.
/// UI durumunu güncellemek için ChangeNotifier kullanır ve
/// kullanıcının tercihlerini yerel hafızaya kaydeder.
class ThemeController extends ChangeNotifier {
  final StorageService _storageService;

  ThemeMode _themeMode = ThemeMode.system;
  String _accentColorKey = 'pink';

  ThemeController(this._storageService) {
    _loadFromStorage();
  }

  ThemeMode get themeMode => _themeMode;
  String get accentColorKey => _accentColorKey;

  Color get currentAccentColor {
    return AppColors.accentColors[_accentColorKey] ?? AppColors.lightPrimary;
  }

  void _loadFromStorage() {
    final modeStr = _storageService.getThemeMode();
    _themeMode = switch (modeStr) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    _accentColorKey = _storageService.getAccentColor();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    final modeStr = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _storageService.setThemeMode(modeStr);
  }

  Future<void> setAccentColor(String key) async {
    if (_accentColorKey == key) return;
    _accentColorKey = key;
    notifyListeners();
    await _storageService.setAccentColor(key);
  }
}
