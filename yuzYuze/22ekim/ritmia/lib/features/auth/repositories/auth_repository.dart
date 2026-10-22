import '../models/user_profile.dart';

/// Kimlik doğrulama ve kullanıcı oturumu için Repository sözleşmesi.
/// İleride gerçek backend API'si bağlandığında bu arayüz korunacaktır.
abstract interface class AuthRepository {
  /// Mevcut açık oturumu döner (varsa)
  Future<UserProfile?> getCurrentUser();

  /// Kullanıcı adı veya e-posta ve şifre ile giriş yapar
  Future<UserProfile> login(String usernameOrEmail, String password);

  /// Yeni kullanıcı kaydı oluşturur
  Future<UserProfile> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  });

  /// Profili günceller
  Future<UserProfile> updateProfile(UserProfile profile);

  /// Oturumu sonlandırır
  Future<void> logout();
}
