/// Kullanıcı profil modeli.
/// İsim, soyisim, kullanıcı adı, e-posta ve lig katılım onayını tutar.
class UserProfile {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String? avatarPath;
  final DateTime joinedAt;
  final bool leaderboardOptIn;

  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    this.avatarPath,
    required this.joinedAt,
    this.leaderboardOptIn = false,
  });

  String get fullName => '$firstName $lastName'.trim();
  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  UserProfile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? username,
    String? avatarPath,
    DateTime? joinedAt,
    bool? leaderboardOptIn,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarPath: avatarPath ?? this.avatarPath,
      joinedAt: joinedAt ?? this.joinedAt,
      leaderboardOptIn: leaderboardOptIn ?? this.leaderboardOptIn,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'username': username,
      'avatarPath': avatarPath,
      'joinedAt': joinedAt.toIso8601String(),
      'leaderboardOptIn': leaderboardOptIn,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String? ?? 'user_1',
      firstName: map['firstName'] as String? ?? 'Kullanıcı',
      lastName: map['lastName'] as String? ?? '',
      email: map['email'] as String? ?? 'kullanici@ritmia.app',
      username: map['username'] as String? ?? 'ritmiakullanici',
      avatarPath: map['avatarPath'] as String?,
      joinedAt: map['joinedAt'] != null
          ? DateTime.tryParse(map['joinedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      leaderboardOptIn: map['leaderboardOptIn'] as bool? ?? false,
    );
  }
}
