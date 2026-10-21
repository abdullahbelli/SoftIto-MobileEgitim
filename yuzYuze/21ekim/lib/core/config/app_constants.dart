/// BoardConnect uygulama geneli sabitleri
/// Bu sınıf; sihirli sayılar (magic numbers) ve sabit metinleri tek merkezde toplayarak kodun bakımını kolaylaştırır.
class AppConstants {
  // Uygulamanın resmi adı.
  static const String appName = 'BoardConnect';

  // Uygulamanın tanıtım sloganı / alt başlığı.
  static const String appTagline = 'Ortak Çalışma & Sonsuz Whiteboard';

  // Uygulamanın mevcut sürüm numarası.
  static const String appVersion = '1.0.0';

  // Demo / Mock Sabitleri
  // Proje gereksiniminde belirtilen 6 haneli OTP kodu geri sayım süresi (90 saniye).
  static const int otpDurationSeconds = 90;

  // Test ve inceleme aşamasında kullanılacak varsayılan simüle edilmiş 6 haneli doğrulama kodu.
  static const String demoOtpCode = '123456';

  // LocalStorage (SharedPreferences) anahtarları
  // Seçilen tema modunun (light, dark, system) saklandığı anahtar.
  static const String prefsKeyThemeMode = 'bc_theme_mode';

  // Kullanıcının tercih ettiği tema vurgu renginin saklandığı anahtar.
  static const String prefsKeyAccentColor = 'bc_accent_color';

  // Aktif oturum açmış kullanıcının JSON bilgilerinin kaydedildiği anahtar.
  static const String prefsKeyCurrentUser = 'bc_current_user';

  // Kullanıcının oluşturduğu ve katıldığı odaların JSON listesinin saklandığı anahtar.
  static const String prefsKeyRooms = 'bc_rooms_list';

  // Her odanın tuval nesnelerinin (çizim, şekil, metin vb.) saklanacağı anahtarın ön eki (Örn: bc_objects_room_123).
  static const String prefsKeyObjectsPrefix = 'bc_objects_room_';

  // Tuval sınırları ve varsayılanları
  // Tuvalin küçültülebileceği (zoom out) minimum yakınlaştırma oranı (%20).
  static const double minZoom = 0.2;

  // Tuvalin büyütülebileceği (zoom in) maksimum yakınlaştırma oranı (5 katı).
  static const double maxZoom = 5.0;

  // Çizim kaleminin başlangıçtaki varsayılan çizgi kalınlığı (piksel cinsinden).
  static const double defaultStrokeWidth = 3.0;
}
