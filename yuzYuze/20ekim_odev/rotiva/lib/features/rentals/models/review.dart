/// Rotiva araç kiralama değerlendirme ve yorum veri modeli.
/// Tamamlanan kiralamalar sonrasında müşterilerin verdiği 1-5 arası yıldız puanını ve yorum metnini saklar.
class Review {
  final String id; // Yorum kaydının benzersiz ID'si (Örn: rev_1)
  final String rentalId; // Bu yorumun ait olduğu kiralama kaydının ID'si
  final String vehicleId; // Yorum yapılan aracın ID'si
  final String customerId; // Yorumu yazan müşterinin ID'si
  final String customerName; // Yorumu yazan müşterinin adı ve soyadı
  final int
  stars; // 1 ile 5 arasında verilen değerlendirme puanı (yıldız sayısı)
  final String
  comment; // Müşterinin araç ve kiralama deneyimi hakkındaki yorum metni
  final DateTime createdAt; // Yorumun yazıldığı tarih ve saat

  // Değiştirilemez (immutable) const constructor
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

  /// Değiştirilmek istenen alanları kopyalayarak yeni bir Review örneği oluşturan copyWith metodu
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

  /// SharedPreferences kalıcılığı için modeli Map yapısına dönüştüren metot
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

  /// JSON verisinden Review nesnesi inşa eden fabrika kurucusu
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      rentalId: json['rentalId'] as String,
      vehicleId: json['vehicleId'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String? ?? 'Müşteri',
      // Puanın mutlaka 1 ile 5 arasında kalmasını clamp ile garanti ediyoruz.
      stars: (json['stars'] as int).clamp(1, 5),
      comment: json['comment'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
