import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/auth_repository.dart';
import '../domain/user_model.dart';

/// Supabase öncesi yerel ve kalıcı çalışan Mock Kimlik Doğrulama Servisi
class MockAuthRepository implements AuthRepository {
  final SharedPreferences _prefs;
  final _uuid = const Uuid();

  // Kayıtlı kullanıcılar havuzu (yerel hafıza ve SharedPreferences)
  static const String _usersStorageKey = 'bc_registered_users';

  MockAuthRepository(this._prefs) {
    _initDefaultUser();
  }

  void _initDefaultUser() {
    final usersJson = _prefs.getString(_usersStorageKey);
    if (usersJson == null) {
      final defaultUser = UserModel(
        id: 'user_demo_1',
        email: 'demo@boardconnect.com',
        username: 'boardmaster',
        firstName: 'Ali',
        lastName: 'Demir',
        joinedAt: DateTime.now(),
      );
      final usersMap = {
        defaultUser.email: {
          'user': defaultUser.toMap(),
          'password': 'Password123*',
        },
      };
      _prefs.setString(_usersStorageKey, json.encode(usersMap));
    }
  }

  Map<String, dynamic> _getStoredUsers() {
    final usersJson = _prefs.getString(_usersStorageKey);
    if (usersJson == null) return {};
    return json.decode(usersJson) as Map<String, dynamic>;
  }

  Future<void> _saveStoredUsers(Map<String, dynamic> users) async {
    await _prefs.setString(_usersStorageKey, json.encode(users));
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final userJson = _prefs.getString(AppConstants.prefsKeyCurrentUser);
    if (userJson == null) return null;
    try {
      return UserModel.fromJson(userJson);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final users = _getStoredUsers();
    final lowerEmail = email.trim().toLowerCase();

    if (!users.containsKey(lowerEmail)) {
      throw const AppException(
        'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.',
      );
    }

    final userData = users[lowerEmail] as Map<String, dynamic>;
    if (userData['password'] != password) {
      throw const AppException('Girdiğiniz şifre hatalı.');
    }

    final user = UserModel.fromMap(userData['user'] as Map<String, dynamic>);
    await _prefs.setString(AppConstants.prefsKeyCurrentUser, user.toJson());
    return user;
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final users = _getStoredUsers();
    final lowerEmail = email.trim().toLowerCase();

    if (users.containsKey(lowerEmail)) {
      throw const AppException('Bu e-posta adresi zaten kullanımda.');
    }

    final newUser = UserModel(
      id: 'user_${_uuid.v4().substring(0, 8)}',
      email: lowerEmail,
      username: username.trim(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      joinedAt: DateTime.now(),
    );

    users[lowerEmail] = {'user': newUser.toMap(), 'password': password};

    await _saveStoredUsers(users);
    await _prefs.setString(AppConstants.prefsKeyCurrentUser, newUser.toJson());
    return newUser;
  }

  @override
  Future<UserModel> guestLogin({
    required String name,
    required String roomCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final guestUser = UserModel(
      id: 'guest_${_uuid.v4().substring(0, 8)}',
      email: 'guest@boardconnect.local',
      username: name.trim().isEmpty ? 'Misafir' : name.trim(),
      firstName: name.trim(),
      lastName: '',
      isGuest: true,
      joinedAt: DateTime.now(),
    );

    await _prefs.setString(
      AppConstants.prefsKeyCurrentUser,
      guestUser.toJson(),
    );
    return guestUser;
  }

  @override
  Future<void> sendVerificationOtp(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Demo simülasyonu: 6 haneli kod '123456' olarak belirlenmiştir.
  }

  @override
  Future<bool> verifyOtp(String email, String code) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (code.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(code)) {
      throw const AppException(
        'Kod 6 haneli ve yalnızca rakamlardan oluşmalıdır.',
      );
    }
    // Demo ortamında '123456' veya geçerli 6 haneli sayı doğrulanır
    return true;
  }

  @override
  Future<void> sendPasswordResetOtp(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final users = _getStoredUsers();
    final lowerEmail = email.trim().toLowerCase();
    if (!users.containsKey(lowerEmail)) {
      throw const AppException(
        'Bu e-posta adresiyle eşleşen hesap bulunamadı.',
      );
    }
  }

  @override
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final users = _getStoredUsers();
    final lowerEmail = email.trim().toLowerCase();

    if (!users.containsKey(lowerEmail)) {
      throw const AppException('Kullanıcı hesabı bulunamadı.');
    }

    if (code.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(code)) {
      throw const AppException(
        'Kod 6 haneli ve yalnızca rakamlardan oluşmalıdır.',
      );
    }

    final userData = users[lowerEmail] as Map<String, dynamic>;
    userData['password'] = newPassword;
    users[lowerEmail] = userData;
    await _saveStoredUsers(users);
    return true;
  }

  @override
  Future<void> logout() async {
    await _prefs.remove(AppConstants.prefsKeyCurrentUser);
  }
}
