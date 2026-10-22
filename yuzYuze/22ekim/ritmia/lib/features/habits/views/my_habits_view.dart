import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/ritmia_logo.dart';
import '../controllers/habit_controller.dart';
import '../models/habit.dart';
import 'widgets/habit_card.dart';
import 'widgets/habit_form_sheet.dart';

/// Alışkanlıklarım Ekranı (My Habits View).
/// Kullanıcının aktif alışkanlıklarını, genel alev serisini ve
/// günlük ilerleme durumlarını listeler.
class MyHabitsView extends StatefulWidget {
  const MyHabitsView({super.key});

  @override
  State<MyHabitsView> createState() => _MyHabitsViewState();
}

class _MyHabitsViewState extends State<MyHabitsView> with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    // Boş durumda FAB için dikkat çeken zıplama animasyonu
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0.0, end: -12.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _openHabitForm([Habit? habitToEdit]) {
    final habitController = context.read<HabitController>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HabitFormSheet(
        habitToEdit: habitToEdit,
        onSave: (habit) {
          if (habitToEdit != null) {
            habitController.updateHabit(habit);
          } else {
            habitController.addHabit(habit);
          }
        },
        onDelete: (id) => habitController.deleteHabit(id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final habitController = context.watch<HabitController>();

    final activeHabits = habitController.activeHabits;
    final overallStreak = habitController.overallStreak;
    final isEmpty = activeHabits.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RitmiaLogo(size: 28),
            SizedBox(width: 8),
            Text(
              'Ritmia',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),
          ],
        ),
        actions: [
          // Sağda Genel Seri (Streak) Göstergesi
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.flameOrange.withValues(alpha: isDark ? 0.25 : 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.flameOrange.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.flameOrange,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '$overallStreak',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.flameOrange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: habitController.isLoading && activeHabits.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : isEmpty
              ? _buildEmptyState(isDark)
              : _buildHabitsList(activeHabits, habitController),
      floatingActionButton: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, isEmpty ? _bounceAnimation.value : 0),
            child: child,
          );
        },
        child: FloatingActionButton(
          onPressed: () => _openHabitForm(),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: const CircleBorder(),
          tooltip: 'Alışkanlık Ekle',
          child: const Icon(Icons.add_rounded, size: 28),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.track_changes_rounded,
                size: 54,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Henüz bir alışkanlık eklemediniz.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bugün ilk adımını atarak harika bir ritim başlat! Sağ alttaki + butonuna dokun.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.add_rounded),
              label: const Text('İlk Alışkanlığını Ekle'),
              onPressed: () => _openHabitForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitsList(List<Habit> activeHabits, HabitController habitController) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 84),
      itemCount: activeHabits.length,
      itemBuilder: (context, index) {
        final habit = activeHabits[index];
        final progress = habitController.getProgress(habit.id);
        final streak = habitController.getHabitStreak(habit);

        return HabitCard(
          key: ValueKey(habit.id),
          habit: habit,
          progress: progress,
          streak: streak,
          onToggle: () => habitController.toggleProgress(habit.id),
          onIncrement: () => habitController.incrementProgress(habit.id),
          onDecrement: () => habitController.decrementProgress(habit.id),
          onEdit: () => _openHabitForm(habit),
        );
      },
    );
  }
}
