import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/competition/controller/competition_controller.dart';
import 'features/competition/view/competition_view.dart';
import 'features/water_tracker/controller/water_tracker_controller.dart';
import 'features/water_tracker/view/water_tracker_view.dart';
import 'features/workout/controller/workout_controller.dart';
import 'features/workout/view/workout_view.dart';

void main() {
  runApp(const SusadimApp());
}

class SusadimApp extends StatelessWidget {
  const SusadimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Susadım',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SusadimHomePage(),
    );
  }
}

class SusadimHomePage extends StatefulWidget {
  const SusadimHomePage({super.key});

  @override
  State<SusadimHomePage> createState() => _SusadimHomePageState();
}

class _SusadimHomePageState extends State<SusadimHomePage> {
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

  Widget _buildAppBarTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            'assets/images/logo.png',
            width: 30,
            height: 30,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        const Text('SUSADIM'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            tooltip: 'Sıfırla',
            onPressed: () => _waterController.resetToday(),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          WaterTrackerView(controller: _waterController),
          WorkoutView(controller: _workoutController),
          CompetitionView(controller: _competitionController),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop),
            label: 'Su Takibi',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Egzersiz',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Yarışma',
          ),
        ],
      ),
    );
  }
}
