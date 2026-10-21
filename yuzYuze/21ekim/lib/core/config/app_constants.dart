/// BoardConnect uygulama geneli sabitleri
class AppConstants {
  static const String appName = 'BoardConnect';
  static const String appTagline = 'Ortak Çalışma & Sonsuz Whiteboard';
  static const String appVersion = '1.0.0';

  // Demo / Mock Sabitleri
  static const int otpDurationSeconds = 90;
  static const String demoOtpCode = '123456';

  // LocalStorage anahtarları
  static const String prefsKeyThemeMode = 'bc_theme_mode';
  static const String prefsKeyAccentColor = 'bc_accent_color';
  static const String prefsKeyCurrentUser = 'bc_current_user';
  static const String prefsKeyRooms = 'bc_rooms_list';
  static const String prefsKeyObjectsPrefix = 'bc_objects_room_';

  // Tuval sınırları ve varsayılanları
  static const double minZoom = 0.2;
  static const double maxZoom = 5.0;
  static const double defaultStrokeWidth = 3.0;
}
