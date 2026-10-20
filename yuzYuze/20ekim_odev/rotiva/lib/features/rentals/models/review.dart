/// Rotiva araç kiralama değerlendirme ve yorum modeli.
class Review {
  final String id;
  final String rentalId;
  final String vehicleId;
  final String customerId;
  final String customerName;
  final int stars; // 1 ile 5 arası yıldız
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.rentalId,
    required this.vehicleId,
    required this.customerId,
    required this.customerName,
    required this.stars,
    required this.comment,
    required this.createdAt,
  });

  Review copyWith({
    String? id,
    String? rentalId,
    String? vehicleId,
    String? customerId,
    String? customerName,
    int? stars,
    String? comment,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      rentalId: rentalId ?? this.rentalId,
      vehicleId: vehicleId ?? this.vehicleId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      stars: stars ?? this.stars,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rentalId': rentalId,
      'vehicleId': vehicleId,
      'customerId': customerId,
      'customerName': customerName,
      'stars': stars,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      rentalId: json['rentalId'] as String,
      vehicleId: json['vehicleId'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String? ?? 'Müşteri',
      stars: (json['stars'] as int).clamp(1, 5),
      comment: json['comment'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
