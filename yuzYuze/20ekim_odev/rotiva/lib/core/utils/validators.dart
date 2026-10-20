/// Rotiva form girdi alanları için doğrulama (validation) fonksiyonları.
/// Flutter'da TextFormField widget'larının 'validator' parametresine atanır.
class RotivaValidators {
  /// Zorunlu alan kontrolü: Metin boş veya sadece boşluklardan oluşuyorsa hata mesajı döner.
  static String? validateRequired(
    String? value, [
    String fieldName =
        'Bu alan', // Hata mesajında görünecek alan adı opsiyoneldir.
  ]) {
    // Null kontrolü veya boşluk kontrolü
    if (value == null || value.trim().isEmpty) {
      return '$fieldName boş bırakılamaz.';
    }
    return null; // Null dönmesi girdinin geçerli ve hatasız olduğunu belirtir.
  }

  /// E-posta formatı kontrolü: Standart regex deseniyle e-posta biçimini doğrular.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'E-posta adresi zorunludur.';
    }
    // E-posta formatı düzenli ifadesi (Regex)
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Geçerli bir e-posta adresi giriniz (Örn: ad@ornek.com).';
    }
    return null; // Format doğruysa null döner.
  }

  /// Telefon numarası kontrolü: Rakam sayısını denetler (10 veya 11 hane).
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Telefon numarası zorunludur.';
    }
    // Rakam dışındaki tüm boşluk ve parantez gibi karakterleri temizliyoruz.
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 10 || digitsOnly.length > 11) {
      return 'Geçerli bir telefon numarası giriniz (10 veya 11 hane).';
    }
    return null;
  }

  /// Şifre uzunluğu kontrolü (Varsayılan en az 6 karakter).
  static String? validatePassword(String? value, [int minLength = 6]) {
    if (value == null || value.trim().isEmpty) {
      return 'Şifre zorunludur.';
    }
    if (value.length < minLength) {
      return 'Şifre en az $minLength karakterden oluşmalıdır.';
    }
    return null;
  }

  /// Kayıt sırasında şifre tekrarının ilk şifreyle eşleşip eşleşmediğini kontrol eder.
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

  /// Pozitif sayı ve ücret kontrolü (Örn: Günlük ücret, teslimat bedeli).
  static String? validatePositiveNumber(
    String? value, [
    String fieldName = 'Miktar',
  ]) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName zorunludur.';
    }
    // Virgül girildiyse ondalık nokta formatına dönüştürüyoruz.
    final number = double.tryParse(value.replaceAll(',', '.'));
    if (number == null || number <= 0) {
      return '$fieldName 0\'dan büyük geçerli bir sayı olmalıdır.';
    }
    return null;
  }

  /// Pozitif tam sayı kontrolü (Örn: Model yılı, km limiti, yaş sınırı).
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
