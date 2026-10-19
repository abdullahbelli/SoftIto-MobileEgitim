import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dijital_gunlugum/core/services/diary_storage_service.dart';
import 'package:dijital_gunlugum/core/theme/theme_controller.dart';
import 'package:dijital_gunlugum/features/calendar/controllers/calendar_controller.dart';
import 'package:dijital_gunlugum/features/diary/controllers/diary_controller.dart';
import 'package:dijital_gunlugum/main.dart';

void main() {
  testWidgets('Dijital Günlüğüm temel widget ve etkileşim testi',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final storageService = DiaryStorageService(prefs);
    final themeController = ThemeController(prefs);
    final calendarController = CalendarController(
      initialDate: DateTime(2026, 10, 20),
      storageService: storageService,
    );
    final diaryController = DiaryController(storageService: storageService);

    await tester.pumpWidget(
      DijitalGunlugumApp(
        themeController: themeController,
        calendarController: calendarController,
        diaryController: diaryController,
      ),
    );
    await tester.pumpAndSettle();

    // 1. Ana başlığın render edildiğini doğrula
    expect(find.text('Dijital Günlüğüm'), findsOneWidget);

    // 2. Türkçe ay başlığının render edildiğini doğrula ("Ekim 2026")
    expect(find.text('Ekim 2026'), findsOneWidget);

    // 3. Tema butonunun varlığını doğrula ve tıkla
    final themeToggleFinder = find.byType(IconButton).first;
    expect(themeToggleFinder, findsWidgets);
    await tester.tap(find.byTooltip('Karanlık Temaya Geç'));
    await tester.pumpAndSettle();
    expect(themeController.themeMode.value, ThemeMode.dark);

    // 4. Günlüğe git butonunun varlığını doğrula ve tıkla
    final openDiaryButtonFinder = find.byType(ElevatedButton);
    expect(openDiaryButtonFinder, findsOneWidget);
    await tester.tap(openDiaryButtonFinder);
    await tester.pumpAndSettle();

    // 5. Günlük ekranının açıldığını ve boş mesajı gösterdiğini doğrula
    expect(
      find.text('Bu güne ait henüz bir günlük yazılmamış.'),
      findsOneWidget,
    );

    // 6. Geri dön
    final backButton = find.byType(BackButton);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton);
      await tester.pumpAndSettle();
    }
  });
}
