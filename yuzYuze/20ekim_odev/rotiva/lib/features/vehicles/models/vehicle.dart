import '../../../core/constants/app_constants.dart';

/// Rotiva kiralık araç modeli.
class Vehicle {
  final String id;
  final String brand;
  final String model;
  final int year;
  final VehicleCategory category;
  final FuelType fuelType;
  final TransmissionType transmission;
  final String city;
  final String district;
  final String imagePath;
  final double hourlyRate; // Bilgi amaçlı saatlik ücret
  final double dailyRate; // Asıl günlük kiralama ücreti
  final int minimumAge; // Sürücü yaş şartı
  final int minimumLicenseYears; // Ehliyet yılı şartı
  final int dailyKmLimit; // Standart günlük km sınırı
  final int additionalDailyKm; // Ek pakette verilen günlük ekstra km
  final double additionalKmDailyPrice; // Ek km paketinin günlük bedeli
  final double addressDeliveryFee; // Adrese teslimat ücreti
  final bool isActive; // Araç aktif/müsait mi

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
    this.isActive = true,
  });

  String get displayName => '$brand $model';
  String get location => '$city / $district';

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
