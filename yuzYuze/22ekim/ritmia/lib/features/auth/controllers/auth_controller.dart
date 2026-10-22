import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';

/// Kimlik doğrulama ve kullanıcı oturum durumunu yöneten MVC Controller.
/// View katmanına oturum durumu, yüklenme ve hata bilgilerini ChangeNotifier ile iletir.
class AuthController extends ChangeNotifier {
  final AuthRepository _authRepository;

  UserProfile? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthController(this._authRepository);

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Uygulama açılışında kayıtlı yerel oturumu kontrol eder
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    try {
      _currentUser = await _authRepository.getCurrentUser();
    } catch (e) {
      _errorMessage = 'Oturum kontrolü sırasında hata: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Giriş işlemi
  Future<bool> login(String usernameOrEmail, String password) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _currentUser = await _authRepository.login(usernameOrEmail, password);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Giriş yapılamadı: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Kayıt işlemi
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _currentUser = await _authRepository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        username: username,
        password: password,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Kayıt başarısız: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Profil güncelleme
  Future<bool> updateProfile(UserProfile updated) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      _currentUser = await _authRepository.updateProfile(updated);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Profil güncellenemedi: $e';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Liderlik panosu katılım tercihini günceller
  Future<void> updateLeaderboardOptIn(bool optIn) async {
    if (_currentUser == null) return;
    final updated = _currentUser!.copyWith(leaderboardOptIn: optIn);
    await updateProfile(updated);
  }

  /// Çıkış yapma
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authRepository.logout();
      _currentUser = null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
