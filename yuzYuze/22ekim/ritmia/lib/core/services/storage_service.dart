import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences tabanlı yerel veri saklama servisi.
/// Tema, oturum, alışkanlıklar ve günlük ilerleme kayıtlarının
/// cihaz kapansa bile korunmasını sağlar.
class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static const String _keyThemeMode = 'ritmia_theme_mode';
  static const String _keyAccentColor = 'ritmia_accent_color';
  static const String _keyCurrentUser = 'ritmia_current_user';
  static const String _keyHabits = 'ritmia_habits';
  static const String _keyProgress = 'ritmia_day_progress';
  static const String _keyBadges = 'ritmia_earned_badges';
  static const String _keyLeaderboardOptIn = 'ritmia_leaderboard_opt_in';

  // Tema Tercihi
  String getThemeMode() => _prefs.getString(_keyThemeMode) ?? 'system';
  Future<bool> setThemeMode(String mode) => _prefs.setString(_keyThemeMode, mode);

  // Vurgu Rengi Tercihi
  String getAccentColor() => _prefs.getString(_keyAccentColor) ?? 'pink';
  Future<bool> setAccentColor(String colorKey) => _prefs.setString(_keyAccentColor, colorKey);

  // Liderlik Panosu Katılım Onayı
  bool getLeaderboardOptIn() => _prefs.getBool(_keyLeaderboardOptIn) ?? false;
  Future<bool> setLeaderboardOptIn(bool optIn) => _prefs.setBool(_keyLeaderboardOptIn, optIn);

  // Kullanıcı Oturumu (JSON)
  Map<String, dynamic>? getCurrentUser() {
    final raw = _prefs.getString(_keyCurrentUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> setCurrentUser(Map<String, dynamic>? userMap) {
    if (userMap == null) {
      return _prefs.remove(_keyCurrentUser);
    }
    return _prefs.setString(_keyCurrentUser, jsonEncode(userMap));
  }

  // Alışkanlıklar Listesi (JSON Listesi)
  List<Map<String, dynamic>> getHabits() {
    final rawList = _prefs.getStringList(_keyHabits);
    if (rawList == null) return [];
    return rawList.map((e) {
      try {
        return jsonDecode(e) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((m) => m.isNotEmpty).toList();
  }

  Future<bool> saveHabits(List<Map<String, dynamic>> habits) {
    final rawList = habits.map((e) => jsonEncode(e)).toList();
    return _prefs.setStringList(_keyHabits, rawList);
  }

  // Günlük İlerleme Kayıtları (JSON Map: "habitId_YYYY-MM-DD" -> JSON)
  Map<String, Map<String, dynamic>> getDayProgressMap() {
    final raw = _prefs.getString(_keyProgress);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value as Map<String, dynamic>));
    } catch (_) {
      return {};
    }
  }

  Future<bool> saveDayProgressMap(Map<String, Map<String, dynamic>> progressMap) {
    return _prefs.setString(_keyProgress, jsonEncode(progressMap));
  }

  // Kazanılan Rozetler (JSON Listesi)
  List<Map<String, dynamic>> getBadges() {
    final rawList = _prefs.getStringList(_keyBadges);
    if (rawList == null) return [];
    return rawList.map((e) {
      try {
        return jsonDecode(e) as Map<String, dynamic>;
      } catch (_) {
        return <String, dynamic>{};
      }
    }).where((m) => m.isNotEmpty).toList();
  }

  Future<bool> saveBadges(List<Map<String, dynamic>> badges) {
    final rawList = badges.map((e) => jsonEncode(e)).toList();
    return _prefs.setStringList(_keyBadges, rawList);
  }

  // Demo verilerini sıfırlamak veya çıkış yapmak için
  Future<void> clearSession() async {
    await _prefs.remove(_keyCurrentUser);
  }
}
