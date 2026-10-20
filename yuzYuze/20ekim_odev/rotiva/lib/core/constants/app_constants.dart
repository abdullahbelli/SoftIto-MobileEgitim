/// Rotiva uygulaması sabitleri ve yardımcı tanımları.
class AppConstants {
  static const String appName = 'Rotiva';
  static const String appTagline = 'Araç Kiralama ve Takip';
  static const String appVersion = '1.0.0 (Demo)';

  // Para birimi
  static const String currencySymbol = '₺';

  // Şehirler ve ilçeler (Arama ve filtreleme için)
  static const Map<String, List<String>> turkeyCities = {
    'İstanbul': [
      'Kadıköy',
      'Beşiktaş',
      'Şişli',
      'Üsküdar',
      'Bakırköy',
      'Maltepe',
      'Sarıyer',
    ],
    'Ankara': ['Çankaya', 'Yenimahalle', 'Keçiören', 'Etimesgut', 'Gölbaşı'],
    'İzmir': ['Konak', 'Karşıyaka', 'Bornova', 'Alsancak', 'Çeşme', 'Urla'],
    'Antalya': ['Muratpaşa', 'Konyaaltı', 'Alanya', 'Kemer', 'Manavgat'],
    'Bursa': ['Nilüfer', 'Osmangazi', 'Yıldırım', 'Mudanya'],
  };

  // İndirim oranı
  static const double cashDiscountRate = 0.10; // %10 şube nakit indirimi
}

/// Kullanıcı rolleri
enum UserRole {
  customer,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Müşteri';
      case UserRole.admin:
        return 'Yönetici';
    }
  }
}

/// Araç kategorileri
enum VehicleCategory {
  sedan,
  suv,
  hatchback,
  stationWagon,
  commercial,
  coupe,
  luxury;

  String get displayName {
    switch (this) {
      case VehicleCategory.sedan:
        return 'Sedan';
      case VehicleCategory.suv:
        return 'SUV';
      case VehicleCategory.hatchback:
        return 'Hatchback';
      case VehicleCategory.stationWagon:
        return 'Station Wagon';
      case VehicleCategory.commercial:
        return 'Ticari';
      case VehicleCategory.coupe:
        return 'Coupe / Spor';
      case VehicleCategory.luxury:
        return 'Lüks';
    }
  }
}

/// Yakıt türleri
enum FuelType {
  gasoline,
  diesel,
  hybrid,
  electric;

  String get displayName {
    switch (this) {
      case FuelType.gasoline:
        return 'Benzin';
      case FuelType.diesel:
        return 'Dizel';
      case FuelType.hybrid:
        return 'Hibrit';
      case FuelType.electric:
        return 'Elektrik';
    }
  }
}

/// Vites türleri
enum TransmissionType {
  manual,
  automatic;

  String get displayName {
    switch (this) {
      case TransmissionType.manual:
        return 'Manuel';
      case TransmissionType.automatic:
        return 'Otomatik';
    }
  }
}

/// Teslimat türleri
enum DeliveryType {
  branch,
  address;

  String get displayName {
    switch (this) {
      case DeliveryType.branch:
        return 'Şubeden Teslim';
      case DeliveryType.address:
        return 'Adrese Teslim';
    }
  }
}

/// Ödeme yöntemleri
enum PaymentMethod {
  creditCard,
  bankTransfer,
  cashAtBranch;

  String get displayName {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'Kredi Kartı (Simüle)';
      case PaymentMethod.bankTransfer:
        return 'Havale / EFT (Simüle)';
      case PaymentMethod.cashAtBranch:
        return 'Şubede Nakit (Simüle)';
    }
  }
}

/// Kiralama durumu
enum RentalStatus {
  approved,
  active,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case RentalStatus.approved:
        return 'Onaylandı';
      case RentalStatus.active:
        return 'Aktif';
      case RentalStatus.completed:
        return 'Tamamlandı';
      case RentalStatus.cancelled:
        return 'İptal Edildi';
    }
  }
}

/// Ödeme durumu
enum PaymentStatus {
  simulatedPaid,
  payAtBranch,
  pending;

  String get displayName {
    switch (this) {
      case PaymentStatus.simulatedPaid:
        return 'Ödendi (Simüle)';
      case PaymentStatus.payAtBranch:
        return 'Şubede Ödenecek';
      case PaymentStatus.pending:
        return 'Beklemede';
    }
  }
}
