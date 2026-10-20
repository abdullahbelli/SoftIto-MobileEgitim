import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rotiva/app.dart';
import 'package:rotiva/core/theme/theme_controller.dart';
import 'package:rotiva/data/repositories/app_repository.dart';
import 'package:rotiva/features/auth/view/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('RotivaApp açılış ve WelcomeScreen kontrolü', (
    WidgetTester tester,
  ) async {
    final themeController = ThemeController();
    await themeController.loadTheme();

    final repository = AppRepository();
    await repository.initialize();

    await tester.pumpWidget(
      RotivaApp(repository: repository, themeController: themeController),
    );
    await tester.pumpAndSettle();

    // WelcomeScreen üzerinde marka ve butonların varlığı
    expect(find.text('ROTIVA'), findsOneWidget);
    expect(find.text('Giriş Yap'), findsOneWidget);
    expect(find.text('Yeni Hesap Oluştur'), findsOneWidget);
    expect(find.text('Yönetici Girişi (Demo Panel)'), findsOneWidget);
  });

  testWidgets(
    'RegisterScreen: KVKK ve Açık Rıza onaylanmadan kayıt tamamlanamaz',
    (WidgetTester tester) async {
      final themeController = ThemeController();
      final repository = AppRepository();
      await repository.initialize();

      await tester.pumpWidget(
        RotivaApp(repository: repository, themeController: themeController),
      );
      await tester.pumpAndSettle();

      // Yeni Hesap Oluştur butonuna tıkla
      await tester.tap(find.text('Yeni Hesap Oluştur'));
      await tester.pumpAndSettle();

      // RegisterScreen açıldı
      expect(find.byType(RegisterScreen), findsOneWidget);

      // Kayıt Ol butonu başlangıçta onay kutuları işaretli olmadığı için disabled (onPressed null) olmalıdır
      final registerButtonFinder = find.widgetWithText(
        FilledButton,
        'Kayıt Ol ve Giriş Yap',
      );
      expect(registerButtonFinder, findsOneWidget);

      final FilledButton buttonWidget = tester.widget(registerButtonFinder);
      expect(buttonWidget.onPressed, isNull);

      // Checkbox'ları işaretle
      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsNWidgets(2));

      await tester.ensureVisible(checkboxes.first);
      await tester.pumpAndSettle();
      await tester.tap(checkboxes.first); // KVKK onayı
      await tester.pumpAndSettle();

      await tester.ensureVisible(checkboxes.last);
      await tester.pumpAndSettle();
      await tester.tap(checkboxes.last); // Açık Rıza onayı
      await tester.pumpAndSettle();

      // Şimdi buton aktifleşmiş olmalı
      final FilledButton buttonWidgetAfter = tester.widget(
        registerButtonFinder,
      );
      expect(buttonWidgetAfter.onPressed, isNotNull);
    },
  );

  testWidgets('Tema modu değiştirme testi', (WidgetTester tester) async {
    final themeController = ThemeController();
    expect(themeController.themeMode, ThemeMode.system);

    await themeController.setThemeMode(ThemeMode.dark);
    expect(themeController.themeMode, ThemeMode.dark);

    await themeController.toggleTheme();
    expect(themeController.themeMode, ThemeMode.light);
  });
}
