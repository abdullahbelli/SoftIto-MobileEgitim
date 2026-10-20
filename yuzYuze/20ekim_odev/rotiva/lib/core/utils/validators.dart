/// Rotiva form doğrulama (validation) fonksiyonları.
class RotivaValidators {
  /// Zorunlu alan kontrolü
  static String? validateRequired(
    String? value, [
    String fieldName = 'Bu alan',
  ]) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName boş bırakılamaz.';
    }
    return null;
  }

  /// E-posta formatı kontrolü
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresi zorunludur.';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir e-posta adresi giriniz (Örn: ad@ornek.com).';
    }
    return null;
  }

  /// Telefon numarası kontrolü
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefon numarası zorunludur.';
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10 || digitsOnly.length > 11) {
      return 'Geçerli bir telefon numarası giriniz (10 veya 11 hane).';
    }
    return null;
  }

  /// Şifre kontrolü (En az 6 karakter)
  static String? validatePassword(String? value, [int minLength = 6]) {
    if (value == null || value.trim().isEmpty) {
      return 'Şifre zorunludur.';
    }
    if (value.length < minLength) {
      return 'Şifre en az $minLength karakterden oluşmalıdır.';
    }
    return null;
  }

  /// Şifre tekrar kontrolü
  static String? validateConfirmPassword(
    String? value,
    String originalPassword,
  ) {
    if (value == null || value.trim().isEmpty) {
      return 'Şifre tekrarı zorunludur.';
    }
    if (value != originalPassword) {
      return 'Şifreler birbiriyle eşleşmiyor.';
    }
    return null;
  }

  /// Pozitif sayı / ücret kontrolü
  static String? validatePositiveNumber(
    String? value, [
    String fieldName = 'Miktar',
  ]) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName zorunludur.';
    }
    final number = double.tryParse(value.replaceAll(',', '.'));
    if (number == null || number <= 0) {
      return '$fieldName 0\'dan büyük geçerli bir sayı olmalıdır.';
    }
    return null;
  }

  /// Tam sayı kontrolü (Yıl, km, yaş vb.)
  static String? validatePositiveInteger(
    String? value, [
    String fieldName = 'Değer',
  ]) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName zorunludur.';
    }
    final number = int.tryParse(value.trim());
    if (number == null || number <= 0) {
      return '$fieldName pozitif bir tam sayı olmalıdır.';
    }
    return null;
  }
}
