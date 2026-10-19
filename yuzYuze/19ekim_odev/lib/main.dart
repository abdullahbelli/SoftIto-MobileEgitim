import 'package:flutter/material.dart';
import 'core/services/diary_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/calendar/controllers/calendar_controller.dart';
import 'features/calendar/view/calendar_view.dart';
import 'features/diary/controllers/diary_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Servis ve Kontrolcülerin Başlatılması
  final storageService = DiaryStorageService();
  final themeController = ThemeController();
  await themeController.init();

  final calendarController = CalendarController(storageService: storageService);
  final diaryController = DiaryController(storageService: storageService);

  runApp(
    DijitalGunlugumApp(
      themeController: themeController,
      calendarController: calendarController,
      diaryController: diaryController,
    ),
  );
}

/// Uygulamanın ana MaterialApp kabuğu.
class DijitalGunlugumApp extends StatelessWidget {
  final ThemeController themeController;
  final CalendarController calendarController;
  final DiaryController diaryController;

  const DijitalGunlugumApp({
    super.key,
    required this.themeController,
    required this.calendarController,
    required this.diaryController,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController.themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Dijital Günlüğüm',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: CalendarView(
            calendarController: calendarController,
            diaryController: diaryController,
            themeController: themeController,
          ),
        );
      },
    );
  }
}
