import 'package:flutter/material.dart'; // Flutter Material Design görsel tasarım kütüphanesini içe aktarır.

/// BoardConnect merkezi tema yapılandırması
/// Bu sınıf, uygulamanın açık (light) ve koyu (dark) temalarını Material 3 standartlarında dinamik olarak üretir.
class AppTheme {
  // Varsayılan sıcak sarı / amber vurgu rengi (proje isterlerinde belirtilen birincil marka rengi).
  static const Color defaultAccentColor = Color(
    0xFFF59E0B,
  ); // Amber 500 renk kodu.

  // Alternatif vurgu renkleri (kullanıcının ayarlar sayfasından temayı özelleştirebilmesi için sunulan renk paleti).
  static const List<Color> accentColorOptions = [
    Color(0xFFF59E0B), // Amber / Sıcak Sarı
    Color(0xFFEAB308), // Altın Sarısı
    Color(0xFFF97316), // Sıcak Turuncu
    Color(0xFF10B981), // Zümrüt Yeşili
    Color(0xFF3B82F6), // Okyanus Mavisi
    Color(0xFF8B5CF6), // Mor
  ];

  /// Açık tema konfigürasyonunu oluşturan statik fonksiyon
  /// [accentColor]: Kullanıcının tercih ettiği birincil vurgu rengi
  static ThemeData light(Color accentColor) {
    // Material 3 renk paletini tek bir tohum (seed) renkten matematiksel olarak türetir.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor, // Paletin üretileceği ana referans rengi.
      brightness: Brightness.light, // Açık tonlama modunu belirtir.
      primary: accentColor, // Birincil eylem ve odaklanma rengi.
      surface: const Color(
        0xFFF8FAFC,
      ), // Kart ve sayfa yüzeylerinin temel zemin rengi.
      surfaceContainerHighest: const Color(
        0xFFEDF2F7,
      ), // Vurgulu arka plan ve ikincil zemin rengi.
    );

