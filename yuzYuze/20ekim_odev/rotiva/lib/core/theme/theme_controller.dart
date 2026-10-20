import 'package:flutter/material.dart'; // ChangeNotifier ve ThemeMode yapıları için Material kütüphanesini içe aktarıyoruz.
import 'package:shared_preferences/shared_preferences.dart'; // Tema tercihini cihazda kalıcı saklamak için SharedPreferences kullanıyoruz.

/// Rotiva tema modunu (Açık, Koyu, Sistem) yöneten ve kalıcı saklayan controller.
/// ChangeNotifier sınıfını miras alarak durum değişikliklerini dinleyen widget'lara haber verir.
class ThemeController extends ChangeNotifier {
  // SharedPreferences anahtarı (Key-Value veritabanında tema modu bu isimle saklanır)
  static const String _themePrefKey = 'rotiva_theme_mode';

  // Aktif tema modu (Varsayılan olarak cihazın sistem temasına uyar)
  ThemeMode _themeMode = ThemeMode.system;

  // Dışarıdan sadece okunabilmesi için kapsüllenmiş (encapsulated) getter
  ThemeMode get themeMode => _themeMode;

  /// Koyu temanın aktif olup olmadığını kontrol eden mantıksal getter
  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    // Sistem modu için varsayılan kontrol
    return false;
  }

  /// Uygulama ilk açıldığında SharedPreferences üzerinden kayıtlı temayı asenkron yükler.
  Future<void> loadTheme() async {
    try {
      // Yerel cihaz anahtar-değer deposuna bağlanıyoruz.
      final prefs = await SharedPreferences.getInstance();
      // Daha önceden kaydedilmiş tema metnini okuyoruz.
      final savedTheme = prefs.getString(_themePrefKey);
      if (savedTheme != null) {
        if (savedTheme == 'light') {
          _themeMode = ThemeMode.light;
        } else if (savedTheme == 'dark') {
          _themeMode = ThemeMode.dark;
        } else {
          _themeMode = ThemeMode.system;
        }
        // Dinleyicileri (UI ekranlarını) haberdar ederek arayüzün yeni temayla çizilmesini sağlıyoruz.
        notifyListeners();
      }
    } catch (_) {
      // Hata durumunda varsayılan sistem modunda sessizce devam edilir.
    }
  }

  /// Temayı değiştirir ve kullanıcının tercihini SharedPreferences'a kalıcı olarak yazar.
  Future<void> setThemeMode(ThemeMode mode) async {
    // Zaten seçili olan temaya tekrar tıklandıysa gereksiz render yapma
    if (_themeMode == mode) return;

    _themeMode = mode; // Yeni modu atıyoruz.
    notifyListeners(); // Ekranları anında yeni renklerle güncelliyoruz.

    try {
      final prefs = await SharedPreferences.getInstance();
      String modeStr = 'system';
      if (mode == ThemeMode.light) modeStr = 'light';
      if (mode == ThemeMode.dark) modeStr = 'dark';
      // String olarak saklıyoruz: 'light', 'dark' veya 'system'
      await prefs.setString(_themePrefKey, modeStr);
    } catch (_) {
      // SharedPreferences erişim hatası yok sayılır (bellekte çalışmaya devam eder)
    }
  }

  /// AppBar üzerindeki butonla Açık ve Koyu tema arasında tek dokunuşla hızlı geçiş yapar.
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}
