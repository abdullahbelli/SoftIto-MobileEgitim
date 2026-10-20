// Sabitler, tarih araçları ve araç modelini içeri aktarıyoruz.
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../vehicles/models/vehicle.dart';

/// Kiralama fiyatlandırma detay ve sonuç veri modeli.
/// Günlük ücret, gün sayısı, taban fiyat, ek km, teslimat bedeli ve nakit indirim dökümünü tutar.
class RentalPricingResult {
  final int rentalDays; // Hesaba dahil edilen toplam gün sayısı
  final double dailyRate; // Aracın uygulanan günlük kiralama ücreti
  final double
  basePrice; // rentalDays * dailyRate formülüyle elde edilen taban ücret
  final bool hasExtraKm; // Ekstra kilometre paketi seçildi mi?
  final double extraKmDailyPrice; // Ek paketin günlük birim fiyatı
  final double extraKmCost; // rentalDays * extraKmDailyPrice ile hesaplanan toplam ek km maliyeti
  final DeliveryType deliveryType; // Teslimat şekli (Şubeden veya Adrese)
  final double deliveryFee; // Adrese teslim bedeli (Şubeden teslimse 0.0)
  final PaymentMethod? paymentMethod; // Seçilen ödeme yöntemi (belirtilmişse)
  final bool
  isCashDiscountApplied; // %10 nakit indiriminin uygulanıp uygulanmadığı
  final double discountAmount; // (basePrice + extraKmCost) üzerinden düşülen %10 indirim miktarı
  final double finalPrice; // basePrice + extraKmCost + deliveryFee - discountAmount ile ulaşılan nihai ödeme tutarı

  // Değiştirilemez (immutable) const constructor
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

  /// Ara toplamı (indirim ve teslimat öncesi araç + ek km bedeli) veren pratik getter
  double get subtotal => basePrice + extraKmCost;
}

/// Rotiva kiralama fiyat hesaplama motoru (Pure Business Logic).
/// İş kurallarını (business logic) UI bileşenlerinden izole eder; kolayca birim test (Unit Test) yapılabilir.
class RentalPricing {
  /// Kiralama fiyatını tüm parametreleri değerlendirerek hesaplar.
  static RentalPricingResult calculate({
    required Vehicle vehicle,
    required DateTime startDate,
    required DateTime endDate,
    required DeliveryType deliveryType,
    required bool hasExtraKm,
    PaymentMethod? paymentMethod,
  }) {
    // 1. Gün sayısı hesaplama (En az 1 tam gün baz alınır)
    final rentalDays = RotivaDateUtils.calculateRentalDays(startDate, endDate);

    // 2. Taban araç kiralama bedeli (Gün × Günlük Ücret)
    final basePrice = rentalDays * vehicle.dailyRate;

    // 3. Ek kilometre paketi bedeli (Seçilmişse gün ile çarpılır, seçilmemişse 0)
    final extraKmDailyPrice = hasExtraKm ? vehicle.additionalKmDailyPrice : 0.0;
    final extraKmCost = rentalDays * extraKmDailyPrice;

    // 4. Adrese teslimat ücreti (Yalnızca adrese teslimat seçildiyse yansıtılır)
    final deliveryFee = (deliveryType == DeliveryType.address)
        ? vehicle.addressDeliveryFee
        : 0.0;

    // 5. Şubede Nakit İndirimi Kuralı (PROJECT.md Madde 7):
    // Şubeden teslim + Şubede nakit ödeme ise (araç bedeli + ek km bedeli) üzerinden %10 indirim uygulanır.
    final bool isEligibleForCashDiscount =
        deliveryType == DeliveryType.branch &&
        paymentMethod == PaymentMethod.cashAtBranch;

    final double discountAmount = isEligibleForCashDiscount
        ? (basePrice + extraKmCost) * AppConstants.cashDiscountRate
        : 0.0;

    // 6. Nihai toplam tutar (Taban + Ek KM + Teslimat - İndirim)
    final rawTotal = basePrice + extraKmCost + deliveryFee - discountAmount;
    // Kuruş yuvarlaması (floating point hassasiyet hatalarını önlemek için)
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

  /// Adrese teslimat seçildiğinde şubede nakit ödemenin yasaklandığını denetleyen iş kuralı (PROJECT.md Madde 7)
  static bool isPaymentMethodAllowed({
    required DeliveryType deliveryType,
    required PaymentMethod paymentMethod,
  }) {
    if (deliveryType == DeliveryType.address &&
        paymentMethod == PaymentMethod.cashAtBranch) {
      return false; // Adrese teslimatta şubede nakit seçilemez, kredi kartı veya havale zorunludur.
    }
    return true;
  }
}
