import 'user_model.dart';

/// Kimlik doğrulama işlemleri için soyut repository arayüzü
/// Supabase entegrasyonu yapıldığında bu arayüz uygulanacaktır.
abstract class AuthRepository {
  /// Mevcut oturum açmış kullanıcıyı döndürür
  Future<UserModel?> getCurrentUser();

  /// E-posta ve şifre ile giriş
  Future<UserModel> login(String email, String password);

  /// Yeni kullanıcı kaydı
  Future<UserModel> register({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
  });

  /// Misafir girişi (İsim ve oda kodu ile)
  Future<UserModel> guestLogin({
    required String name,
    required String roomCode,
  });

  /// E-posta doğrulama OTP kodu gönderimi (90 saniye geçerli)
  Future<void> sendVerificationOtp(String email);

  /// 6 haneli OTP doğrulama
  Future<bool> verifyOtp(String email, String code);

  /// Şifre sıfırlama OTP kodu gönderimi
  Future<void> sendPasswordResetOtp(String email);

  /// Şifre sıfırlama işlemi
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  /// Oturumu kapat
  Future<void> logout();
}
