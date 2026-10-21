import 'dart:convert'; // Verileri JSON formatına dönüştürmek ve çözümlemek için kullanılır.

import 'package:shared_preferences/shared_preferences.dart'; // Yerel kalıcı veri saklama kütüphanesi.
import 'package:uuid/uuid.dart'; // Benzersiz rastgele kimlikler (UUID v4) üretmek için kullanılır.

import '../../../core/config/app_constants.dart'; // Sabit anahtar ve değerleri içe aktarır.
import '../../../core/errors/app_exception.dart'; // Özel hata sınıfını içe aktarır.
import '../domain/auth_repository.dart'; // Uygulanan soyut arayüzü içe aktarır.
import '../domain/user_model.dart'; // Kullanıcı veri modelini içe aktarır.

/// Supabase öncesi yerel ve kalıcı çalışan Mock Kimlik Doğrulama Servisi
/// 'implements AuthRepository' diyerek arayüzdeki tüm metotları yerel hafıza (SharedPreferences) kullanarak somutlaştırır.
class MockAuthRepository implements AuthRepository {
  final SharedPreferences _prefs; // Cihaz hafızasına erişim nesnesi.
  final _uuid = const Uuid(); // Rastgele benzersiz ID üreteci.

  // Kayıtlı kullanıcıların saklandığı SharedPreferences anahtar metni.
  static const String _usersStorageKey = 'bc_registered_users';

  // Kurucu fonksiyon: SharedPreferences nesnesini alır ve başlangıçta demo kullanıcıyı yükler.
  MockAuthRepository(this._prefs) {
    _initDefaultUser(); // İlk çalıştırmada varsayılan demo hesabı hazır eder.
  }

  // Hafızada hiç kullanıcı yoksa ilk açılış için örnek bir demo kullanıcı hesabı ekler.
  void _initDefaultUser() {
    final usersJson = _prefs.getString(
      _usersStorageKey,
    ); // Kayıtlı kullanıcılar tablosunu okur.
    if (usersJson == null) {
      // Örnek demo kullanıcı nesnesi.
      final defaultUser = UserModel(
        id: 'user_demo_1',
        email: 'demo@boardconnect.com',
        username: 'boardmaster',
        firstName: 'Ali',
        lastName: 'Demir',
        joinedAt: DateTime.now(),
      );
      // E-posta anahtarı altında kullanıcı bilgisi ve şifresini harita (Map) olarak yapılandırır.
      final usersMap = {
        defaultUser.email: {
          'user': defaultUser.toMap(),
          'password': 'Password123*', // Demo şifre.
        },
      };
      // JSON formatına dönüştürüp yerel belleğe yazar.
      _prefs.setString(_usersStorageKey, json.encode(usersMap));
    }
  }

  // Hafızadaki tüm kayıtlı kullanıcı haritasını JSON'dan çözüp getiren yardımcı metot.
  Map<String, dynamic> _getStoredUsers() {
    final usersJson = _prefs.getString(_usersStorageKey);
    if (usersJson == null) return {}; // Boşsa boş harita döner.
    return json.decode(usersJson)
        as Map<String, dynamic>; // JSON çözümleyip Map tipinde döndürür.
  }

  // Güncellenmiş kullanıcılar tablosunu JSON olarak yerel belleğe kaydeden yardımcı metot.
  Future<void> _saveStoredUsers(Map<String, dynamic> users) async {
    await _prefs.setString(_usersStorageKey, json.encode(users));
  }

  @override // AuthRepository arayüzündeki metodu ezer.
  // Cihazda aktif oturumu bulunan kullanıcıyı döndürür.
  Future<UserModel?> getCurrentUser() async {
    final userJson = _prefs.getString(
      AppConstants.prefsKeyCurrentUser,
    ); // Aktif oturum JSON verisi.
    if (userJson == null) return null; // Oturum yoksa null döner.
    try {
      return UserModel.fromJson(userJson); // JSON'u modele dönüştürüp döndürür.
    } catch (_) {
      return null; // Format bozuksa null döner.
    }
  }

  @override // E-posta ve şifre ile giriş kontrolü.
  Future<UserModel> login(String email, String password) async {
    // Gerçek bir ağ isteği hissi vermek için 400 milisaniye yapay gecikme simülasyonu uygular.
    await Future.delayed(const Duration(milliseconds: 400));
    final users = _getStoredUsers(); // Kayıtlı kullanıcıları getirir.
    final lowerEmail = email
        .trim()
        .toLowerCase(); // Küçük harfe çevirerek e-posta duyarlılığını kaldırır.

    // E-posta adresi kayıtlı değilse kullanıcıya hata fırlatır.
    if (!users.containsKey(lowerEmail)) {
      throw const AppException(
        'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı.',
      );
    }

    final userData =
        users[lowerEmail]
            as Map<String, dynamic>; // Kullanıcının verisini alır.
    // Şifre eşleşmiyorsa hata fırlatır.
    if (userData['password'] != password) {
      throw const AppException('Girdiğiniz şifre hatalı.');
    }

    // Kullanıcı nesnesini üretir.
    final user = UserModel.fromMap(userData['user'] as Map<String, dynamic>);
    // Aktif oturum olarak SharedPreferences'a kaydeder.
    await _prefs.setString(AppConstants.prefsKeyCurrentUser, user.toJson());
    return user; // Başarılı kullanıcı nesnesini döner.
  }

