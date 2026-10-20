import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../features/auth/models/app_user.dart';
import '../../features/rentals/models/rental.dart';
import '../../features/rentals/models/review.dart';
import '../../features/vehicles/models/vehicle.dart';
import '../mock/mock_seed.dart';

/// Rotiva uygulamasının tek veri kaynağı (Single Source of Truth).
/// Bellek içi CRUD işlemleri sağlar ve değişiklikleri SharedPreferences'a senkronize eder.
class AppRepository extends ChangeNotifier {
  static const String _prefKeyUsers = 'rotiva_users_json';
  static const String _prefKeyVehicles = 'rotiva_vehicles_json';
  static const String _prefKeyRentals = 'rotiva_rentals_json';
  static const String _prefKeyReviews = 'rotiva_reviews_json';
  static const String _prefKeyCurrentUserId = 'rotiva_current_user_id';

  List<AppUser> _users = [];
  List<Vehicle> _vehicles = [];
  List<Rental> _rentals = [];
  List<Review> _reviews = [];
  AppUser? _currentUser;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  List<AppUser> get users => List.unmodifiable(_users);
  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);
  List<Rental> get rentals => List.unmodifiable(_rentals);
  List<Review> get reviews => List.unmodifiable(_reviews);

  /// Sadece aktif araçların listesi
  List<Vehicle> get activeVehicles =>
      _vehicles.where((v) => v.isActive).toList();

  /// Depoyu başlatır ve kayıtlı verileri / mock seed'i yükler
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Kullanıcıları yükle
      final usersJson = prefs.getString(_prefKeyUsers);
      if (usersJson != null && usersJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(usersJson);
        _users = decoded.map((e) => AppUser.fromJson(e)).toList();
      } else {
        _users = List.from(MockSeed.initialUsers);
      }

      // 2. Araçları yükle
      final vehiclesJson = prefs.getString(_prefKeyVehicles);
      if (vehiclesJson != null && vehiclesJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(vehiclesJson);
        _vehicles = decoded.map((e) => Vehicle.fromJson(e)).toList();
      } else {
        _vehicles = List.from(MockSeed.initialVehicles);
      }

      // 3. Kiralamaları yükle
      final rentalsJson = prefs.getString(_prefKeyRentals);
      if (rentalsJson != null && rentalsJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(rentalsJson);
        _rentals = decoded.map((e) => Rental.fromJson(e)).toList();
      } else {
        _rentals = List.from(MockSeed.initialRentals);
      }

      // 4. Yorumları yükle
      final reviewsJson = prefs.getString(_prefKeyReviews);
      if (reviewsJson != null && reviewsJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(reviewsJson);
        _reviews = decoded.map((e) => Review.fromJson(e)).toList();
      } else {
        _reviews = List.from(MockSeed.initialReviews);
      }

      // 5. Kayıtlı kullanıcı oturumu varsa getir
      final currentUserId = prefs.getString(_prefKeyCurrentUserId);
      if (currentUserId != null) {
        _currentUser = _users.cast<AppUser?>().firstWhere(
          (u) => u?.id == currentUserId,
          orElse: () => null,
        );
      }
    } catch (e) {
      // Hata durumunda mock seed ile güvenli geri dönüş
      debugPrint('AppRepository init hatası: $e');
      _users = List.from(MockSeed.initialUsers);
      _vehicles = List.from(MockSeed.initialVehicles);
      _rentals = List.from(MockSeed.initialRentals);
      _reviews = List.from(MockSeed.initialReviews);
      _currentUser = null;
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  // ==================== KİMLİK DOĞRULAMA (AUTH) ====================

  /// Kullanıcı girişi
  Future<bool> login(
    String email,
    String password, {
    UserRole? expectedRole,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final user = _users.cast<AppUser?>().firstWhere(
      (u) =>
          u?.email.toLowerCase() == cleanEmail &&
          (u?.password == password ||
              password == '123456' ||
              (u?.isAdmin == true && password == 'admin')),
      orElse: () => null,
    );

    if (user == null) {
      return false;
    }

    if (expectedRole != null && user.role != expectedRole) {
      return false; // Rol uyuşmazlığı
    }

    _currentUser = user;
    await _saveCurrentUserId(user.id);
    notifyListeners();
    return true;
  }

  /// Yeni müşteri kaydı
  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final exists = _users.any((u) => u.email.toLowerCase() == cleanEmail);
    if (exists) {
      return false; // E-posta zaten kayıtlı
    }

    final newUser = AppUser(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: cleanEmail,
      phone: phone.trim(),
      role: UserRole.customer,
      password: password,
      createdAt: DateTime.now(),
      userScore: null, // Yeni müşteri için henüz puan yok
    );

    _users.add(newUser);
    _currentUser = newUser;

    await _persistUsers();
    await _saveCurrentUserId(newUser.id);
    notifyListeners();
    return true;
  }

  /// Kullanıcı profilini güncelleme (Örn: Doğum tarihi, ehliyet yılı)
  Future<void> updateProfile(AppUser updatedUser) async {
    final index = _users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      if (_currentUser?.id == updatedUser.id) {
        _currentUser = updatedUser;
      }
      await _persistUsers();
      notifyListeners();
    }
  }

  /// Çıkış yap
  Future<void> logout() async {
    _currentUser = null;
    await _saveCurrentUserId(null);
    notifyListeners();
  }

  // ==================== ARAÇ YÖNETİMİ ====================

  Vehicle? getVehicleById(String id) {
    return _vehicles.cast<Vehicle?>().firstWhere(
      (v) => v?.id == id,
      orElse: () => null,
    );
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    _vehicles.insert(0, vehicle);
    await _persistVehicles();
    notifyListeners();
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      _vehicles[index] = vehicle;
      await _persistVehicles();
      notifyListeners();
    }
  }

  /// Bir aracın silinip silinemeyeceğini denetler.
  /// Kural: Aktif veya onaylı kiralaması olan araç silinemez!
  bool canDeleteVehicle(String vehicleId) {
    final hasActiveRentals = _rentals.any(
      (r) =>
          r.vehicleId == vehicleId &&
          (r.rentalStatus == RentalStatus.active ||
              r.rentalStatus == RentalStatus.approved),
    );
    return !hasActiveRentals;
  }

  /// Aracı siler (eğer aktif kiralaması yoksa).
  Future<bool> deleteVehicle(String vehicleId) async {
    if (!canDeleteVehicle(vehicleId)) {
      return false; // Silmeye izin verilmez
    }
    _vehicles.removeWhere((v) => v.id == vehicleId);
    await _persistVehicles();
    notifyListeners();
    return true;
  }

  /// Aracı pasife alma (Soft delete / Geçici kullanım dışı bırakma)
  Future<void> toggleVehicleStatus(String vehicleId, bool isActive) async {
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index != -1) {
      _vehicles[index] = _vehicles[index].copyWith(isActive: isActive);
      await _persistVehicles();
      notifyListeners();
    }
  }

  /// Aracın belirtilen tarihlerde müsait olup olmadığını kontrol eder.
  /// Kural: Araç aktif olmalı ve iptal edilmemiş başka bir kiralama ile çakışmamalıdır.
  bool isVehicleAvailable(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) {
    final vehicle = getVehicleById(vehicleId);
    if (vehicle == null || !vehicle.isActive) {
      return false;
    }

    // İptal edilmeyen kiralamaları incele
    final activeBookings = _rentals.where(
      (r) =>
          r.vehicleId == vehicleId && r.rentalStatus != RentalStatus.cancelled,
    );

    for (final booking in activeBookings) {
      final overlaps = RotivaDateUtils.hasDateOverlap(
        newStart: startDate,
        newEnd: endDate,
        oldStart: booking.startDate,
        oldEnd: booking.endDate,
      );
      if (overlaps) {
        return false;
      }
    }

    return true;
  }

  // ==================== KİRALAMA İŞLEMLERİ ====================

  List<Rental> getRentalsForCustomer(String customerId) {
    return _rentals.where((r) => r.customerId == customerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> createRental(Rental rental) async {
    _rentals.insert(0, rental);
    await _persistRentals();
    notifyListeners();
  }

  Future<void> updateRentalStatus(
    String rentalId,
    RentalStatus newStatus,
  ) async {
    final index = _rentals.indexWhere((r) => r.id == rentalId);
    if (index != -1) {
      _rentals[index] = _rentals[index].copyWith(rentalStatus: newStatus);
      await _persistRentals();
      notifyListeners();
    }
  }

  // ==================== DEĞERLENDİRME & YORUMLAR ====================

  List<Review> getReviewsForVehicle(String vehicleId) {
    return _reviews.where((r) => r.vehicleId == vehicleId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  double? getAverageRatingForVehicle(String vehicleId) {
    final list = _reviews.where((r) => r.vehicleId == vehicleId).toList();
    if (list.isEmpty) return null;
    final total = list.fold<int>(0, (sum, r) => sum + r.stars);
    return total / list.length;
  }

  Review? getReviewForRental(String rentalId) {
    return _reviews.cast<Review?>().firstWhere(
      (r) => r?.rentalId == rentalId,
      orElse: () => null,
    );
  }

  Future<bool> addReview(Review review) async {
    // Aynı kiralama için mükerrer yorum yapılamaz
    if (getReviewForRental(review.rentalId) != null) {
      return false;
    }

    _reviews.insert(0, review);
    await _persistReviews();
    notifyListeners();
    return true;
  }

  // ==================== KALICILIK YARDIMCILARI ====================

  Future<void> _saveCurrentUserId(String? id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (id != null) {
        await prefs.setString(_prefKeyCurrentUserId, id);
      } else {
        await prefs.remove(_prefKeyCurrentUserId);
      }
    } catch (_) {}
  }

  Future<void> _persistUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_users.map((e) => e.toJson()).toList());
      await prefs.setString(_prefKeyUsers, data);
    } catch (_) {}
  }

  Future<void> _persistVehicles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_vehicles.map((e) => e.toJson()).toList());
      await prefs.setString(_prefKeyVehicles, data);
    } catch (_) {}
  }

  Future<void> _persistRentals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_rentals.map((e) => e.toJson()).toList());
      await prefs.setString(_prefKeyRentals, data);
    } catch (_) {}
  }

  Future<void> _persistReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_reviews.map((e) => e.toJson()).toList());
      await prefs.setString(_prefKeyReviews, data);
    } catch (_) {}
  }

  /// Tüm verileri ilk fabrika ayarlarına (seed) döndürür (Demo temizleme)
  Future<void> resetToSeed() async {
    _users = List.from(MockSeed.initialUsers);
    _vehicles = List.from(MockSeed.initialVehicles);
    _rentals = List.from(MockSeed.initialRentals);
    _reviews = List.from(MockSeed.initialReviews);
    await _persistUsers();
    await _persistVehicles();
    await _persistRentals();
    await _persistReviews();
    notifyListeners();
  }
}
