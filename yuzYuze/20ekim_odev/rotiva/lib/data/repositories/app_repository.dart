// JSON serileştirme ve deserileştirme işlemleri için dart:convert kütüphanesini içeri aktarıyoruz.
import 'dart:convert';

// ChangeNotifier ve hata ayıklama fonksiyonları için Flutter foundation kütüphanesini içeri aktarıyoruz.
import 'package:flutter/foundation.dart';
// Yerel veri kalıcılığı (Local Persistence) için SharedPreferences paketini içeri aktarıyoruz.
import 'package:shared_preferences/shared_preferences.dart';

// Sabitler, tarih araçları ve modellerimizi içeri aktarıyoruz.
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../features/auth/models/app_user.dart';
import '../../features/rentals/models/rental.dart';
import '../../features/rentals/models/review.dart';
import '../../features/vehicles/models/vehicle.dart';
import '../mock/mock_seed.dart';

/// Rotiva uygulamasının tek veri kaynağı (Single Source of Truth).
/// ChangeNotifier sınıfından türetilmiştir; veri değiştiğinde notifyListeners() çağrılarak dinleyiciler uyarılır.
/// Bellek içi CRUD işlemleri sağlar ve değişiklikleri SharedPreferences'a otomatik senkronize eder.
class AppRepository extends ChangeNotifier {
  // SharedPreferences içerisinde verileri JSON dizisi olarak saklamak için benzersiz anahtarlar tanımlıyoruz.
  static const String _prefKeyUsers = 'rotiva_users_json';
  static const String _prefKeyVehicles = 'rotiva_vehicles_json';
  static const String _prefKeyRentals = 'rotiva_rentals_json';
  static const String _prefKeyReviews = 'rotiva_reviews_json';
  static const String _prefKeyCurrentUserId = 'rotiva_current_user_id';

  // Bellekte tutulan özel (private) veri listeleri
  List<AppUser> _users = []; // Kullanıcı listesi
  List<Vehicle> _vehicles = []; // Araç listesi
  List<Rental> _rentals = []; // Kiralama listesi
  List<Review> _reviews = []; // Yorum ve değerlendirme listesi
  AppUser?
  _currentUser; // Giriş yapmış olan mevcut kullanıcı (oturum yoksa null)
  bool _isInitialized =
      false; // Veri deposunun diskten başarıyla yüklenip yüklenmediği bayrağı

  // Dışarıya veri sunan getter erişimcileri (Encapsulation gereği)
  bool get isInitialized => _isInitialized; // Başlatma durumu
  AppUser? get currentUser => _currentUser; // Aktif kullanıcı
  bool get isAuthenticated => _currentUser != null; // Giriş yapılmış mı?
  bool get isAdmin =>
      _currentUser?.isAdmin ?? false; // Aktif kullanıcı yönetici mi?

