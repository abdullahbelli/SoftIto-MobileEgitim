import 'dart:convert';

/// BoardConnect kullanıcı modeli
class UserModel {
  final String id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final bool isGuest;
  final DateTime joinedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.isGuest = false,
    required this.joinedAt,
  });

  String get displayName {
    if (isGuest) return '$username (Misafir)';
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    return username;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'avatarUrl': avatarUrl,
      'isGuest': isGuest,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      avatarUrl: map['avatarUrl'],
      isGuest: map['isGuest'] ?? false,
      joinedAt: map['joinedAt'] != null
          ? DateTime.parse(map['joinedAt'])
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

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
      id: id ?? this.id,
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
