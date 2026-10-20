import 'package:flutter_test/flutter_test.dart';
import 'package:rotiva/core/utils/validators.dart';

void main() {
  group('RotivaValidators Testleri', () {
    test('Zorunlu alan validasyonu', () {
      expect(RotivaValidators.validateRequired(''), isNotNull);
      expect(RotivaValidators.validateRequired('   '), isNotNull);
      expect(RotivaValidators.validateRequired(null), isNotNull);
      expect(RotivaValidators.validateRequired('Dolu Metin'), isNull);
    });

    test('E-posta format validasyonu', () {
      expect(RotivaValidators.validateEmail(''), isNotNull);
      expect(RotivaValidators.validateEmail('gecersiz-eposta'), isNotNull);
      expect(RotivaValidators.validateEmail('ahmet@'), isNotNull);
      expect(RotivaValidators.validateEmail('ahmet@rotiva.com'), isNull);
      expect(RotivaValidators.validateEmail('test.user@domain.co.uk'), isNull);
    });

    test('Telefon numarası validasyonu', () {
      expect(RotivaValidators.validatePhone(''), isNotNull);
      expect(RotivaValidators.validatePhone('123'), isNotNull);
      expect(RotivaValidators.validatePhone('0532 123 45 67'), isNull);
      expect(RotivaValidators.validatePhone('05551234567'), isNull);
    });

    test('Şifre ve şifre tekrarı validasyonu', () {
      expect(
        RotivaValidators.validatePassword('12345', 6),
        isNotNull,
      ); // 5 karakter
      expect(
        RotivaValidators.validatePassword('123456', 6),
        isNull,
      ); // 6 karakter

      expect(
        RotivaValidators.validateConfirmPassword('123456', '654321'),
        isNotNull, // Eşleşmiyor
      );
      expect(
        RotivaValidators.validateConfirmPassword('123456', '123456'),
        isNull, // Eşleşiyor
      );
    });

    test('Pozitif sayı validasyonu', () {
      expect(RotivaValidators.validatePositiveNumber(''), isNotNull);
      expect(RotivaValidators.validatePositiveNumber('-10'), isNotNull);
      expect(RotivaValidators.validatePositiveNumber('0'), isNotNull);
      expect(RotivaValidators.validatePositiveNumber('1500'), isNull);
      expect(RotivaValidators.validatePositiveNumber('1250,50'), isNull);
    });
  });
}