  // Dışarıdan listelerin doğrudan değiştirilmesini engellemek için List.unmodifiable ile sarıyoruz.
  List<AppUser> get users => List.unmodifiable(_users);
  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);
  List<Rental> get rentals => List.unmodifiable(_rentals);
  List<Review> get reviews => List.unmodifiable(_reviews);

  /// Sadece aktif (kiralamaya açık) durumdaki araçları döndüren getter
  List<Vehicle> get activeVehicles =>
      _vehicles.where((v) => v.isActive).toList();

  /// Depoyu başlatır ve SharedPreferences'taki kayıtlı verileri veya mock seed verilerini yükler.
  Future<void> initialize() async {
    // Eğer depo daha önce başlatıldıysa mükerrer yüklemeyi önlüyoruz.
    if (_isInitialized) return;

    try {
      // SharedPreferences örneğini alıyoruz.
      final prefs = await SharedPreferences.getInstance();

      // 1. Kullanıcıları diskten oku; yoksa MockSeed verilerini kullan
      final usersJson = prefs.getString(_prefKeyUsers);
      if (usersJson != null && usersJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(usersJson);
        _users = decoded.map((e) => AppUser.fromJson(e)).toList();
      } else {
        _users = List.from(MockSeed.initialUsers);
      }

      // 2. Araçları diskten oku; yoksa MockSeed verilerini kullan
      final vehiclesJson = prefs.getString(_prefKeyVehicles);
      if (vehiclesJson != null && vehiclesJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(vehiclesJson);
        _vehicles = decoded.map((e) => Vehicle.fromJson(e)).toList();
      } else {
        _vehicles = List.from(MockSeed.initialVehicles);
      }

      // 3. Kiralamaları diskten oku; yoksa MockSeed verilerini kullan
      final rentalsJson = prefs.getString(_prefKeyRentals);
      if (rentalsJson != null && rentalsJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(rentalsJson);
        _rentals = decoded.map((e) => Rental.fromJson(e)).toList();
      } else {
        _rentals = List.from(MockSeed.initialRentals);
      }

      // 4. Yorumları diskten oku; yoksa MockSeed verilerini kullan
      final reviewsJson = prefs.getString(_prefKeyReviews);
      if (reviewsJson != null && reviewsJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(reviewsJson);
        _reviews = decoded.map((e) => Review.fromJson(e)).toList();
      } else {
        _reviews = List.from(MockSeed.initialReviews);
      }

      // 5. Kayıtlı kullanıcı oturumu varsa kullanıcıyı bul ve aktif yap
      final currentUserId = prefs.getString(_prefKeyCurrentUserId);
      if (currentUserId != null) {
        _currentUser = _users.cast<AppUser?>().firstWhere(
          (u) => u?.id == currentUserId,
          orElse: () => null,
        );
      }
    } catch (e) {
      // Herhangi bir JSON parse hatasında güvenli bir şekilde mock seed'e geri dönüyoruz.
      debugPrint('AppRepository init hatası: $e');
      _users = List.from(MockSeed.initialUsers);
      _vehicles = List.from(MockSeed.initialVehicles);
      _rentals = List.from(MockSeed.initialRentals);
      _reviews = List.from(MockSeed.initialReviews);
      _currentUser = null;
    } finally {
      // İşlem tamamlandı bayrağını true yapıyoruz ve arayüzü haberdar ediyoruz.
      _isInitialized = true;
      notifyListeners();
    }
  }

  // ==================== KİMLİK DOĞRULAMA (AUTH) ====================

  /// Kullanıcı girişi gerçekleştirir. Rol eşleşmesi ve şifre doğrulaması yapar.
  Future<bool> login(
    String email,
    String password, {
    UserRole? expectedRole,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    // Kullanıcı listesinde e-posta ve şifre kontrolü yapıyoruz (Demo kolaylığı için 123456 desteklenir).
    final user = _users.cast<AppUser?>().firstWhere(
      (u) =>
          u?.email.toLowerCase() == cleanEmail &&
          (u?.password == password ||
              password == '123456' ||
              (u?.isAdmin == true && password == 'admin')),
      orElse: () => null,
    );

    // E-posta veya şifre yanlışsa false dönüyoruz.
    if (user == null) {
      return false;
    }

    // Beklenen rol (müşteri ekranından yönetici girişi yapılmaya çalışılıyorsa vb.) kontrolü
    if (expectedRole != null && user.role != expectedRole) {
      return false; // Rol uyuşmazlığı nedeniyle giriş engellenir.
    }

    _currentUser = user; // Aktif kullanıcı olarak atıyoruz.
    await _saveCurrentUserId(user.id); // Oturumu diske kaydediyoruz.
    notifyListeners(); // Dinleyen arayüz bileşenlerini güncelliyoruz.
    return true;
  }

  /// Yeni müşteri kaydı oluşturur.
  Future<bool> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    // E-posta adresinin daha önce alınıp alınmadığını kontrol ediyoruz.
    final exists = _users.any((u) => u.email.toLowerCase() == cleanEmail);
    if (exists) {
      return false; // E-posta zaten kayıtlı olduğu için kayıt başarısız.
    }

    // Yeni AppUser nesnesini oluşturuyoruz.
    final newUser = AppUser(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: cleanEmail,
      phone: phone.trim(),
      role: UserRole.customer,
      password: password,
      createdAt: DateTime.now(),
      userScore: null, // Yeni müşteri için henüz puan atanmadı.
    );

    _users.add(newUser); // Listeye ekliyoruz.
    _currentUser = newUser; // Oturumu anında açıyoruz.

    await _persistUsers(); // Kullanıcıları diske yazıyoruz.
    await _saveCurrentUserId(newUser.id); // Aktif oturumu kaydediyoruz.
    notifyListeners(); // Ekranı haberdar ediyoruz.
    return true;
  }

  /// Kullanıcı profilini (ad, soyad, telefon, doğum tarihi, ehliyet vb.) günceller.
  Future<void> updateProfile(AppUser updatedUser) async {
    final index = _users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      if (_currentUser?.id == updatedUser.id) {
        _currentUser = updatedUser;
      }
      await _persistUsers(); // Diske kaydediyoruz.
      notifyListeners(); // Arayüze haber veriyoruz.
    }
  }

  /// Aktif kullanıcı oturumunu kapatır.
  Future<void> logout() async {
    _currentUser = null;
    await _saveCurrentUserId(
      null,
    ); // Diskteki kullanıcı oturum bilgisini temizliyoruz.
    notifyListeners();
  }

  // ==================== ARAÇ YÖNETİMİ ====================

  /// ID değerine göre araç bulur.
  Vehicle? getVehicleById(String id) {
    return _vehicles.cast<Vehicle?>().firstWhere(
      (v) => v?.id == id,
      orElse: () => null,
    );
  }

  /// Filoya yeni araç ekler ve listenin en başına yerleştirir.
  Future<void> addVehicle(Vehicle vehicle) async {
    _vehicles.insert(0, vehicle);
    await _persistVehicles();
    notifyListeners();
  }

  /// Mevcut bir aracın bilgilerini günceller.
  Future<void> updateVehicle(Vehicle vehicle) async {
    final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
    if (index != -1) {
      _vehicles[index] = vehicle;
      await _persistVehicles();
      notifyListeners();
    }
  }

  /// Bir aracın silinip silinemeyeceğini denetler.
  /// Kural (PROJECT.md Madde 101): Aktif veya onaylı kiralaması olan araç silinemez!
  bool canDeleteVehicle(String vehicleId) {
    final hasActiveRentals = _rentals.any(
      (r) =>
          r.vehicleId == vehicleId &&
          (r.rentalStatus == RentalStatus.active ||
              r.rentalStatus == RentalStatus.approved),
    );
    return !hasActiveRentals;
  }

  /// Aracı filodan kalıcı olarak siler (eğer aktif kiralaması yoksa).
  Future<bool> deleteVehicle(String vehicleId) async {
    if (!canDeleteVehicle(vehicleId)) {
      return false; // Aktif kiralaması olduğu için silme engellendi.
    }
    _vehicles.removeWhere((v) => v.id == vehicleId);
    await _persistVehicles();
    notifyListeners();
    return true;
  }

  /// Aracı pasife / aktife alır (Soft delete mantığı).
  Future<void> toggleVehicleStatus(String vehicleId, bool isActive) async {
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index != -1) {
      _vehicles[index] = _vehicles[index].copyWith(isActive: isActive);
      await _persistVehicles();
      notifyListeners();
    }
  }

  /// Aracın belirtilen tarihlerde müsait olup olmadığını kontrol eder.
  /// Kural: Araç aktif olmalı ve iptal edilmemiş başka bir kiralama ile tarih çakışması olmamalıdır.
  bool isVehicleAvailable(
    String vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) {
    final vehicle = getVehicleById(vehicleId);
    if (vehicle == null || !vehicle.isActive) {
      return false;
    }

    // İptal edilmeyen mevcut rezervasyonları kontrol ediyoruz.
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
        return false; // Tarihler çakıştığı için araç müsait değil.
      }
    }

    return true; // Araç belirtilen tarihlerde tamamen müsait.
  }

  // ==================== KİRALAMA İŞLEMLERİ ====================

  /// Belirli bir müşteriye ait tüm kiralama geçmişini en yeniden en eskiye sıralı getirir.
  List<Rental> getRentalsForCustomer(String customerId) {
    return _rentals.where((r) => r.customerId == customerId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Yeni kiralama rezervasyonu oluşturur ve listenin başına ekler.
  Future<void> createRental(Rental rental) async {
    _rentals.insert(0, rental);
    await _persistRentals();
    notifyListeners();
  }

  /// Bir kiralamanın durumunu (Onaylandı, Aktif, Tamamlandı, İptal vb.) günceller.
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

  /// Bir araca yapılmış tüm değerlendirme ve yorumları getirir.
  List<Review> getReviewsForVehicle(String vehicleId) {
    return _reviews.where((r) => r.vehicleId == vehicleId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Bir aracın ortalama yıldız puanını (1.0 - 5.0) hesaplar.
  double? getAverageRatingForVehicle(String vehicleId) {
    final list = _reviews.where((r) => r.vehicleId == vehicleId).toList();
    if (list.isEmpty) return null;
    final total = list.fold<int>(0, (sum, r) => sum + r.stars);
    return total / list.length;
  }

  /// Belirli bir kiralama işlemine ait yazılmış yorumu getirir.
  Review? getReviewForRental(String rentalId) {
    return _reviews.cast<Review?>().firstWhere(
      (r) => r?.rentalId == rentalId,
      orElse: () => null,
    );
  }

  /// Tamamlanan kiralama için araca yeni yorum ekler. Mükerrer yorumu engeller.
  Future<bool> addReview(Review review) async {
    // Aynı kiralama için daha önce yorum yapılmışsa engelliyoruz.
    if (getReviewForRental(review.rentalId) != null) {
      return false;
    }

    _reviews.insert(0, review);
    await _persistReviews();
    notifyListeners();
    return true;
  }

  // ==================== KALICILIK YARDIMCILARI ====================

  /// Giriş yapan kullanıcının ID'sini SharedPreferences'a yazar veya oturum kapandıysa siler.
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

  /// Kullanıcı listesini JSON formatına çevirip diske kalıcı olarak kaydeder.
  Future<void> _persistUsers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_users.map((e) => e.toJson()).toList());
      await prefs.setString(_prefKeyUsers, data);
    } catch (_) {}
  }

  /// Araç listesini JSON formatına çevirip diske kalıcı olarak kaydeder.
  Future<void> _persistVehicles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_vehicles.map((e) => e.toJson()).toList());
      await prefs.setString(_prefKeyVehicles, data);
    } catch (_) {}
  }

  /// Kiralama listesini JSON formatına çevirip diske kalıcı olarak kaydeder.
  Future<void> _persistRentals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_rentals.map((e) => e.toJson()).toList());
      await prefs.setString(_prefKeyRentals, data);
    } catch (_) {}
  }

  /// Yorum ve değerlendirme listesini JSON formatına çevirip diske kalıcı olarak kaydeder.
  Future<void> _persistReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_reviews.map((e) => e.toJson()).toList());
      await prefs.setString(_prefKeyReviews, data);
    } catch (_) {}
  }

  /// Tüm verileri ilk başlangıç mock tohum verilerine (seed) geri döndürür (Fabrika Ayarlarına Sıfırla).
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
