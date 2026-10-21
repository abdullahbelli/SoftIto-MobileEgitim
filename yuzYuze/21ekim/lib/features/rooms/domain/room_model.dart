import 'dart:convert'; // JSON kodlama ve çözme işlemleri için standart kütüphaneyi içe aktarır.

/// BoardConnect oda veri modeli
/// Kullanıcıların oluşturduğu veya katıldığı ortak çalışma odalarını temsil eden değişmez (immutable) sınıftır.
class RoomModel {
  final String id; // Odanın benzersiz kimlik numarası (UUID).
  final String
  name; // Odanın adı/başlığı (Örn: "Sprint Planlama", "Tasarım Fikirleri").
  final String ownerId; // Odayı oluşturan kullanıcının kimlik numarası.
  final String ownerName; // Odayı oluşturan kullanıcının adı.
  final String joinCode; // Katılımcıların odaya girmesi için üretilen 6-8 karakterlik kısa kod (Örn: "BC-A1B2").
  final String shareLink; // Odaya doğrudan tarayıcıdan bağlanmak için üretilen paylaşım linki.
  final int
  maxParticipants; // Odaya aynı anda katılabilecek maksimum kişi sayısı.
  final int participantCount; // Odada şu an aktif olan katılımcı sayısı.
  final DateTime createdAt; // Odanın oluşturulma tarihi ve saati.
  final DateTime
  updatedAt; // Odanın veya tuvalin son güncellenme tarihi ve saati.
  final bool isDeleted; // Odanın silinip silinmediğini belirten mantıksal bayrak (soft delete).

  // Değişmez kurucu fonksiyon (Constructor).
  const RoomModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.ownerName,
    required this.joinCode,
    required this.shareLink,
    this.maxParticipants = 10, // Varsayılan maksimum 10 katılımcı.
    this.participantCount = 1, // Başlangıçta odayı açan 1 kişi bulunur.
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false, // Varsayılan olarak silinmemiş (aktif).
  });

  /// Modeli yerel depolama veya veritabanı için harita (Map) yapısına dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'joinCode': joinCode,
      'shareLink': shareLink,
      'maxParticipants': maxParticipants,
      'participantCount': participantCount,
      'createdAt': createdAt
          .toIso8601String(), // Tarihi ISO-8601 metnine çevirir.
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  /// Veritabanından veya yerel hafızadan gelen harita (Map) verisinden RoomModel üreten fabrika kurucusu.
  factory RoomModel.fromMap(Map<String, dynamic> map) {
    return RoomModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      ownerId: map['ownerId'] ?? '',
      ownerName: map['ownerName'] ?? 'Oda Sahibi',
      joinCode: map['joinCode'] ?? '',
      shareLink: map['shareLink'] ?? '',
      maxParticipants: map['maxParticipants'] ?? 10,
      participantCount: map['participantCount'] ?? 1,
      // Tarih metinlerini DateTime nesnesine dönüştürür; null ise mevcut anı atar.
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      isDeleted: map['isDeleted'] ?? false,
    );
  }

  /// Odayı JSON dizesine dönüştürür.
  String toJson() => json.encode(toMap());

  /// JSON dizesini çözümleyerek RoomModel nesnesi üretir.
  factory RoomModel.fromJson(String source) =>
      RoomModel.fromMap(json.decode(source));

  /// Odanın belirli alanlarını değiştirip yeni bir nesne üretmek için kopyalama fonksiyonu.
  RoomModel copyWith({
    String? id,
    String? name,
    String? ownerId,
    String? ownerName,
    String? joinCode,
    String? shareLink,
    int? maxParticipants,
    int? participantCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      joinCode: joinCode ?? this.joinCode,
      shareLink: shareLink ?? this.shareLink,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      participantCount: participantCount ?? this.participantCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
