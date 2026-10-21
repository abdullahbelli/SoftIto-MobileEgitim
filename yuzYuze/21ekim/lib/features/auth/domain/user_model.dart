import 'dart:convert'; // JSON serileştirme (encode/decode) işlemleri için Dart standart kütüphanesini içe aktarır.

/// BoardConnect kullanıcı veri modeli
/// Sistemdeki kayıtlı veya misafir kullanıcıların verilerini taşıyan değişmez (immutable) veri sınıfıdır.
class UserModel {
  final String id; // Kullanıcının benzersiz kimlik numarası (UUID).
  final String email; // Kullanıcının sisteme kayıtlı e-posta adresi.
  final String username; // Kullanıcının sistemdeki kullanıcı adı (@rumuz).
  final String firstName; // Kullanıcının adı.
  final String lastName; // Kullanıcının soyadı.
  final String? avatarUrl; // Kullanıcının profil fotoğrafı internet adresi (opsiyonel / null olabilir).
  final bool isGuest; // Kullanıcının şifresiz misafir hesabı olup olmadığını belirten bayrak.
  final DateTime
  joinedAt; // Kullanıcının hesabı oluşturduğu veya odaya girdiği tarih ve saat.

  // Değişmez (immutable) yapıcı metot (constructor).
  const UserModel({
    required this.id, // Zorunlu kimlik alanı.
    required this.email, // Zorunlu e-posta alanı.
    required this.username, // Zorunlu kullanıcı adı alanı.
    required this.firstName, // Zorunlu ad alanı.
    required this.lastName, // Zorunlu soyad alanı.
    this.avatarUrl, // Opsiyonel profil fotoğrafı.
    this.isGuest =
        false, // Varsayılan olarak kayıtlı kullanıcı kabul edilir (false).
    required this.joinedAt, // Zorunlu katılım tarihi.
  });

  /// Kullanıcının arayüzde (ekranda) görüntülenecek en uygun adını hesaplayan 'getter' fonksiyonu.
  String get displayName {
    // Eğer kullanıcı misafirse sonuna '(Misafir)' ibaresi ekler.
    if (isGuest) return '$username (Misafir)';
    // İsim veya soyisim girilmişse ikisini birleştirip kenar boşluklarını silerek döndürür.
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    // İsim-soyisim boş ise kullanıcı adını gösterir.
    return username;
  }

  /// Model nesnesini veritabanına veya hafızaya yazmak üzere Dart anahtar-değer haritasına (Map) dönüştürür.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': avatarUrl,
      'isGuest': isGuest,
      'joinedAt': joinedAt.toIso8601String(), // DateTime nesnesini standart ISO-8601 metnine çevirir.
    };
  }

  /// Map (harita) verisini okuyarak yeni bir UserModel nesnesi inşa eden fabrika (factory) kurucu metodu.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '', // Değer null ise varsayılan olarak boş metin atar.
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      avatarUrl: map['avatarUrl'], // Null olabilir.
      isGuest: map['isGuest'] ?? false, // Null ise varsayılan false.
      // ISO-8601 string tarihini DateTime nesnesine çevirir; yoksa mevcut anı alır.
      joinedAt: map['joinedAt'] != null
          ? DateTime.parse(map['joinedAt'])
          : DateTime.now(),
    );
  }

  /// Modeli JSON dizesine (string) dönüştürür (LocalStorage ve ağ transferi için).
  String toJson() => json.encode(toMap());

  /// JSON dizesini (string) çözümleyip UserModel nesnesi üreten fabrika kurucusu.
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  /// Mevcut nesnenin değerlerini koruyarak yalnızca istenen alanlarını değiştiren kopyalama fonksiyonu.
  /// İmmutable (değişmez) mimaride durum güncellemeleri için vazgeçilmez bir kalıptır.
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    bool? isGuest,
    DateTime? joinedAt,
  }) {
    return UserModel(
      id:
          id ??
          this.id, // Yeni değer verilmişse onu al, verilmemişse eskisini koru.
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGuest: isGuest ?? this.isGuest,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