  @override // Yeni kullanıcı kayıt işlemi.
  Future<UserModel> register({
    required String email,
    required String password,
    required String username,
    required String firstName,
    required String lastName,
  }) async {
    await Future.delayed(
      const Duration(milliseconds: 400),
    ); // Ağ simülasyonu gecikmesi.
    final users = _getStoredUsers(); // Mevcut kullanıcıları çeker.
    final lowerEmail = email.trim().toLowerCase(); // E-postayı normalize eder.

    // E-posta zaten kayıtlıysa tekrar kayıt olmasına izin vermez.
    if (users.containsKey(lowerEmail)) {
      throw const AppException('Bu e-posta adresi zaten kullanımda.');
    }

    // Yeni kullanıcı nesnesini oluşturur.
    final newUser = UserModel(
      id: 'user_${_uuid.v4().substring(0, 8)}', // 8 karakterlik benzersiz ID üretir.
      email: lowerEmail,
      username: username.trim(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      joinedAt: DateTime.now(),
    );

    // Yeni kullanıcıyı ve şifresini havuza ekler.
    users[lowerEmail] = {'user': newUser.toMap(), 'password': password};

    await _saveStoredUsers(users); // Kullanıcı havuzunu kaydeder.
    // Yeni kullanıcıyı doğrudan oturum açmış olarak kaydeder.
    await _prefs.setString(AppConstants.prefsKeyCurrentUser, newUser.toJson());
    return newUser; // Oluşturulan kullanıcıyı döndürür.
  }

  @override // Odaya misafir olarak katılma işlemi.
  Future<UserModel> guestLogin({
    required String name,
    required String roomCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Ağ simülasyonu.
    // Geçici misafir profili oluşturur.
    final guestUser = UserModel(
      id: 'guest_${_uuid.v4().substring(0, 8)}',
      email: 'guest@boardconnect.local',
      username: name.trim().isEmpty ? 'Misafir' : name.trim(),
      firstName: name.trim(),
      lastName: '',
      isGuest: true, // Misafir bayrağını true yapar.
      joinedAt: DateTime.now(),
    );

    // Misafir oturumunu hafızaya yazar.
    await _prefs.setString(
      AppConstants.prefsKeyCurrentUser,
      guestUser.toJson(),
    );
    return guestUser;
  }

  @override // E-posta doğrulama OTP kodu gönderim simülasyonu.
  Future<void> sendVerificationOtp(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Demo simülasyonu: 6 haneli kod '123456' olarak belirlenmiştir; arka planda SMS/e-posta simüle edilir.
  }

  @override // 6 haneli OTP kodunun doğrulanması.
  Future<bool> verifyOtp(String email, String code) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // Kod 6 haneli değilse veya rakam dışında karakter içeriyorsa hata fırlatır.
    if (code.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(code)) {
      throw const AppException(
        'Kod 6 haneli ve yalnızca rakamlardan oluşmalıdır.',
      );
    }
    // Demo ortamında kurala uygun 6 haneli kod doğrulanmış kabul edilir.
    return true;
  }

  @override // Şifre sıfırlama OTP gönderim simülasyonu.
  Future<void> sendPasswordResetOtp(String email) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final users = _getStoredUsers();
    final lowerEmail = email.trim().toLowerCase();
    // Sıfırlanmak istenen e-posta sistemde kayıtlı değilse hata bildirir.
    if (!users.containsKey(lowerEmail)) {
      throw const AppException(
        'Bu e-posta adresiyle eşleşen hesap bulunamadı.',
      );
    }
  }

  @override // Yeni şifre ile kullanıcının şifresini güncelleme işlemi.
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final users = _getStoredUsers();
    final lowerEmail = email.trim().toLowerCase();

    // Kullanıcı kontrolü.
    if (!users.containsKey(lowerEmail)) {
      throw const AppException('Kullanıcı hesabı bulunamadı.');
    }

    // Kod formatı doğrulaması.
    if (code.length != 6 || !RegExp(r'^[0-9]+$').hasMatch(code)) {
      throw const AppException(
        'Kod 6 haneli ve yalnızca rakamlardan oluşmalıdır.',
      );
    }

    // Şifreyi günceller ve yerel hafızaya kaydeder.
    final userData = users[lowerEmail] as Map<String, dynamic>;
    userData['password'] = newPassword;
    users[lowerEmail] = userData;
    await _saveStoredUsers(users); // Yeni şifreli kullanıcı verisini kaydeder.
    return true;
  }

  @override // Oturumu kapatma metodu.
  Future<void> logout() async {
    // Aktif kullanıcı oturum bilgisini yerel hafızadan siler.
    await _prefs.remove(AppConstants.prefsKeyCurrentUser);
  }
}
