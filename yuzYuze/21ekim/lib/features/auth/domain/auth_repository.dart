import 'user_model.dart'; // Kimlik doğrulama işlemlerinde kullanılan UserModel veri modelini içe aktarır.

/// Kimlik doğrulama işlemleri için soyut repository arayüzü (Interface / Contract).
/// 'abstract class' yapısı, metotların gövdesini (nasıl yapıldığını) değil, yalnızca imzasını (ne yapıldığını) tanımlar.
/// Böylece arayüz katmanı, arka plandaki veritabanından (Mock veya Supabase) bağımsız hale gelir (Dependency Inversion prensibi).
abstract class AuthRepository {
  /// Cihaz hafızasındaki veya sunucudaki mevcut oturum açmış kullanıcıyı asenkron olarak döndürür.
  /// Kullanıcı oturum açmamışsa 'null' döner (UserModel?).
  Future<UserModel?> getCurrentUser();

  /// E-posta ve şifre ikilisiyle sisteme giriş yapmayı dener.
  /// [email]: Kullanıcının kayıtlı e-posta adresi.
  /// [password]: Kullanıcının gizli şifresi.
  /// Başarılı olursa oturum açan [UserModel] nesnesini döndürür.
  Future<UserModel> login(String email, String password);

  /// Yeni bir kullanıcı hesabı oluşturur.
  /// İsimli ve zorunlu (required) parametreler alarak güvenli veri aktarımı sağlar.
  /// Başarılı kayıt neticesinde oluşturulan [UserModel] nesnesini döndürür.
  Future<UserModel> register({
    required String email, // Kayıt olacak e-posta adresi
    required String password, // Kullanıcının belirlediği şifre
    required String username, // Benzersiz kullanıcı adı
    required String firstName, // Kullanıcının adı
    required String lastName, // Kullanıcının soyadı
  });

  /// Hesap oluşturmadan doğrudan odaya bağlanmak isteyenler için misafir girişi oluşturur.
  /// [name]: Misafirin tuvalde görünecek takma adı (display name).
  /// [roomCode]: Katılmak istediği odanın paylaşım kodu.
  /// Misafir yetkilerine sahip geçici bir [UserModel] döndürür.
  Future<UserModel> guestLogin({
    required String name,
    required String roomCode,
  });

  /// E-posta doğrulama için 6 haneli ve 90 saniye geçerli tek kullanımlık şifre (OTP) gönderir.
  /// [email]: Kodun gönderileceği hedef e-posta adresi.
  Future<void> sendVerificationOtp(String email);

  /// Kullanıcının girdiği 6 haneli OTP kodunun geçerliliğini kontrol eder.
  /// [email]: Kodun ait olduğu e-posta adresi.
  /// [code]: Kullanıcının girdiği 6 haneli rakamsal kod.
  /// Kod doğru ve süresi geçmemişse 'true', aksi halde 'false' döner.
  Future<bool> verifyOtp(String email, String code);

  /// Şifresini unutan kullanıcıya e-posta üzerinden 6 haneli sıfırlama kodu gönderir.
  /// [email]: Sıfırlama talebinde bulunan kullanıcının e-posta adresi.
  Future<void> sendPasswordResetOtp(String email);

  /// Doğrulama koduyla birlikte kullanıcının şifresini yeni şifreyle günceller.
  /// [email]: Şifresi değişecek hesabın e-postası.
  /// [code]: E-postaya gelen doğrulama kodu.
  /// [newPassword]: Kullanıcının belirlediği yeni şifre.
  /// Şifre başarıyla güncellenirse 'true' döndürür.
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  /// Aktif kullanıcı oturumunu sonlandırır ve yerel hafızadaki oturum bilgilerini siler.
  Future<void> logout();
}
