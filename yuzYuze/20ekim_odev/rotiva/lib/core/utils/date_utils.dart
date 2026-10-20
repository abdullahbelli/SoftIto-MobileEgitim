/// Rotiva tarih, gün farkı, yaş, ehliyet süresi ve çakışma kontrolleri yardımcı sınıfı.
class RotivaDateUtils {
  /// Yalnızca yıl, ay ve günü dikkate alarak saat, dakika ve saniyeleri sıfırlayan tarih nesnesi döndürür.
  /// Saat farklarından kaynaklanan gün hesaplama hatalarını önler.
  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Kiralama takvim gün farkını hesaplar.
  /// Bitiş teslim günüdür; [startDate, endDate) aralığında kiralama en az 1 gün olmalıdır.
  static int calculateRentalDays(DateTime startDate, DateTime endDate) {
    final start = dateOnly(
      startDate,
    ); // Başlangıç tarihinin saatini sıfırlıyoruz.
    final end = dateOnly(endDate); // Bitiş tarihinin saatini sıfırlıyoruz.
    final days = end
        .difference(start)
        .inDays; // İki tarih arasındaki tam gün farkını alıyoruz.
    return days < 1
        ? 1
        : days; // Gün farkı 0 veya negatifse en az 1 gün kabul edilir.
  }

  /// İki kiralama tarih aralığının takvimde çakışıp çakışmadığını kontrol eder.
  /// Matematiksel Formül: newStart < oldEnd && oldStart < newEnd
  static bool hasDateOverlap({
    required DateTime newStart, // Yeni kiralanmak istenen başlangıç
    required DateTime newEnd, // Yeni kiralanmak istenen bitiş
    required DateTime oldStart, // Mevcut rezervasyon başlangıcı
    required DateTime oldEnd, // Mevcut rezervasyon bitişi
  }) {
    final nStart = dateOnly(newStart);
    final nEnd = dateOnly(newEnd);
    final oStart = dateOnly(oldStart);
    final oEnd = dateOnly(oldEnd);

    // Çakışma koşulu: Yeni başlangıç eski bitişten önceyse VE eski başlangıç yeni bitişten önceyse çakışır.
    return nStart.isBefore(oEnd) && oStart.isBefore(nEnd);
  }

  /// Doğum tarihine göre kullanıcının tam doldurduğu yaşı hesaplar (gün ve ay kontrolüyle).
  static int calculateExactAge(DateTime birthDate, [DateTime? currentDate]) {
    final now =
        currentDate ??
        DateTime.now(); // Test edilebilmesi için opsiyonel tarih parametresi
    int age = now.year - birthDate.year; // Yıl farkını alıyoruz.
    // Eğer kullanıcının doğum günü bu yıl henüz gelmediyse yaşını 1 eksiltiyoruz.
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
    // Eğer ehliyet alış yıldönümü bu yıl henüz dolmadıysa süreyi 1 eksiltiyoruz.
    if (now.month < licenseDate.month ||
        (now.month == licenseDate.month && now.day < licenseDate.day)) {
      years--;
    }
    return years;
  }

  /// Tarihi Türkiye standartlarında kullanıcı dostu GG.AA.YYYY formatında döndürür (Örn: 05.11.2024).
  static String formatTurkishDate(DateTime date) {
    final day = date.day.toString().padLeft(
      2,
      '0',
    ); // Tek basamaklı günlerin başına 0 ekler.
    final month = date.month.toString().padLeft(
      2,
      '0',
    ); // Tek basamaklı ayların başına 0 ekler.
    final year = date.year.toString();
    return '$day.$month.$year';
  }

  /// İki tarih aralığını "12.10.2026 - 15.10.2026 (3 Gün)" şeklinde okunabilir metne dönüştürür.
  static String formatDateRangeText(DateTime start, DateTime end) {
    final days = calculateRentalDays(start, end);
    return '${formatTurkishDate(start)} - ${formatTurkishDate(end)} ($days Gün)';
  }
}
