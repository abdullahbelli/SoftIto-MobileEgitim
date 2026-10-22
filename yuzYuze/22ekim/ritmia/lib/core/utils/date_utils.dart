import 'package:intl/intl.dart';

/// Tarih işlemleri, yerel gün anahtarı (YYYY-MM-DD) dönüşümleri ve
/// haftalık lig zaman pencereleri için yardımcı metotlar.
abstract final class AppDateUtils {
  /// Tarihi yerel 'YYYY-MM-DD' anahtar formatına çevirir
  static String toDateString(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// 'YYYY-MM-DD' formatındaki metni yerel DateTime nesnesine çevirir
  static DateTime parseDateString(String dateStr) {
    return DateTime.parse(dateStr);
  }

  /// Bugünün yerel tarih anahtarını döner
  static String todayString() {
    return toDateString(DateTime.now());
  }

  /// İki tarihin aynı takvim gününe ait olup olmadığını kontrol eder
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Belirtilen tarihin içinde bulunduğu haftanın Pazartesi gününü döner
  static DateTime weekStart(DateTime date) {
    // Dart'ta DateTime.weekday: 1 = Pazartesi, 7 = Pazar
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: date.weekday - 1));
  }

  /// Belirtilen tarihin içinde bulunduğu haftanın Pazar gününü döner
  static DateTime weekEnd(DateTime date) {
    return weekStart(date).add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  }

  /// Haftalık lig kimliği döner (Örn: "2026-W43")
  static String weekId(DateTime date) {
    final monday = weekStart(date);
    return '${monday.year}-W${DateFormat('w').format(monday)}';
  }

  /// Kullanıcı dostu Türkçe tarih gösterimi (Örn: "22 Ekim 2026, Perşembe")
  static String formatFullTurkish(DateTime date) {
    return DateFormat('d MMMM yyyy, EEEE', 'tr_TR').format(date);
  }

  /// Ay ve yıl başlığı (Örn: "Ekim 2026")
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'tr_TR').format(date);
  }

  /// Kısa gün adı (Örn: "22 Eki")
  static String formatShortDayMonth(DateTime date) {
    return DateFormat('d MMM', 'tr_TR').format(date);
  }
}
