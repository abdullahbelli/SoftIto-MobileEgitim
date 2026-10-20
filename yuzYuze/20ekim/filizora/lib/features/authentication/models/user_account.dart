/// Kullanıcı Rolleri
enum UserRole {
  entrepreneur,
  investor,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.entrepreneur:
        return 'Girişimci';
      case UserRole.investor:
        return 'Yatırımcı';
      case UserRole.admin:
        return 'Yönetici (Admin)';
    }
  }
}

/// Kullanıcı hesap ve onay durumları
enum ApprovalStatus {
  pendingApproval,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case ApprovalStatus.pendingApproval:
        return 'Yönetici Onayı Bekleniyor';
      case ApprovalStatus.approved:
        return 'Onaylandı';
      case ApprovalStatus.rejected:
        return 'Reddedildi';
    }
  }
}

/// Girişimcinin kayıt sırasında beyan ettiği iş fikri
class BusinessIdea {
  final String title;
  final String sector;
  final String description;

  const BusinessIdea({
    required this.title,
    required this.sector,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'sector': sector,
      'description': description,
    };
  }

  factory BusinessIdea.fromJson(Map<String, dynamic> json) {
    return BusinessIdea(
      title: json['title'] as String? ?? '',
      sector: json['sector'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

/// Girişimci ve Kullanıcı Hesabı Modeli
class UserAccount {
  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final bool hasIdea;
  final BusinessIdea? idea;
  final ApprovalStatus approvalStatus;
  final DateTime createdAt;

  const UserAccount({
    required this.id,
    required this.fullName,
    required this.email,
    this.role = UserRole.entrepreneur,
    this.hasIdea = false,
    this.idea,
    this.approvalStatus = ApprovalStatus.pendingApproval,
    required this.createdAt,
  });

  bool get isApproved => approvalStatus == ApprovalStatus.approved;
  bool get isPending => approvalStatus == ApprovalStatus.pendingApproval;
  bool get isAdmin => role == UserRole.admin;
  bool get isInvestor => role == UserRole.investor;
  bool get isEntrepreneur => role == UserRole.entrepreneur;

  UserAccount copyWith({
    String? id,
    String? fullName,
    String? email,
    UserRole? role,
    bool? hasIdea,
    BusinessIdea? idea,
    ApprovalStatus? approvalStatus,
    DateTime? createdAt,
  }) {
    return UserAccount(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      hasIdea: hasIdea ?? this.hasIdea,
      idea: idea ?? this.idea,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'role': role.name,
      'hasIdea': hasIdea,
      'idea': idea?.toJson(),
      'approvalStatus': approvalStatus.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.entrepreneur,
      ),
      hasIdea: json['hasIdea'] as bool? ?? false,
      idea: json['idea'] != null ? BusinessIdea.fromJson(json['idea'] as Map<String, dynamic>) : null,
      approvalStatus: ApprovalStatus.values.firstWhere(
        (e) => e.name == json['approvalStatus'],
        orElse: () => ApprovalStatus.pendingApproval,
      ),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
