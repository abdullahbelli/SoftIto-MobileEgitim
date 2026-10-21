import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod durum yönetimi bileşenlerini (StateNotifier, AsyncValue) içe aktarır.

import 'package:boardconnect/app/theme/theme_provider.dart'; // SharedPreferences sağlayıcısını içe aktarır.

import '../../data/mock_auth_repository.dart'; // Yerel mock kimlik doğrulama deposunu içe aktarır.
import '../../domain/auth_repository.dart'; // Kimlik doğrulama sözleşmesini (arayüz) içe aktarır.
import '../../domain/user_model.dart'; // Kullanıcı veri modelini içe aktarır.

/// Kimlik Doğrulama Repository Provider'ı
/// Riverpod Provider yapısı; SharedPreferences örneğini alarak MockAuthRepository nesnesi üretir ve sunar.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final prefs = ref.watch(
    sharedPreferencesProvider,
  ); // SharedPreferences bağımlılığını okur.
  return MockAuthRepository(prefs); // Depo nesnesini döndürür.
});

/// Kimlik Doğrulama Durum Yöneticisi (Controller)
/// `StateNotifier<AsyncValue<UserModel?>>`, kullanıcının oturum durumunu asenkron olarak
/// (yükleniyor, veri geldi, hata oluştu durumlarıyla) yöneten reaktif kontrol sınıfıdır.
class AuthController extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository
  _repository; // Kimlik doğrulama işlemlerini gerçekleştirecek depo referansı.

  // Kurucu fonksiyon: Başlangıç durumunu 'AsyncValue.loading()' (yükleniyor) yapar ve kayıtlı oturumu sorgular.
  AuthController(this._repository) : super(const AsyncValue.loading()) {
    checkCurrentUser(); // Uygulama açılışında kayıtlı kullanıcı olup olmadığını kontrol eder.
  }

  /// Cihazda önceden açık kalmış bir oturum olup olmadığını kontrol eden fonksiyon.
  Future<void> checkCurrentUser() async {
    try {
      final user = await _repository
          .getCurrentUser(); // Hafızadaki oturumu sorgular.
      state = AsyncValue.data(
        user,
      ); // Başarılı sonucu (kullanıcı veya null) duruma atar.
    } catch (e, st) {
      state = AsyncValue.error(
        e,
        st,
      ); // Hata durumunu ve hata yığınını (stack trace) kaydeder.
    }
  }

  /// Kullanıcı girişi fonksiyonu
  /// [email]: Giriş e-postası, [password]: Giriş şifresi
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading(); // Ekranın yükleniyor moduna geçmesi için durumu loading yapar.
    try {
      final user = await _repository.login(
        email,
        password,
      ); // Depodan giriş işlemini çağırır.
      state = AsyncValue.data(
        user,
      ); // Giriş başarılıysa kullanıcı verisini duruma yazar.
    } catch (e, st) {
      state = AsyncValue.error(e, st); // Hata durumunu günceller.
      rethrow; // UI katmanında da hata mesajı gösterilebilmesi için hatayı tekrar fırlatır.
    }
  }

  /// Yeni kullanıcı kaydı fonksiyonu
  Future<void> register({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    state = const AsyncValue.loading(); // Yükleniyor durumuna geçirir.
    try {
      // Depodaki kayıt metodunu çağırır.
      final user = await _repository.register(
        email: email,
        password: password,
        username: username,
        firstName: firstName,
        lastName: lastName,
      );
      state = AsyncValue.data(
        user,
      ); // Kayıt başarılıysa kullanıcıyı duruma bağlar.
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow; // Arayüzün yakalaması için fırlatır.
    }
  }

  /// Odaya misafir olarak giriş yapma fonksiyonu
  Future<void> guestLogin({
    required String name,
    required String roomCode,
  }) async {
    state = const AsyncValue.loading(); // Yükleme animasyonunu başlatır.
    try {
      final user = await _repository.guestLogin(name: name, roomCode: roomCode);
      state = AsyncValue.data(user); // Misafir profilini duruma kaydeder.
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// E-posta doğrulama OTP kodu gönderimi talebi
  Future<void> sendVerificationOtp(String email) async {
    await _repository.sendVerificationOtp(email);
  }

  /// Girilen 6 haneli OTP kodunu doğrulama talebi
  Future<bool> verifyOtp(String email, String code) async {
    return await _repository.verifyOtp(email, code);
  }

  /// Şifre sıfırlama talebi başlatma
  Future<void> sendPasswordResetOtp(String email) async {
    await _repository.sendPasswordResetOtp(email);
  }

  /// Yeni şifreyi onaylayıp kaydetme
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

  /// Kullanıcı oturumunu kapatma fonksiyonu
  Future<void> logout() async {
    await _repository.logout(); // Depodaki oturum verisini siler.
    state = const AsyncValue.data(
      null,
    ); // Durumu 'kullanıcı yok' (null) verisine çekerek oturumu kapatır.
  }
}

/// Tüm uygulama bileşenlerinin oturum durumunu takip edebilmesi için tanımlanan sağlayıcı.
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<UserModel?>>((ref) {
      final repo = ref.watch(authRepositoryProvider); // Depoyu çözer.
      return AuthController(repo); // Yeni denetleyici örneğini döndürür.
    });
