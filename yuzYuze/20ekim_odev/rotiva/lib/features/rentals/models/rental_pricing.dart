import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../vehicles/models/vehicle.dart';

/// Kiralama fiyatlandırma detay ve sonuç modeli.
class RentalPricingResult {
  final int rentalDays;
  final double dailyRate;
  final double basePrice; // rentalDays * dailyRate
  final bool hasExtraKm;
  final double extraKmDailyPrice;
  final double extraKmCost; // rentalDays * extraKmDailyPrice
  final DeliveryType deliveryType;
  final double deliveryFee; // Adrese teslim bedeli (varsa)
  final PaymentMethod? paymentMethod;
  final bool isCashDiscountApplied;
  final double discountAmount; // (basePrice + extraKmCost) * 0.10
  final double
  finalPrice; // basePrice + extraKmCost + deliveryFee - discountAmount

  const RentalPricingResult({
    required this.rentalDays,
    required this.dailyRate,
    required this.basePrice,
    required this.hasExtraKm,
    required this.extraKmDailyPrice,
    required this.extraKmCost,
    required this.deliveryType,
    required this.deliveryFee,
    this.paymentMethod,
    required this.isCashDiscountApplied,
    required this.discountAmount,
    required this.finalPrice,
  });

  /// Ara toplam (indirim ve teslimat öncesi araç + ek km bedeli)
  double get subtotal => basePrice + extraKmCost;
}

/// Rotiva kiralama fiyat hesaplama motoru (Pure Business Logic).
class RentalPricing {
  /// Kiralama fiyatını hesaplar.
  static RentalPricingResult calculate({
    required Vehicle vehicle,
    required DateTime startDate,
    required DateTime endDate,
    required DeliveryType deliveryType,
    required bool hasExtraKm,
    PaymentMethod? paymentMethod,
  }) {
    // 1. Gün sayısı hesaplama (minimum 1 gün)
    final rentalDays = RotivaDateUtils.calculateRentalDays(startDate, endDate);

    // 2. Baz araç bedeli
    final basePrice = rentalDays * vehicle.dailyRate;

    // 3. Ek kilometre bedeli
    final extraKmDailyPrice = hasExtraKm ? vehicle.additionalKmDailyPrice : 0.0;
    final extraKmCost = rentalDays * extraKmDailyPrice;

    // 4. Teslimat ücreti (yalnızca adrese teslimatta)
    final deliveryFee = (deliveryType == DeliveryType.address)
        ? vehicle.addressDeliveryFee
        : 0.0;

    // 5. Nakit indirimi kuralı:
    // Şubeden teslim + Şubede nakit ödeme ise (araç + ek km) üzerinden %10 indirim
    final bool isEligibleForCashDiscount =
        deliveryType == DeliveryType.branch &&
        paymentMethod == PaymentMethod.cashAtBranch;

    final double discountAmount = isEligibleForCashDiscount
        ? (basePrice + extraKmCost) * AppConstants.cashDiscountRate
        : 0.0;

    // 6. Toplam tutar
    final rawTotal = basePrice + extraKmCost + deliveryFee - discountAmount;
    // Kuruş yuvarlaması
    final finalPrice = (rawTotal * 100).round() / 100;

    return RentalPricingResult(
      rentalDays: rentalDays,
      dailyRate: vehicle.dailyRate,
      basePrice: basePrice,
      hasExtraKm: hasExtraKm,
      extraKmDailyPrice: extraKmDailyPrice,
      extraKmCost: extraKmCost,
      deliveryType: deliveryType,
      deliveryFee: deliveryFee,
      paymentMethod: paymentMethod,
      isCashDiscountApplied: isEligibleForCashDiscount,
      discountAmount: discountAmount,
      finalPrice: finalPrice,
    );
  }

  /// Adrese teslimat için nakit ödeme seçilebilir mi kontrolü
  static bool isPaymentMethodAllowed({
    required DeliveryType deliveryType,
    required PaymentMethod paymentMethod,
  }) {
    if (deliveryType == DeliveryType.address &&
        paymentMethod == PaymentMethod.cashAtBranch) {
      return false; // Adrese teslimde şubede nakit kesinlikle seçilemez
    }
    return true;
  }
}
