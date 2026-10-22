import 'package:uuid/uuid.dart';
import '../../../core/services/storage_service.dart';
import '../models/user_profile.dart';
import 'auth_repository.dart';

/// AuthRepository'nin yerel demo implementasyonu.
/// Gerçek sunucu olmadığı için şifreyi açık metin saklamaz;
/// yerel SharedPreferences üzerinden oturum simülasyonu yürütür.
class LocalAuthRepository implements AuthRepository {
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();

  LocalAuthRepository(this._storageService);

  @override
  Future<UserProfile?> getCurrentUser() async {
    final map = _storageService.getCurrentUser();
    if (map == null) return null;
    return UserProfile.fromMap(map);
  }

  @override
  Future<UserProfile> login(String usernameOrEmail, String password) async {
    // Kısa ağ simülasyonu gecikmesi
    await Future.delayed(const Duration(milliseconds: 400));

    // Var olan kullanıcı kontrolü
    final existing = await getCurrentUser();
    if (existing != null &&
        (existing.username.toLowerCase() == usernameOrEmail.toLowerCase() ||
         existing.email.toLowerCase() == usernameOrEmail.toLowerCase())) {
      return existing;
    }

    // Demo kullanıcı oluşturup giriş yaptır
    final isEmail = usernameOrEmail.contains('@');
    final username = isEmail ? usernameOrEmail.split('@').first : usernameOrEmail;

    final user = UserProfile(
      id: _uuid.v4(),
      firstName: username.isNotEmpty ? username[0].toUpperCase() + username.substring(1) : 'Ritmia',
      lastName: 'Kullanıcısı',
      email: isEmail ? usernameOrEmail : '$username@ritmia.app',
      username: username,
      joinedAt: DateTime.now(),
      leaderboardOptIn: false,
    );

    await _storageService.setCurrentUser(user.toMap());
    return user;
  }

  @override
  Future<UserProfile> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final user = UserProfile(
      id: _uuid.v4(),
      firstName: firstName,
      lastName: lastName,
      email: email,
      username: username,
      joinedAt: DateTime.now(),
      leaderboardOptIn: false,
    );

    await _storageService.setCurrentUser(user.toMap());
    return user;
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    await _storageService.setCurrentUser(profile.toMap());
    return profile;
  }

  @override
  Future<void> logout() async {
    await _storageService.clearSession();
  }
}
