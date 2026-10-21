import 'package:flutter/material.dart'; // Flutter Material arayüz bileşenlerini ve ThemeMode enum yapısını içe aktarır.
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod StateNotifier ve StateNotifierProvider yapılarını içe aktarır.
import 'package:shared_preferences/shared_preferences.dart'; // Yerel veri saklama arayüzünü içe aktarır.

import '../../core/config/app_constants.dart'; // Kalıcı depolama anahtar sabitlerini içe aktarır.
import 'app_theme.dart'; // Varsayılan tema renklerini içeren AppTheme sınıfını içe aktarır.

/// SharedPreferences Riverpod provider'ı
/// Uygulama açılışında main() içinde 'overrideWithValue' ile gerçek SharedPreferences örneği atanır.
/// Başlatılmadan doğrudan erişilirse UnimplementedError fırlatarak hatayı bildirir.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences başlatılmadı',
  ); // Başlatılmamış bağımlılık uyarısı.
});

/// Tema Modu (Aydınlık / Karanlık / Sistem) yöneticisi
/// `StateNotifier<ThemeMode>`, değişebilir bir ThemeMode durumunu yöneten ve dinleyicilerine haber veren sınıftır.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences
  _prefs; // Cihaz hafızasına yazmak için SharedPreferences referansı.

  // Kurucu fonksiyon: Başlangıç durumunu ThemeMode.system yapar ve hafızadaki son tercihi yükler.
  ThemeModeNotifier(this._prefs) : super(ThemeMode.system) {
    _loadFromPrefs(); // Daha önce kaydedilmiş tema modunu SharedPreferences'tan okur.
  }

  // Hafızadan tema modunu okuyan özel (private) yardımcı fonksiyon.
  void _loadFromPrefs() {
    final saved = _prefs.getString(
      AppConstants.prefsKeyThemeMode,
    ); // Kayıtlı metni ('light'/'dark') çeker.
    // Kayıtlı metne göre duruma (state) uygun ThemeMode enum değerini atar.
    if (saved == 'light') {
      state = ThemeMode.light; // Açık tema durumunu ayarlar.
    } else if (saved == 'dark') {
      state = ThemeMode.dark; // Koyu tema durumunu ayarlar.
    } else {
      state = ThemeMode.system; // Sistem teması durumunu ayarlar.
    }
  }

  // Kullanıcının tema modunu değiştirmesini ve bu tercihi cihazda kalıcı hale getirmesini sağlar.
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode; // StateNotifier durumunu anında günceller; böylece UI hemen yenilenir.
    String val = 'system'; // Kaydedilecek varsayılan metin değeri.
    if (mode == ThemeMode.light)
      val = 'light'; // Açık tema için metin karşılığı.
    if (mode == ThemeMode.dark) val = 'dark'; // Koyu tema için metin karşılığı.
    await _prefs.setString(
      AppConstants.prefsKeyThemeMode,
      val,
    ); // Tercihi cihaz hafızasına yazar.
  }

  // Aydınlık ve karanlık modlar arasında tek tıkla hızlı geçiş yapılmasını sağlayan fonksiyon.
  Future<void> toggleTheme() async {
    // Mevcut durum koyu ise açığa, açık ise koyuya geçirir.
    if (state == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}

// ThemeModeNotifier sınıfını tüm uygulamaya sunan Riverpod StateNotifierProvider nesnesi.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  final prefs = ref.watch(
    sharedPreferencesProvider,
  ); // Kayıtlı tercihler nesnesini elde eder.
  return ThemeModeNotifier(prefs); // Sınıfın örneğini oluşturup döndürür.
});

/// Vurgu Rengi Yöneticisi
/// Uygulamanın birincil marka rengini (sarı/amber vb.) ve kullanıcı tercihlerini yönetir.
class AccentColorNotifier extends StateNotifier<Color> {
  final SharedPreferences _prefs; // Cihaz hafızasına erişim referansı.

  // Kurucu fonksiyon: Başlangıç rengi olarak AppTheme.defaultAccentColor belirler ve kayıtlı tercihi yükler.
  AccentColorNotifier(this._prefs) : super(AppTheme.defaultAccentColor) {
    _loadFromPrefs(); // Kayıtlı renk kodunu hafızadan okur.
  }

  // Cihaz hafızasından onaltılık (hex) renk kodunu yükleyen yardımcı metot.
  void _loadFromPrefs() {
    final hexString = _prefs.getString(
      AppConstants.prefsKeyAccentColor,
    ); // Kayıtlı hex string'i alır.
    if (hexString != null) {
      // Hex string'i 16 tabanında tam sayıya dönüştürür.
      final value = int.tryParse(hexString, radix: 16);
      if (value != null) {
        state = Color(
          value,
        ); // Sayısal değeri renge çevirerek durumu günceller.
      }
    }
  }

  // Yeni bir vurgu rengi seçildiğinde durumu günceller ve onaltılık kod olarak diske kaydeder.
  Future<void> setAccentColor(Color color) async {
    state = color; // UI'ı anında yeni renge güncellemek için durumu eşitler.
    // Rengin 32-bit ARGB değerini 16 tabanında string olarak kaydeder (Örn: "fff59e0b").
    await _prefs.setString(
      AppConstants.prefsKeyAccentColor,
      color.toARGB32().toRadixString(16),
    );
  }
}

// AccentColorNotifier sınıfını Riverpod aracılığıyla arayüze bağlayan sağlayıcı.
final accentColorProvider = StateNotifierProvider<AccentColorNotifier, Color>((
  ref,
) {
  final prefs = ref.watch(
    sharedPreferencesProvider,
  ); // SharedPreferences bağımlılığını çözer.
  return AccentColorNotifier(prefs); // Yeni AccentColorNotifier nesnesi üretir.
});
