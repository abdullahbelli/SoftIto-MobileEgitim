import '../../../core/constants/app_constants.dart';

/// Rotiva araç kiralama rezervasyon modeli.
class Rental {
  final String id;
  final String reservationCode;
  final String customerId;
  final String customerName;
  final String vehicleId;
  final String vehicleName;
  final DateTime startDate;
  final DateTime endDate;
  final int rentalDays;
  final int dailyKmLimitChosen;
  final bool hasExtraKm;
  final double additionalKmCost;
  final DeliveryType deliveryType;
  final String? deliveryAddress;
  final PaymentMethod paymentMethod;
  final double basePrice;
  final double deliveryFee;
  final double discount;
  final double finalPrice;
  final PaymentStatus paymentStatus;
  final RentalStatus rentalStatus;
  final DateTime agreementAcceptedAt;
  final DateTime createdAt;

  const Rental({
    required this.id,
    required this.reservationCode,
    required this.customerId,
    required this.customerName,
    required this.vehicleId,
    required this.vehicleName,
    required this.startDate,
    required this.endDate,
    required this.rentalDays,
    required this.dailyKmLimitChosen,
    required this.hasExtraKm,
    required this.additionalKmCost,
    required this.deliveryType,
    this.deliveryAddress,
    required this.paymentMethod,
    required this.basePrice,
    required this.deliveryFee,
    required this.discount,
    required this.finalPrice,
    required this.paymentStatus,
    required this.rentalStatus,
    required this.agreementAcceptedAt,
    required this.createdAt,
  });

  bool get isCompleted => rentalStatus == RentalStatus.completed;
  bool get isActive => rentalStatus == RentalStatus.active;
  bool get isApproved => rentalStatus == RentalStatus.approved;
  bool get isCancelled => rentalStatus == RentalStatus.cancelled;

  Rental copyWith({
    String? id,
    String? reservationCode,
    String? customerId,
    String? customerName,
    String? vehicleId,
    String? vehicleName,
    DateTime? startDate,
    DateTime? endDate,
    int? rentalDays,
    int? dailyKmLimitChosen,
    bool? hasExtraKm,
    double? additionalKmCost,
    DeliveryType? deliveryType,
    String? deliveryAddress,
    PaymentMethod? paymentMethod,
    double? basePrice,
    double? deliveryFee,
    double? discount,
    double? finalPrice,
    PaymentStatus? paymentStatus,
    RentalStatus? rentalStatus,
    DateTime? agreementAcceptedAt,
    DateTime? createdAt,
  }) {
    return Rental(
      id: id ?? this.id,
      reservationCode: reservationCode ?? this.reservationCode,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      vehicleId: vehicleId ?? this.vehicleId,
      vehicleName: vehicleName ?? this.vehicleName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      rentalDays: rentalDays ?? this.rentalDays,
      dailyKmLimitChosen: dailyKmLimitChosen ?? this.dailyKmLimitChosen,
      hasExtraKm: hasExtraKm ?? this.hasExtraKm,
      additionalKmCost: additionalKmCost ?? this.additionalKmCost,
      deliveryType: deliveryType ?? this.deliveryType,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      basePrice: basePrice ?? this.basePrice,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      finalPrice: finalPrice ?? this.finalPrice,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      rentalStatus: rentalStatus ?? this.rentalStatus,
      agreementAcceptedAt: agreementAcceptedAt ?? this.agreementAcceptedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservationCode': reservationCode,
      'customerId': customerId,
      'customerName': customerName,
      'vehicleId': vehicleId,
      'vehicleName': vehicleName,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'rentalDays': rentalDays,
      'dailyKmLimitChosen': dailyKmLimitChosen,
      'hasExtraKm': hasExtraKm,
      'additionalKmCost': additionalKmCost,
      'deliveryType': deliveryType.name,
      'deliveryAddress': deliveryAddress,
      'paymentMethod': paymentMethod.name,
      'basePrice': basePrice,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'finalPrice': finalPrice,
      'paymentStatus': paymentStatus.name,
      'rentalStatus': rentalStatus.name,
      'agreementAcceptedAt': agreementAcceptedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id: json['id'] as String,
      reservationCode: json['reservationCode'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String? ?? 'Müşteri',
      vehicleId: json['vehicleId'] as String,
      vehicleName: json['vehicleName'] as String? ?? 'Araç',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      rentalDays: json['rentalDays'] as int,
      dailyKmLimitChosen: json['dailyKmLimitChosen'] as int,
      hasExtraKm: json['hasExtraKm'] as bool? ?? false,
      additionalKmCost: (json['additionalKmCost'] as num).toDouble(),
      deliveryType: DeliveryType.values.firstWhere(
        (e) => e.name == json['deliveryType'],
        orElse: () => DeliveryType.branch,
      ),
      deliveryAddress: json['deliveryAddress'] as String?,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == json['paymentMethod'],
        orElse: () => PaymentMethod.creditCard,
      ),
      basePrice: (json['basePrice'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      finalPrice: (json['finalPrice'] as num).toDouble(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.simulatedPaid,
      ),
      rentalStatus: RentalStatus.values.firstWhere(
        (e) => e.name == json['rentalStatus'],
        orElse: () => RentalStatus.approved,
      ),
      agreementAcceptedAt: DateTime.parse(
        json['agreementAcceptedAt'] as String,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