    // Açık temaya ait tüm görsel parametreleri içeren ThemeData nesnesini döndürür.
    return ThemeData(
      useMaterial3:
          true, // Google Material Design 3 tasarım sistemini etkinleştirir.
      brightness:
          Brightness.light, // Temanın açık renk modunda olduğunu bildirir.
      colorScheme: colorScheme, // Yukarıda oluşturulan renk şemasını bağlar.
      scaffoldBackgroundColor: const Color(
        0xFFF8FAFC,
      ), // Ekranların (Scaffold) varsayılan arka plan rengi.
      fontFamily: 'Roboto', // Uygulama genelinde kullanılacak varsayılan yazı tipi ailesi.
      // Ekran üst barlarının (AppBar) genel stil ayarları.
      appBarTheme: AppBarTheme(
        elevation:
            0, // Düz tasarım için varsayılan gölge yüksekliğini sıfırlar.
        scrolledUnderElevation:
            1, // Sayfa kaydırıldığında oluşan hafif derinlik gölgesi.
        backgroundColor: Colors.white, // Üst barın zemin rengini beyaz yapar.
        foregroundColor: const Color(
          0xFF0F172A,
        ), // Üst bardaki metin ve simgelerin rengi (koyu lacivert).
        surfaceTintColor: Colors.transparent, // Material 3'ün otomatik yüzey renk tonlamasını kaldırır.
        shape: Border(
          // Üst barın altına ince, zarif bir sınır çizgisi çizer.
          bottom: BorderSide(
            color: Colors.grey.withValues(
              alpha: 0.15,
            ), // %15 opaklıkta gri kenarlık.
            width: 1, // Kenarlık kalınlığı.
          ),
        ),
      ),
      // Kart bileşenlerinin (Card) genel stil ayarları.
      cardTheme: CardThemeData(
        elevation: 0, // Kart gölgesini sıfırlayarak modern konturlu (outlined) görünüm sağlar.
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            16,
          ), // Kart köşelerine 16 birimlik yuvarlatma uygular.
          side: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ), // İnce kenarlık çizgisi.
        ),
        color: Colors.white, // Kart içi arka plan rengi.
      ),
      // Metin giriş alanlarının (TextField / TextFormField) varsayılan dekorasyon ayarları.
      inputDecorationTheme: InputDecorationTheme(
        filled: true, // Giriş alanının arka planının boyanacağını belirtir.
        fillColor: Colors.white, // Giriş kutusunun arka plan rengi.
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18, // Giriş alanı içi yatay boşluk.
          vertical: 16, // Giriş alanı içi dikey boşluk.
        ),
        // Genel kenarlık stili.
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            12,
          ), // 12 birimlik yuvarlatılmış köşe.
          borderSide: BorderSide(
            color: Colors.grey.withValues(alpha: 0.3),
          ), // İnce gri kenarlık.
        ),
        // Odaklanılmamış (etkin) durumdaki kenarlık stili.
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        // Kullanıcı alana dokunduğundaki (odaklandığındaki) kenarlık stili.
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: accentColor,
            width: 2,
          ), // Vurgu renginde 2 birim kalın kenarlık.
        ),
        // Doğrulama hatası oluştuğundaki kenarlık stili.
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.5,
          ), // Kırmızı uyarı kenarlığı.
        ),
      ),
      // Vurgulu butonların (ElevatedButton) varsayılan stil ayarları.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0, // Buton gölgesini kaldırır.
          backgroundColor:
              accentColor, // Butonun arka plan rengini vurgu rengi yapar.
          foregroundColor:
              Colors.black, // Buton üzerindeki yazı ve simgelerin rengi.
          minimumSize: const Size.fromHeight(
            50,
          ), // Butonun yüksekliğini en az 50 birim yapar ve genişletir.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              12,
            ), // Buton köşelerini yuvarlatır.
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ), // Kalın ve okunaklı yazı stili.
        ),
      ),
      // Çerçeveli ikincil butonların (OutlinedButton) varsayılan stil ayarları.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(
            50,
          ), // Yüksekliği en az 50 birim yapar.
          side: BorderSide(
            color: Colors.grey.withValues(alpha: 0.3),
          ), // İnce gri dış çerçeve.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Yuvarlatılmış köşeler.
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ), // Yarı kalın yazı stili.
        ),
      ),
    );
  }

  /// Koyu (Dark) tema konfigürasyonunu oluşturan statik fonksiyon
  /// [accentColor]: Kullanıcının tercih ettiği birincil vurgu rengi
  static ThemeData dark(Color accentColor) {
    // Koyu mod için renk şemasını tohum renkten otomatik olarak türetir.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.dark, // Koyu parlaklık modu.
      primary: accentColor,
      surface: const Color(
        0xFF0F172A,
      ), // Koyu lacivert/gri kart ve yüzey rengi.
      surfaceContainerHighest: const Color(
        0xFF1E293B,
      ), // Bir ton daha açık koyu yüzey rengi.
    );

    // Koyu temaya ait ThemeData nesnesini döndürür.
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(
        0xFF090D16,
      ), // Çok koyu zemin rengi (gece mavisi/siyah).
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: const Color(0xFF0F172A), // Koyu zeminli üst bar.
        foregroundColor: Colors.white, // Üst bar başlık ve butonları beyaz.
        surfaceTintColor: Colors.transparent,
        shape: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(
              alpha: 0.08,
            ), // Koyu modda saydam beyaz alt çizgi.
            width: 1,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withValues(
              alpha: 0.08,
            ), // Koyu mod için hafif beyaz kenarlık.
            width: 1,
          ),
        ),
        color: const Color(0xFF0F172A),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(
          0xFF1E293B,
        ), // Koyu modda giriş alanının içi hafif aydınlık koyu ton.
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: accentColor,
            width: 2,
          ), // Odaklanıldığında sarı/vurgu çerçeve.
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: accentColor,
          foregroundColor:
              Colors.black, // Koyu temada da sarı buton üzerine siyah yazı.
          minimumSize: const Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.15),
          ), // Koyu temaya uygun çerçeve.
          foregroundColor: Colors.white, // Çerçeveli butonun yazı rengi beyaz.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
