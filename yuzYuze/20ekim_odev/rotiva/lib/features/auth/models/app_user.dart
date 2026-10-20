import '../../../core/constants/app_constants.dart';

/// Rotiva kullanıcı modeli (Müşteri ve Yönetici).
class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final UserRole role;
  final String password; // Demo giriş kontrolü için
  final DateTime? driverBirthDate;
  final DateTime? licenseIssueDate;
  final DateTime createdAt;
  final double? userScore; // Demo müşteri puanı (Örn: 4.8)

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

  bool get isAdmin => role == UserRole.admin;
  bool get isCustomer => role == UserRole.customer;

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'role': role.name,
      'password': password,
      'driverBirthDate': driverBirthDate?.toIso8601String(),
      'licenseIssueDate': licenseIssueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'userScore': userScore,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
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
