import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/theme/theme_controller.dart';
import 'core/services/storage_service.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/repositories/local_auth_repository.dart';
import 'features/calendar/controllers/calendar_controller.dart';
import 'features/calendar/services/calendar_service.dart';
import 'features/habits/controllers/habit_controller.dart';
import 'features/habits/repositories/local_habit_repository.dart';
import 'features/habits/services/habit_streak_service.dart';
import 'features/leaderboard/controllers/leaderboard_controller.dart';
import 'features/leaderboard/repositories/demo_leaderboard_repository.dart';
import 'features/leaderboard/services/leaderboard_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Yerel Depolama (SharedPreferences) Başlatma
  final prefs = await SharedPreferences.getInstance();
  final storageService = StorageService(prefs);

  // 2. Servis Katmanı (Saf hesaplama ve iş kuralları)
  final habitStreakService = HabitStreakService();
  final calendarService = CalendarService(habitStreakService);
  final leaderboardService = LeaderboardService();

  // 3. Veri Katmanı (Repository - Yerel & Demo simülasyonları)
  final authRepository = LocalAuthRepository(storageService);
  final habitRepository = LocalHabitRepository(storageService);
  final leaderboardRepository = DemoLeaderboardRepository(leaderboardService);

  // 4. Durum Yönetimi / Controller Katmanı (MVC + ChangeNotifier)
  final themeController = ThemeController(storageService);
  final authController = AuthController(authRepository);
  await authController.checkAuthStatus();

  final habitController = HabitController(habitRepository, habitStreakService);
  await habitController.loadHabits();

  final calendarController = CalendarController(calendarService);
  final leaderboardController = LeaderboardController(leaderboardRepository, leaderboardService);

  // 5. Uygulama Kökü (MultiProvider ile bağımlılık enjeksiyonu)
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeController),
        ChangeNotifierProvider.value(value: authController),
        ChangeNotifierProvider.value(value: habitController),
        ChangeNotifierProvider.value(value: calendarController),
        ChangeNotifierProvider.value(value: leaderboardController),
      ],
      child: const RitmiaApp(),
    ),
  );
}
