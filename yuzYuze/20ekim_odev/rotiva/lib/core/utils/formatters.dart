import 'dart:math';

/// Metin, para ve rezervasyon kodu formatlayıcıları.
class RotivaFormatters {
  /// Para birimini TL simgesi ve binlik ayırıcı ile formatlar.
  /// Örnek: 3240 -> "3.240 ₺", 1250.50 -> "1.250,50 ₺"
  static String formatCurrency(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    final intPart = absAmount.truncate();
    final decimalPart = ((absAmount - intPart) * 100).round();

    // Binlik ayırıcı ekleme
    final intString = intPart.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < intString.length; i++) {
      if (i > 0 && (intString.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(intString[i]);
    }

    String result;
    if (decimalPart > 0) {
      final decStr = decimalPart.toString().padLeft(2, '0');
      result = '${buffer.toString()},$decStr ₺';
    } else {
      result = '${buffer.toString()} ₺';
    }

    return isNegative ? '-$result' : result;
  }

  /// Telefon numarasını standart formata getirir (Örn: 0532 123 45 67)
  static String formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 11 && cleaned.startsWith('0')) {
      return '${cleaned.substring(0, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7, 9)} ${cleaned.substring(9, 11)}';
    } else if (cleaned.length == 10) {
      return '0${cleaned.substring(0, 3)} ${cleaned.substring(3, 6)} ${cleaned.substring(6, 8)} ${cleaned.substring(8, 10)}';
    }
    return phone;
  }

  /// Rastgele ve benzersiz rezervasyon kodu üretir (Örn: RTV-2026-8491)
  static String generateReservationCode() {
    final year = DateTime.now().year;
    final randomPart = 1000 + Random().nextInt(9000);
    return 'RTV-$year-$randomPart';
  }
}
