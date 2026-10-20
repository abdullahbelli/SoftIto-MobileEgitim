import 'package:flutter_test/flutter_test.dart';
import 'package:rotiva/core/utils/date_utils.dart';

void main() {
  group('RotivaDateUtils Testleri', () {
    test('Senaryo 5: Tarih çakışma kuralları [10, 13) vs [13, 15) çakışmaz, [12, 15) çakışır', () {
      final oldStart = DateTime(2026, 10, 10);
      final oldEnd = DateTime(2026, 10, 13);

      // 1. [13, 15) ardışık kiralama - çakışmaz!
      final nonOverlapping = RotivaDateUtils.hasDateOverlap(
        newStart: DateTime(2026, 10, 13),
        newEnd: DateTime(2026, 10, 15),
        oldStart: oldStart,
        oldEnd: oldEnd,
      );
      expect(nonOverlapping, false);

      // 2. [12, 15) bir gün önce başlıyor - çakışır!
      final overlapping1 = RotivaDateUtils.hasDateOverlap(
        newStart: DateTime(2026, 10, 12),
        newEnd: DateTime(2026, 10, 15),
        oldStart: oldStart,
        oldEnd: oldEnd,
      );
      expect(overlapping1, true);

      // 3. [8, 11) eski aralığın başına biniyor - çakışır!
      final overlapping2 = RotivaDateUtils.hasDateOverlap(
        newStart: DateTime(2026, 10, 8),
        newEnd: DateTime(2026, 10, 11),
        oldStart: oldStart,
        oldEnd: oldEnd,
      );
      expect(overlapping2, true);

      // 4. [5, 10) eski aralıktan önce teslim edilmiş - çakışmaz!
      final nonOverlappingBefore = RotivaDateUtils.hasDateOverlap(
        newStart: DateTime(2026, 10, 5),
        newEnd: DateTime(2026, 10, 10),
        oldStart: oldStart,
        oldEnd: oldEnd,
      );
      expect(nonOverlappingBefore, false);
    });

    test('Gün farkı hesaplama minimum 1 gündür', () {
      final d1 = DateTime(2026, 5, 1);
      final d2 = DateTime(2026, 5, 1); // Aynı gün
      final d3 = DateTime(2026, 5, 4); // 3 gün

      expect(RotivaDateUtils.calculateRentalDays(d1, d2), 1);
      expect(RotivaDateUtils.calculateRentalDays(d1, d3), 3);
    });

    test(
      'Tam geçen yaş hesaplama (Doğum günü gelmediyse yaş 1 küçük sayılır)',
      () {
        final now = DateTime(2026, 10, 20);

        // Doğum günü henüz gelmedi: 25 Kasım 2005 (Henüz 20 yaşında, 21 değil)
        final b1 = DateTime(2005, 11, 25);
        expect(RotivaDateUtils.calculateExactAge(b1, now), 20);

        // Doğum günü geçti: 15 Ocak 2005 (21 yaşında)
        final b2 = DateTime(2005, 1, 15);
        expect(RotivaDateUtils.calculateExactAge(b2, now), 21);
      },
    );

    test('Tam geçen ehliyet süresi hesaplama', () {
      final now = DateTime(2026, 10, 20);

      // Ehliyet alış: 10 Aralık 2024 (Henüz 1 yıl dolmadı, 0 yıl)
      final l1 = DateTime(2024, 12, 10);
      expect(RotivaDateUtils.calculateExactLicenseYears(l1, now), 1);

      // Ehliyet alış: 10 Mayıs 2023 (3 tam yıl)
      final l2 = DateTime(2023, 5, 10);
      expect(RotivaDateUtils.calculateExactLicenseYears(l2, now), 3);
    });
  });
}
