import 'package:flutter_test/flutter_test.dart';
import 'package:rotiva/core/constants/app_constants.dart';
import 'package:rotiva/data/repositories/app_repository.dart';
import 'package:rotiva/features/rentals/models/review.dart';
import 'package:rotiva/features/vehicles/models/vehicle.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppRepository Veri ve İş Kuralları Testleri', () {
    test('Repository ilk açılışta Mock Seed verileriyle yüklenir', () async {
      final repository = AppRepository();
      await repository.initialize();

      expect(repository.isInitialized, true);
      expect(repository.vehicles.length, greaterThanOrEqualTo(10));
      expect(repository.users.length, greaterThanOrEqualTo(5));
      expect(repository.rentals.isNotEmpty, true);
    });

    test(
      'Aktif veya onaylı kiralaması olan araç silinemez (Madde 101)',
      () async {
        final repository = AppRepository();
        await repository.initialize();

        // Seed içinde aktif veya onaylı kiralaması olan aracı bul (Örn: veh_03 veya veh_04)
        final activeRental = repository.rentals.firstWhere(
          (r) =>
              r.rentalStatus == RentalStatus.active ||
              r.rentalStatus == RentalStatus.approved,
        );

        final canDelete = repository.canDeleteVehicle(activeRental.vehicleId);
        expect(canDelete, false);

        // Silme çağrısı da false döndürmeli ve araç listede kalmalı
        final deleted = await repository.deleteVehicle(activeRental.vehicleId);
        expect(deleted, false);
        expect(repository.getVehicleById(activeRental.vehicleId), isNotNull);
      },
    );

    test('Yeni araç ekleme, düzenleme ve pasife alma çalışır', () async {
      final repository = AppRepository();
      await repository.initialize();

      const newCar = Vehicle(
        id: 'veh_test_crud',
        brand: 'TestBrand',
        model: 'TestModel',
        year: 2025,
        category: VehicleCategory.suv,
        fuelType: FuelType.electric,
        transmission: TransmissionType.automatic,
        city: 'İzmir',
        district: 'Karşıyaka',
        imagePath: '',
        hourlyRate: 150,
        dailyRate: 1800,
        minimumAge: 22,
        minimumLicenseYears: 2,
        dailyKmLimit: 350,
        additionalDailyKm: 150,
        additionalKmDailyPrice: 250,
        addressDeliveryFee: 400,
        isActive: true,
      );

      // Ekleme
      await repository.addVehicle(newCar);
      expect(repository.getVehicleById('veh_test_crud'), isNotNull);

      // Düzenleme
      final updated = newCar.copyWith(dailyRate: 2000);
      await repository.updateVehicle(updated);
      expect(repository.getVehicleById('veh_test_crud')?.dailyRate, 2000);

      // Pasife alma
      await repository.toggleVehicleStatus('veh_test_crud', false);
      expect(repository.getVehicleById('veh_test_crud')?.isActive, false);

      // Silme (Aktif kiralaması olmadığı için silinebilir)
      final deleted = await repository.deleteVehicle('veh_test_crud');
      expect(deleted, true);
      expect(repository.getVehicleById('veh_test_crud'), isNull);
    });

    test(
      'Senaryo 6: Aynı kiralama için ikinci değerlendirme oluşturulamaz',
      () async {
        final repository = AppRepository();
        await repository.initialize();

        final completedRental = repository.rentals.firstWhere(
          (r) => r.rentalStatus == RentalStatus.completed,
        );

        final rev1 = Review(
          id: 'rev_test_1',
          rentalId: completedRental.id,
          vehicleId: completedRental.vehicleId,
          customerId: completedRental.customerId,
          customerName: completedRental.customerName,
          stars: 5,
          comment: 'İlk yorum',
          createdAt: DateTime.now(),
        );

        // Seed içinde zaten rev_01 varsa ikinci aynı rentalId ile addReview false döner
        final existingReview = repository.getReviewForRental(
          completedRental.id,
        );
        if (existingReview != null) {
          final addedSecond = await repository.addReview(rev1);
          expect(addedSecond, false);
        }
      },
    );

    test('Kullanıcı kayıt ve e-posta mükerrerlik engeli', () async {
      final repository = AppRepository();
      await repository.initialize();

      // Zaten var olan ahmet@rotiva.com ile kayıt başarısız olmalı
      final failResult = await repository.register(
        fullName: 'Ahmet Çakma',
        email: 'ahmet@rotiva.com',
        phone: '0532 999 88 77',
        password: 'password',
      );
      expect(failResult, false);

      // Yeni benzersiz e-posta ile kayıt başarılı olmalı
      final successResult = await repository.register(
        fullName: 'Yeni Kullanıcı',
        email: 'yeni.kullanici@rotiva.com',
        phone: '0532 999 88 77',
        password: 'password123',
      );
      expect(successResult, true);
      expect(repository.currentUser?.email, 'yeni.kullanici@rotiva.com');
    });
  });
}
