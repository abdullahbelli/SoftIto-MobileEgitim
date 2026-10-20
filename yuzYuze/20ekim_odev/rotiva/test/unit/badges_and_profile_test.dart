import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotiva/core/constants/app_constants.dart';
import 'package:rotiva/core/constants/vehicle_badge_colors.dart';
import 'package:rotiva/core/theme/theme_controller.dart';
import 'package:rotiva/core/widgets/fuel_type_badge.dart';
import 'package:rotiva/core/widgets/rotiva_app_bar.dart';
import 'package:rotiva/core/widgets/rotiva_scope.dart';
import 'package:rotiva/core/widgets/vehicle_type_badge.dart';
import 'package:rotiva/data/repositories/app_repository.dart';
import 'package:rotiva/features/profile/view/profile_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Yakıt Türü ve Araç Tipi Renk Eşleştirmeleri (Madde 5)', () {
    test('Yakıt türleri renk kurallarına uymalıdır', () {
      // Benzin: Turuncu
      expect(
        VehicleBadgeColors.getFuelColor(FuelType.gasoline),
        VehicleBadgeColors.gasolineColor,
      );
      // Dizel: Mavi
      expect(
        VehicleBadgeColors.getFuelColor(FuelType.diesel),
        VehicleBadgeColors.dieselColor,
      );
      // Hibrit: Mor
      expect(
        VehicleBadgeColors.getFuelColor(FuelType.hybrid),
        VehicleBadgeColors.hybridColor,
      );
      // Elektrik: Yeşil
      expect(
        VehicleBadgeColors.getFuelColor(FuelType.electric),
        VehicleBadgeColors.electricColor,
      );
    });

    test('Araç tipleri renk kurallarına uymalıdır', () {
      // Sedan: Mavi
      expect(
        VehicleBadgeColors.getCategoryColor(VehicleCategory.sedan),
        VehicleBadgeColors.sedanColor,
      );
      // SUV: Mor
      expect(
        VehicleBadgeColors.getCategoryColor(VehicleCategory.suv),
        VehicleBadgeColors.suvColor,
      );
      // Hatchback: Turkuaz
      expect(
        VehicleBadgeColors.getCategoryColor(VehicleCategory.hatchback),
        VehicleBadgeColors.hatchbackColor,
      );
      // Coupe / Spor: Kırmızı
      expect(
        VehicleBadgeColors.getCategoryColor(VehicleCategory.coupe),
        VehicleBadgeColors.coupeColor,
      );
      // Ticari / Van: Kahverengi
      expect(
        VehicleBadgeColors.getCategoryColor(VehicleCategory.commercial),
        VehicleBadgeColors.commercialColor,
      );
      // Lüks: Amber / Altın
      expect(
        VehicleBadgeColors.getCategoryColor(VehicleCategory.luxury),
        VehicleBadgeColors.luxuryColor,
      );
    });
  });

  group('Rozet Bileşenleri (Badge Widgets)', () {
    testWidgets('FuelTypeBadge benzin için doğru metin ve ikonu göstermeli', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FuelTypeBadge(fuelType: FuelType.gasoline)),
        ),
      );

      expect(find.text('Benzin'), findsOneWidget);
      expect(find.byIcon(Icons.local_gas_station), findsOneWidget);
    });

    testWidgets('VehicleTypeBadge sedan için doğru metin ve ikonu göstermeli', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VehicleTypeBadge(category: VehicleCategory.sedan),
          ),
        ),
      );

      expect(find.text('Sedan'), findsOneWidget);
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
    });
  });

  group('Ortak RotivaAppBar Testleri', () {
    testWidgets('RotivaAppBar başlık, logo ve tema butonunu göstermeli', (
      tester,
    ) async {
      final repository = AppRepository();
      await repository.initialize();
      final themeController = ThemeController();
      await themeController.loadTheme();

      await tester.pumpWidget(
        RotivaScope(
          repository: repository,
          themeController: themeController,
          child: const MaterialApp(
            home: Scaffold(
              appBar: RotivaAppBar(titleText: 'Profil'),
              body: SizedBox(),
            ),
          ),
        ),
      );

      expect(find.text('Rotiva'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
    });
  });

  group('Profil Ekranı ve Kullanıcı Güncelleme Testleri (Madde 2 & 3)', () {
    testWidgets('ProfileTabView kullanıcı bilgileri ve çıkış aksiyonu', (
      tester,
    ) async {
      final repository = AppRepository();
      await repository.initialize();
      final themeController = ThemeController();
      await themeController.loadTheme();

      // Demo müşteri ile oturum aç
      await repository.login('ahmet@rotiva.com', '123456');

      await tester.pumpWidget(
        RotivaScope(
          repository: repository,
          themeController: themeController,
          child: const MaterialApp(home: ProfileTabView()),
        ),
      );
      await tester.pumpAndSettle();

      // Baş harf avatarı (Ahmet Yılmaz -> AY)
      expect(find.text('AY'), findsOneWidget);
      expect(find.text('Ahmet Yılmaz'), findsOneWidget);
      expect(find.text('ahmet@rotiva.com'), findsOneWidget);
      expect(find.text('Müşteri'), findsOneWidget);

      // Kiralama özet kutusu
      expect(find.text('Kiralama Bilgilerim'), findsOneWidget);
      expect(find.textContaining('Müşteri Skoru'), findsOneWidget);

      // Çıkış Yap butonu
      expect(find.text('Çıkış Yap'), findsWidgets);
    });

    test('Kullanıcı profil güncellemesi verileri korur ve günceller', () async {
      final repository = AppRepository();
      await repository.initialize();

      await repository.login('ahmet@rotiva.com', '123456');
      final user = repository.currentUser!;

      final updatedUser = user.copyWith(
        fullName: 'Ahmet Güncel',
        phone: '05559998877',
      );

      await repository.updateProfile(updatedUser);

      expect(repository.currentUser?.fullName, 'Ahmet Güncel');
      expect(repository.currentUser?.phone, '05559998877');
    });
  });
}
