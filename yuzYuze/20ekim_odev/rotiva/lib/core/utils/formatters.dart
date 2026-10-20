import 'dart:math'; // Rastgele rezervasyon kodu üretmek için Random sınıfını içe aktarıyoruz.

/// Metin, para birimi ve rezervasyon kodu formatlayıcıları yardımcı sınıfı.
class RotivaFormatters {
  /// Para birimini TL simgesi ve binlik ayırıcı nokta ile formatlar.
  /// Örnek: 3240 -> "3.240 ₺", 1250.50 -> "1.250,50 ₺"
  static String formatCurrency(double amount) {
    final isNegative = amount < 0; // Negatif tutar kontrolü (indirimler için)
    final absAmount = amount.abs(); // Mutlak değeri alıyoruz.

    final intPart = absAmount.truncate(); // Tam sayı kısmını alıyoruz.
    final decimalPart = ((absAmount - intPart) * 100)
        .round(); // Kuruş kısmını 2 basamaklı sayıya yuvarlıyoruz.

    // Binlik ayırıcı nokta ekleme mantığı
    final intString = intPart.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < intString.length; i++) {
      // Sondan itibaren her 3 basamakta bir nokta (.) koyuyoruz
      if (i > 0 && (intString.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(intString[i]);
    }

    String result;
    // Eğer kuruş kısmı varsa virgülle ekliyoruz, yoksa sadece tam sayıyı gösteriyoruz
    if (decimalPart > 0) {
      final decStr = decimalPart.toString().padLeft(2, '0');
      result = '${buffer.toString()},$decStr ₺';
    } else {
      result = '${buffer.toString()} ₺';
    }

    // Negatifse başına eksi koyup döndürüyoruz
    return isNegative ? '-$result' : result;
  }

  /// Telefon numarasını Türkiye standart formatına getirir (Örn: 0532 123 45 67)
  static String formatPhone(String phone) {
    // Sayı dışındaki tüm karakterleri temizliyoruz
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 11 && cleaned.startsWith('0')) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7, 9)} ${cleaned.substring(9, 11)}';
    } else if (cleaned.length == 10) {
      return '0${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6, 8)} ${cleaned.substring(8, 10)}';
    }
    return phone;
  }

  /// Kullanıcıya gösterilecek kurumsal ve benzersiz rezervasyon kodu üretir (Örn: RTV-2026-8491)
  static String generateReservationCode() {
    final year = DateTime.now().year; // Güncel yılı alıyoruz.
    final randomPart =
        1000 +
        Random().nextInt(
          9000,
        ); // 1000 ile 9999 arasında 4 basamaklı rastgele sayı
    return 'RTV-$year-$randomPart';
  }
}
