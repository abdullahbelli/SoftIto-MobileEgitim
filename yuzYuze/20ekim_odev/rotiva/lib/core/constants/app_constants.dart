/// Rotiva uygulaması genelinde kullanılan sabit değerler ve yardımcı enum tanımları.
class AppConstants {
  static const String appName = 'Rotiva'; // Uygulamanın adı.
  static const String appTagline =
      'Araç Kiralama ve Takip'; // Uygulamanın sloganı.
  static const String appVersion =
      '1.0.0 (Demo)'; // Uygulamanın versiyon bilgisi.

  // Para birimi simgesi (Türk Lirası)
  static const String currencySymbol = '₺';

  // Şehirler ve ilçeler sözlüğü (Arama ve filtreleme açılır menülerinde kullanılır)
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

  // Şubeden teslim + nakit ödemede uygulanan indirim oranı
  static const double cashDiscountRate = 0.10; // %10 şube nakit indirimi kuralı
}

/// Uygulamadaki kullanıcı rolleri (Yetkilendirme ve ekran ayrımı için kullanılır)
enum UserRole {
  customer, // Müşteri rolü
  admin; // Yönetici rolü

  /// Ekranda kullanıcıya gösterilecek Türkçe metin karşılığı
  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Müşteri';
      case UserRole.admin:
        return 'Yönetici';
    }
  }
}

/// Araç kasa/gövde kategorileri
enum VehicleCategory {
  sedan, // Sedan kasa
  suv, // Arazi / SUV araç
  hatchback, // Kompakt hatchback
  stationWagon, // Geniş bagajlı station wagon
  commercial, // Ticari taşıma aracı / Van
  coupe, // İki kapılı spor / coupe
  luxury; // Premium / lüks sınıf

  /// Kategori adının arayüzdeki Türkçe gösterimi
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

/// Araçların motor/yakıt türleri
enum FuelType {
  gasoline, // Benzinli motor
  diesel, // Dizel motor
  hybrid, // Benzin + Elektrik hibrit motor
  electric; // %100 Elektrikli motor

  /// Yakıt türünün Türkçe arayüz karşılığı
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

/// Şanzıman / vites türleri
enum TransmissionType {
  manual, // Düz / manuel vites
  automatic; // Otomatik vites

  /// Vites tipinin Türkçe gösterimi
  String get displayName {
    switch (this) {
      case TransmissionType.manual:
        return 'Manuel';
      case TransmissionType.automatic:
        return 'Otomatik';
    }
  }
}

/// Aracın teslim alınma şekli
enum DeliveryType {
  branch, // Müşteri aracı şubeden bizzat alır
  address; // Araç müşterinin belirttiği adrese vale ile getirilir

  /// Teslimat türünün arayüzdeki Türkçe adı
  String get displayName {
    switch (this) {
      case DeliveryType.branch:
        return 'Şubeden Teslim';
      case DeliveryType.address:
        return 'Adrese Teslim';
    }
  }
}

/// Desteklenen simüle ödeme yöntemleri
enum PaymentMethod {
  creditCard, // Kredi / banka kartı simülasyonu
  bankTransfer, // Havale / EFT simülasyonu
  cashAtBranch; // Şubede teslim sırasında nakit ödeme simülasyonu

  /// Ödeme yönteminin ekranda gösterilen adı
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

/// Bir kiralamanın güncel işlem durumu
enum RentalStatus {
  approved, // Rezervasyon alındı ve onaylandı
  active, // Araç teslim edildi, kiralama fiilen devam ediyor
  completed, // Araç geri teslim alındı ve kiralama tamamlandı
  cancelled; // Kiralama iptal edildi

  /// Durumun rozetlerde görünen Türkçe metni
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

/// Rezervasyona ait tahsilat / ödeme durumu
enum PaymentStatus {
  simulatedPaid, // Simülasyon gereği tahsilat yapıldı
  payAtBranch, // Araç teslim alınırken şubede ödenecek
  pending; // Ödeme teyidi bekleniyor

  /// Ödeme durumunun arayüzdeki etiketi
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
