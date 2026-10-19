import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/diary/models/diary_model.dart';

/// Günlük verilerini yerel depolamada (`SharedPreferences`) kalıcı olarak saklayan servis.
/// Web (Chrome, Edge vb.), Android ve iOS platformlarında yerel depolama ile çalışır.
class DiaryStorageService {
  static const String _keyPrefix = 'diary_entry_';
  static const String _datesIndexKey = 'diary_saved_dates_index';

  final SharedPreferences? _prefs;

  DiaryStorageService([this._prefs]);

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  /// Verilen tarihe ait günlük kaydını getirir. Kayıt yoksa null döner.
  Future<DiaryModel?> getDiary(DateTime date) async {
    try {
      final prefs = await _getPrefs();
      final key = _buildKey(date);
      final jsonString = prefs.getString(key);

      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      final Map<String, dynamic> jsonMap =
          jsonDecode(jsonString) as Map<String, dynamic>;
      return DiaryModel.fromJson(jsonMap);
    } catch (e) {
      // Hata durumunda veri bozulmasını önlemek için null döner
      return null;
    }
  }

  /// Günlük kaydını kalıcı olarak kaydeder veya günceller.
  Future<void> saveDiary(DiaryModel diary) async {
    final prefs = await _getPrefs();
    final key = _buildKey(diary.date);
    final jsonString = jsonEncode(diary.toJson());

    await prefs.setString(key, jsonString);

    // Tarih indeksini güncelle
    final dateKey = diary.dateKey;
    final dates = await _getDatesIndex(prefs);
    if (!dates.contains(dateKey)) {
      dates.add(dateKey);
      await prefs.setStringList(_datesIndexKey, dates.toList());
    }
  }

  /// Belirtilen tarihteki günlüğü siler.
  Future<bool> deleteDiary(DateTime date) async {
    final prefs = await _getPrefs();
    final key = _buildKey(date);
    final dateKey = DiaryModel.formatDateKey(date);

    final removed = await prefs.remove(key);

    // Tarih indeksinden çıkart
    final dates = await _getDatesIndex(prefs);
    if (dates.remove(dateKey)) {
      await prefs.setStringList(_datesIndexKey, dates.toList());
    }

    return removed;
  }

  /// Takvimde nokta/işaret gösterilecek olan tarih anahtarlarını (YYYY-MM-DD) döner.
  Future<Set<String>> getMarkedDateKeys() async {
    final prefs = await _getPrefs();
    return _getDatesIndex(prefs);
  }

  /// Tüm günlük kayıtlarını döner.
  Future<List<DiaryModel>> getAllDiaries() async {
    final prefs = await _getPrefs();
    final dateKeys = await _getDatesIndex(prefs);
    final List<DiaryModel> result = [];

    for (final dateKey in dateKeys) {
      final key = '$_keyPrefix$dateKey';
      final jsonString = prefs.getString(key);
      if (jsonString != null && jsonString.isNotEmpty) {
        try {
          final Map<String, dynamic> jsonMap =
              jsonDecode(jsonString) as Map<String, dynamic>;
          result.add(DiaryModel.fromJson(jsonMap));
        } catch (_) {
          // Bozuk kayıtları atla
        }
      }
    }

    // Tarihe göre sırala (yeniden eskiye)
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  String _buildKey(DateTime date) {
    return '$_keyPrefix${DiaryModel.formatDateKey(date)}';
  }

  Future<Set<String>> _getDatesIndex(SharedPreferences prefs) async {
    final list = prefs.getStringList(_datesIndexKey) ?? [];
    return list.toSet();
  }
}
