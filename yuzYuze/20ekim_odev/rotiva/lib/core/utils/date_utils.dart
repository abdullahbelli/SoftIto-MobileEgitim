/// Rotiva tarih, gün farkı, yaş, ehliyet süresi ve çakışma kontrolleri.
class RotivaDateUtils {
  /// Yalnızca yıl, ay ve günü dikkate alarak saat farklarını sıfırlayan tarih döndürür.
  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Kiralama takvim gün farkını hesaplar.
  /// Bitiş teslim günüdür; [startDate, endDate) aralığında minimum 1 gün olmalıdır.
  static int calculateRentalDays(DateTime startDate, DateTime endDate) {
    final start = dateOnly(startDate);
    final end = dateOnly(endDate);
    final days = end.difference(start).inDays;
    return days < 1 ? 1 : days;
  }

  /// İki tarih aralığının çakışıp çakışmadığını kontrol eder.
  /// Formül: newStart < oldEnd && oldStart < newEnd
  static bool hasDateOverlap({
    required DateTime newStart,
    required DateTime newEnd,
    required DateTime oldStart,
    required DateTime oldEnd,
  }) {
    final nStart = dateOnly(newStart);
    final nEnd = dateOnly(newEnd);
    final oStart = dateOnly(oldStart);
    final oEnd = dateOnly(oldEnd);

    return nStart.isBefore(oEnd) && oStart.isBefore(nEnd);
  }

  /// Doğum tarihine göre tam geçen yaşı hesaplar (gün/ay kontrolüyle).
  static int calculateExactAge(DateTime birthDate, [DateTime? currentDate]) {
    final now = currentDate ?? DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Ehliyet alış tarihine göre tam geçen ehliyet süresini (yıl olarak) hesaplar.
  static int calculateExactLicenseYears(
    DateTime licenseDate, [
    DateTime? currentDate,
  ]) {
    final now = currentDate ?? DateTime.now();
    int years = now.year - licenseDate.year;
    if (now.month < licenseDate.month ||
        (now.month == licenseDate.month && now.day < licenseDate.day)) {
      years--;
    }
    return years;
  }

  /// Tarihi kullanıcı dostu GG.AA.YYYY formatında döndürür.
  static String formatTurkishDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day.$month.$year';
  }

  /// İki tarih aralığını "12.10.2026 - 15.10.2026 (3 Gün)" şeklinde metinleştirir.
  static String formatDateRangeText(DateTime start, DateTime end) {
    final days = calculateRentalDays(start, end);
    return '${formatTurkishDate(start)} - ${formatTurkishDate(end)} ($days Gün)';
  }
}
