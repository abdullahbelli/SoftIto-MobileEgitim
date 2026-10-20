import 'package:flutter_test/flutter_test.dart';
import 'package:rotiva/core/constants/app_constants.dart';
import 'package:rotiva/features/rentals/models/rental_pricing.dart';
import 'package:rotiva/features/vehicles/models/vehicle.dart';

void main() {
  group('RentalPricing İş Kuralları Testleri', () {
    const testVehicle = Vehicle(
      id: 'test_veh',
      brand: 'TestBrand',
      model: 'TestModel',
      year: 2024,
      category: VehicleCategory.sedan,
      fuelType: FuelType.gasoline,
      transmission: TransmissionType.automatic,
      city: 'İstanbul',
      district: 'Kadıköy',
      imagePath: '',
      hourlyRate: 100.0,
      dailyRate: 1000.0, // Günlük 1000 ₺
      minimumAge: 21,
      minimumLicenseYears: 1,
      dailyKmLimit: 300,
      additionalDailyKm: 150,
      additionalKmDailyPrice: 200.0, // Ek km günlük 200 ₺
      addressDeliveryFee: 450.0, // Adrese teslimat 450 ₺
      isActive: true,
    );

    final start = DateTime(2026, 10, 10);
    final end = DateTime(2026, 10, 13); // 3 gün

    test('Senaryo 1: 3 gün x 1000 ₺ = 3000 ₺ standart kiralama', () {
      final result = RentalPricing.calculate(
        vehicle: testVehicle,
        startDate: start,
        endDate: end,
        deliveryType: DeliveryType.branch,
        hasExtraKm: false,
        paymentMethod: PaymentMethod.creditCard,
      );

      expect(result.rentalDays, 3);
      expect(result.basePrice, 3000.0);
      expect(result.extraKmCost, 0.0);
      expect(result.deliveryFee, 0.0);
      expect(result.discountAmount, 0.0);
      expect(result.finalPrice, 3000.0);
    });

    test('Senaryo 2: 3 gün x 200 ₺ km paketi = 600 ₺ ek ücret', () {
      final result = RentalPricing.calculate(
        vehicle: testVehicle,
        startDate: start,
        endDate: end,
        deliveryType: DeliveryType.branch,
        hasExtraKm: true,
        paymentMethod: PaymentMethod.creditCard,
      );

      expect(result.rentalDays, 3);
      expect(result.basePrice, 3000.0);
      expect(result.extraKmCost, 600.0);
      expect(result.subtotal, 3600.0);
      expect(result.finalPrice, 3600.0);
    });

    test('Senaryo 3: Şubeden + nakit ile (3000+600) üzerinden 360 ₺ indirim; toplam 3240 ₺', () {
      final result = RentalPricing.calculate(
        vehicle: testVehicle,
        startDate: start,
        endDate: end,
        deliveryType: DeliveryType.branch,
        hasExtraKm: true,
        paymentMethod: PaymentMethod.cashAtBranch,
      );

      expect(result.isCashDiscountApplied, true);
      expect(result.discountAmount, 360.0); // (3000 + 600) * 0.10
      expect(result.finalPrice, 3240.0);
    });

    test('Senaryo 4: Adrese teslimat (450 ₺) + kart ile toplam 4050 ₺; nakit engeli', () {
      final result = RentalPricing.calculate(
        vehicle: testVehicle,
        startDate: start,
        endDate: end,
        deliveryType: DeliveryType.address,
        hasExtraKm: true,
        paymentMethod: PaymentMethod.creditCard,
      );

      expect(result.deliveryFee, 450.0);
      expect(result.discountAmount, 0.0);
      expect(result.finalPrice, 4050.0); // 3000 + 600 + 450

      // Adrese teslimde nakit yasak kuralı
      final isAllowed = RentalPricing.isPaymentMethodAllowed(
        deliveryType: DeliveryType.address,
        paymentMethod: PaymentMethod.cashAtBranch,
      );
      expect(isAllowed, false);
    });

    test('Senaryo 7: Seçenek değiştiğinde toplam yeniden hesaplanır', () {
      // Standart şubeden kart
      final r1 = RentalPricing.calculate(
        vehicle: testVehicle,
        startDate: start,
        endDate: end,
        deliveryType: DeliveryType.branch,
        hasExtraKm: false,
        paymentMethod: PaymentMethod.creditCard,
      );
      expect(r1.finalPrice, 3000.0);

      // Ek km eklendi
      final r2 = RentalPricing.calculate(
        vehicle: testVehicle,
        startDate: start,
        endDate: end,
        deliveryType: DeliveryType.branch,
        hasExtraKm: true,
        paymentMethod: PaymentMethod.creditCard,
      );
      expect(r2.finalPrice, 3600.0);

      // Şube nakit seçildi
      final r3 = RentalPricing.calculate(
        vehicle: testVehicle,
        startDate: start,
        endDate: end,
        deliveryType: DeliveryType.branch,
        hasExtraKm: true,
        paymentMethod: PaymentMethod.cashAtBranch,
      );
      expect(r3.finalPrice, 3240.0);
    });
  });
}
