import 'package:flutter/material.dart'; // Flutter Material Design tema ve stil bileşenlerini içe aktarıyoruz.

/// Rotiva Material Design 3 tema yapılandırması.
/// - Light temada mavi tonları ve ferah yüzeyler;
/// - Dark temada antrasit arka plan ve turuncu vurgular kullanılır.
class AppTheme {
  // Light tema tohum rengi (Material 3 Seed: Kurumsal ve güven verici Mavi)
  static const Color lightSeedColor = Color(0xFF1764C0);

  // Dark tema tohum ve vurgusu (Enerjik ve okunaklı Turuncu ile Antrasit zemin)
  static const Color darkSeedColor = Color(0xFFFF922B);
  static const Color darkBackgroundColor = Color(
    0xFF15191F,
  ); // Koyu tema arka planı
  static const Color darkSurfaceColor = Color(
    0xFF1E242C,
  ); // Koyu tema yüzey rengi (AppBar, Menüler)
  static const Color darkCardColor = Color(
    0xFF242B35,
  ); // Koyu tema kart ve kutu zeminleri

  /// Açık Tema Yapılandırması (Light Theme)
  static ThemeData get lightTheme {
    // Seed color üzerinden dinamik ve uyumlu Material 3 renk şeması üretiyoruz
    final colorScheme = ColorScheme.fromSeed(
      seedColor: lightSeedColor,
      brightness: Brightness.light,
      primary: const Color(0xFF1565C0), // Birincil marka rengimiz (Mavi)
      secondary: const Color(0xFF0288D1), // İkincil destekleyici ton
      surface: const Color(0xFFF8FAFD), // Üst yüzey rengi
      surfaceContainerHighest: const Color(
        0xFFE8EEF5,
      ), // Vurgulu kart zeminleri
    );

    return ThemeData(
      useMaterial3: true, // Material Design 3 standartlarını etkinleştiriyoruz.
      colorScheme: colorScheme, // Üretilen renk şemasını bağlıyoruz.
      scaffoldBackgroundColor: const Color(
        0xFFF5F7FA,
      ), // Ekranların genel arka plan rengi.
      fontFamily: null, // Cihazın varsayılan sistem yazı tipini kullanıyoruz.
      // AppBar teması: Sayfa kaydırıldığında içerikle çakışmaması için scrolledUnderElevation ayarlıyoruz.
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation:
            2.0, // Sayfa kaydığında AppBar'ın altına gölge ve kontrast ekler.
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),
      // Kart Teması (Tüm Card widget'ları yuvarlatılmış ve hafif gölgeli olur)
      cardTheme: CardThemeData(
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      // Birincil Buton Teması (FilledButton)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      // Çerçeveli Buton Teması (OutlinedButton)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      // Form Girdi Alanları Teması (TextFormField & TextField)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
      // Alt Navigasyon Çubuğu Teması (NavigationBar)
      navigationBarTheme: NavigationBarThemeData(
        elevation: 2,
        backgroundColor: Colors.white,
        indicatorColor: colorScheme.primary.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          );
        }),
      ),
      // Etiket / Çip Teması (Chip & FilterChip)
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  /// Koyu Tema Yapılandırması (Dark Theme)
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: darkSeedColor,
      brightness: Brightness.dark,
      primary: const Color(
        0xFFFF922B,
      ), // Koyu temadaki ana aksan rengimiz (Turuncu)
      onPrimary: const Color(
        0xFF15191F,
      ), // Turuncu buton üzerindeki metin rengi
      secondary: const Color(0xFFFFAB5E),
      surface: darkSurfaceColor,
      surfaceContainerHighest: darkCardColor,
      onSurface: const Color(0xFFF1F3F5), // Koyu zemindeki açık metin rengi
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackgroundColor,
      // Koyu tema AppBar yapılandırması
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation:
            2.0, // Sayfa kaydığında içeriğin üstte çakışmasını engeller
        backgroundColor: darkSurfaceColor,
        foregroundColor: Color(0xFFF1F3F5),
        titleTextStyle: TextStyle(
          color: Color(0xFFF1F3F5),
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),
      // Koyu tema Card yapılandırması
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: darkCardColor,
      ),
      // Koyu tema FilledButton
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFFF922B),
          foregroundColor: const Color(0xFF15191F),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      // Koyu tema OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFF922B),
          side: const BorderSide(color: Color(0xFFFF922B)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      // Koyu tema girdi kutuları
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF374151)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF374151)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFFF922B), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
      // Koyu tema alt gezinme çubuğu
      navigationBarTheme: NavigationBarThemeData(
        elevation: 2,
        backgroundColor: darkSurfaceColor,
        indicatorColor: const Color(0xFFFF922B).withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF922B),
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade400,
          );
        }),
      ),
      // Koyu tema çipler
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: const BorderSide(color: Color(0xFF374151)),
        backgroundColor: darkCardColor,
      ),
    );
  }
}
