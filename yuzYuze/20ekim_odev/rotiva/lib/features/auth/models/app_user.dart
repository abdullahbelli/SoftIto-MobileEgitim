// Kullanıcı rollerini (customer, admin) içeren sabitler dosyasını içeri aktarıyoruz.
import '../../../core/constants/app_constants.dart';

/// Rotiva kullanıcı veri modeli (Müşteri ve Yönetici).
/// Immutable (değiştirilemez) bir modeldir; alanlar final olarak tanımlanmıştır.
class AppUser {
  final String id; // Kullanıcının benzersiz kimliği (Örn: usr_1, usr_admin)
  final String fullName; // Kullanıcının adı ve soyadı
  final String email; // Kullanıcının sisteme giriş e-posta adresi
  final String phone; // Kullanıcının iletişim telefon numarası
  final UserRole role; // Kullanıcının yetki rolü (Müşteri veya Yönetici)
  final String password; // Demo kimlik doğrulama kontrolü için şifre
  final DateTime?
  driverBirthDate; // Sürücü doğrulama için doğum tarihi (nullable)
  final DateTime? licenseIssueDate; // Sürücü ehliyet alış tarihi (nullable)
  final DateTime createdAt; // Hesabın oluşturulma tarihi
  final double?
  userScore; // Müşterinin kiralama güven puanı (1.0 - 5.0, nullable)

  // Bellek optimizasyonu için const constructor tanımlıyoruz.
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.password,
    this.driverBirthDate,
    this.licenseIssueDate,
    required this.createdAt,
    this.userScore,
  });

  // Kullanıcının yönetici yetkisine sahip olup olmadığını kontrol eden pratik getter
  bool get isAdmin => role == UserRole.admin;
  // Kullanıcının standart müşteri rolünde olup olmadığını kontrol eden pratik getter
  bool get isCustomer => role == UserRole.customer;

  /// Değiştirilemez (immutable) nesnelerin belirli alanlarını kopyalayarak güncellemek için copyWith deseni
  AppUser copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phone,
    UserRole? role,
    String? password,
    DateTime? driverBirthDate,
    DateTime? licenseIssueDate,
    DateTime? createdAt,
    double? userScore,
  }) {
    return AppUser(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      password: password ?? this.password,
      driverBirthDate: driverBirthDate ?? this.driverBirthDate,
      licenseIssueDate: licenseIssueDate ?? this.licenseIssueDate,
      createdAt: createdAt ?? this.createdAt,
      userScore: userScore ?? this.userScore,
    );
  }

  /// Modeli yerel SharedPreferences'ta saklamak için Map/JSON yapısına dönüştüren metot
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role.name, // Enum değerini string ismine çeviriyoruz.
      'password': password,
      'driverBirthDate': driverBirthDate?.toIso8601String(), // Tarihi standart ISO string formatına çeviriyoruz.
      'licenseIssueDate': licenseIssueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'userScore': userScore,
    };
  }

  /// JSON verisinden Dart nesnesi üreten isimlendirilmiş kurucu metot (Factory Constructor)
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      // String rol adını ilgili UserRole enum değerine eşleştiriyoruz.
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.customer,
      ),
      password: json['password'] as String? ?? '123456',
      driverBirthDate: json['driverBirthDate'] != null
          ? DateTime.tryParse(json['driverBirthDate'] as String)
          : null,
      licenseIssueDate: json['licenseIssueDate'] != null
          ? DateTime.tryParse(json['licenseIssueDate'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      userScore: (json['userScore'] as num?)?.toDouble(),
    );
  }
}
