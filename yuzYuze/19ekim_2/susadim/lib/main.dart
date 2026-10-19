import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/competition/controllers/competition_controller.dart';
import 'features/competition/view/competition_view.dart';
import 'features/water_tracker/controllers/water_tracker_controller.dart';
import 'features/water_tracker/view/water_tracker_view.dart';
import 'features/workout/controllers/workout_controller.dart';
import 'features/workout/view/workout_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController();
  runApp(SusadimApp(themeController: themeController));
}

/// Susadım v1 Ana Uygulama Kökü (Çift Tema & Reaktif Yapı)
class SusadimApp extends StatelessWidget {
  final ThemeController? themeController;

  const SusadimApp({super.key, this.themeController});

  @override
  Widget build(BuildContext context) {
    final controller = themeController ?? ThemeController();

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: controller.themeMode,
      builder: (context, currentThemeMode, _) {
        return MaterialApp(
          title: 'Susadım v1',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,
          home: MainNavigationShell(themeController: controller),
        );
      },
    );
  }
}

/// Yerel UI sekme durumunu yöneten ana kabuk
class MainNavigationShell extends StatefulWidget {
  final ThemeController themeController;

  const MainNavigationShell({
    super.key,
    required this.themeController,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  late final WaterTrackerController _waterController;
  late final WorkoutController _workoutController;
  late final CompetitionController _competitionController;

  @override
  void initState() {
    super.initState();
    _waterController = WaterTrackerController();
    _workoutController = WorkoutController();
    _competitionController = CompetitionController();
  }

  @override
  void dispose() {
    _waterController.dispose();
    _workoutController.dispose();
    _competitionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      WaterTrackerView(
        controller: _waterController,
        themeController: widget.themeController,
      ),
      WorkoutView(
        controller: _workoutController,
        themeController: widget.themeController,
      ),
      CompetitionView(
        controller: _competitionController,
        themeController: widget.themeController,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop_rounded),
            label: 'Su Takibi',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center_rounded),
            label: 'Egzersiz',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events_rounded),
            label: 'Yarışma',
          ),
        ],
      ),
    );
  }
}
