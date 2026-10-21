import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:boardconnect/app/theme/theme_provider.dart';

import '../../domain/auth_repository.dart';
import '../../domain/user_model.dart';
import '../../data/mock_auth_repository.dart';

/// Kimlik Doğrulama Repository Provider'ı
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return MockAuthRepository(prefs);
});

/// Kimlik Doğrulama Durum Yöneticisi
class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncValue.loading()) {
    checkCurrentUser();
  }

  Future<void> checkCurrentUser() async {
    try {
      final user = await _repository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(email, password);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.register(
        email: email,
        password: password,
        username: username,
        firstName: firstName,
        lastName: lastName,
      );
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> guestLogin({
    required String name,
    required String roomCode,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.guestLogin(name: name, roomCode: roomCode);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> sendVerificationOtp(String email) async {
    await _repository.sendVerificationOtp(email);
  }

  Future<bool> verifyOtp(String email, String code) async {
    return await _repository.verifyOtp(email, code);
  }

  Future<void> sendPasswordResetOtp(String email) async {
    await _repository.sendPasswordResetOtp(email);
  }

  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    return await _repository.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AsyncValue.data(null);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
      final repo = ref.watch(authRepositoryProvider);
      return AuthController(repo);
    });
