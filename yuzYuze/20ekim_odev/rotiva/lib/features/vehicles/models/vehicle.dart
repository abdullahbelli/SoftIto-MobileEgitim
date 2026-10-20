// Araç kategorisi, yakıt türü ve vites türü enum'larını içeren sabitler dosyasını içeri aktarıyoruz.
import '../../../core/constants/app_constants.dart';

/// Rotiva kiralık araç veri modeli.
/// Aracın marka, model, yaş/ehliyet şartı, km limitleri ve fiyatlandırma bilgilerini tutar.
class Vehicle {
  final String id; // Aracın benzersiz kimliği (Örn: veh_1)
  final String brand; // Araç markası (Örn: Renault, Fiat)
  final String model; // Araç modeli (Örn: Megane, Egea)
  final int year; // Model üretim yılı (Örn: 2023)
  final VehicleCategory category; // Araç kasa kategorisi (Sedan, SUV vb.)
  final FuelType fuelType; // Yakıt türü (Benzin, Dizel, Elektrik, Hibrit)
  final TransmissionType transmission; // Vites türü (Otomatik, Manuel)
  final String city; // Aracın bulunduğu şehir (Örn: İstanbul)
  final String district; // Aracın bulunduğu ilçe (Örn: Kadıköy)
  final String imagePath; // Araç görsel yolu veya yerel asset referansı
  final double hourlyRate; // Kullanıcıyı bilgilendirme amaçlı saatlik ücret (Demo kuralı gereği kiralama günlük yapılır)
  final double dailyRate; // Asıl günlük kiralama ücreti
  final int minimumAge; // Aracı kiralamak için gereken minimum sürücü yaşı
  final int minimumLicenseYears; // Aracı kiralamak için gereken minimum ehliyet süresi (yıl)
  final int
  dailyKmLimit; // Standart paketteki günlük kilometre sınırı (Örn: 300 km)
  final int additionalDailyKm; // Ekstra kilometre paketinde günlük verilen ilave km (Örn: 150 km)
  final double
  additionalKmDailyPrice; // Ek kilometre paketinin günlük ücreti (Örn: 200 TL)
  final double
  addressDeliveryFee; // Aracın adrese teslim edilme hizmet bedeli (Örn: 400 TL)
  final bool
  isActive; // Aracın kiralama aramalarında görünür olup olmadığı (Aktif/Pasif)

  // Değiştirilemez (immutable) const constructor
  const Vehicle({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    required this.category,
    required this.fuelType,
    required this.transmission,
    required this.city,
    required this.district,
    required this.imagePath,
    required this.hourlyRate,
    required this.dailyRate,
    required this.minimumAge,
    required this.minimumLicenseYears,
    required this.dailyKmLimit,
    required this.additionalDailyKm,
    required this.additionalKmDailyPrice,
    required this.addressDeliveryFee,
    this.isActive = true, // Varsayılan olarak araçlar aktif başlar.
  });

  // Marka ve modeli bir arada gösteren pratik getter (Örn: "Renault Megane")
  String get displayName => '$brand $model';
  // Şehir ve ilçeyi formatlı gösteren getter (Örn: "İstanbul / Kadıköy")
  String get location => '$city / $district';

  /// Aracın kopyasını oluşturup istenen alanları güncelleyen yardımcı copyWith metodu
  Vehicle copyWith({
    String? id,
    String? brand,
    String? model,
    int? year,
    VehicleCategory? category,
    FuelType? fuelType,
    TransmissionType? transmission,
    String? city,
    String? district,
    String? imagePath,
    double? hourlyRate,
    double? dailyRate,
    int? minimumAge,
    int? minimumLicenseYears,
    int? dailyKmLimit,
    int? additionalDailyKm,
    double? additionalKmDailyPrice,
    double? addressDeliveryFee,
    bool? isActive,
  }) {
    return Vehicle(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      category: category ?? this.category,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      city: city ?? this.city,
      district: district ?? this.district,
      imagePath: imagePath ?? this.imagePath,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      dailyRate: dailyRate ?? this.dailyRate,
      minimumAge: minimumAge ?? this.minimumAge,
      minimumLicenseYears: minimumLicenseYears ?? this.minimumLicenseYears,
      dailyKmLimit: dailyKmLimit ?? this.dailyKmLimit,
      additionalDailyKm: additionalDailyKm ?? this.additionalDailyKm,
      additionalKmDailyPrice:
          additionalKmDailyPrice ?? this.additionalKmDailyPrice,
      addressDeliveryFee: addressDeliveryFee ?? this.addressDeliveryFee,
      isActive: isActive ?? this.isActive,
    );
  }

  /// SharedPreferences'ta saklamak üzere Map (JSON) objesine çeviren metot
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'year': year,
      'category': category.name,
      'fuelType': fuelType.name,
      'transmission': transmission.name,
      'city': city,
      'district': district,
      'imagePath': imagePath,
      'hourlyRate': hourlyRate,
      'dailyRate': dailyRate,
      'minimumAge': minimumAge,
      'minimumLicenseYears': minimumLicenseYears,
      'dailyKmLimit': dailyKmLimit,
      'additionalDailyKm': additionalDailyKm,
      'additionalKmDailyPrice': additionalKmDailyPrice,
      'addressDeliveryFee': addressDeliveryFee,
      'isActive': isActive,
    };
  }

  /// JSON sözlüğünden (Map) Vehicle nesnesi inşa eden fabrika kurucusu (Factory Constructor)
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] as String,
      brand: json['brand'] as String,
      model: json['model'] as String,
      year: json['year'] as int,
      category: VehicleCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => VehicleCategory.sedan,
      ),
      fuelType: FuelType.values.firstWhere(
        (e) => e.name == json['fuelType'],
        orElse: () => FuelType.gasoline,
      ),
      transmission: TransmissionType.values.firstWhere(
        (e) => e.name == json['transmission'],
        orElse: () => TransmissionType.automatic,
      ),
      city: json['city'] as String,
      district: json['district'] as String,
      imagePath: json['imagePath'] as String? ?? '',
      hourlyRate: (json['hourlyRate'] as num).toDouble(),
      dailyRate: (json['dailyRate'] as num).toDouble(),
      minimumAge: json['minimumAge'] as int,
      minimumLicenseYears: json['minimumLicenseYears'] as int,
      dailyKmLimit: json['dailyKmLimit'] as int,
      additionalDailyKm: json['additionalDailyKm'] as int,
      additionalKmDailyPrice: (json['additionalKmDailyPrice'] as num)
          .toDouble(),
      addressDeliveryFee: (json['addressDeliveryFee'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
