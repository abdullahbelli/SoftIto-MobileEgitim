import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/ritmia_logo.dart';
import '../controllers/habit_controller.dart';
import '../models/habit.dart';
import '../services/motivation_service.dart';
import 'widgets/habit_card.dart';
import 'widgets/habit_detail_sheet.dart';
import 'widgets/habit_form_sheet.dart';

/// Alışkanlıklarım Ekranı (My Habits View).
/// Kullanıcının aktif alışkanlıklarını, genel alev serisini,
/// Hugging Face'ten dinamik çekilen motivasyon kartını ve
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

  void _openHabitDetail(Habit habit) {
    final habitController = context.read<HabitController>();
    final progress = habitController.getProgress(habit.id);
    final streak = habitController.getHabitStreak(habit);

    HabitDetailSheet.show(
      context,
      habit: habit,
      progress: progress,
      streak: streak,
      onToggle: () => habitController.toggleProgress(habit.id),
      onEdit: () => _openHabitForm(habit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final habitController = context.watch<HabitController>();
    final motivationService = context.watch<MotivationService>();

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
          // Eğer motivasyon kartı gizlendiyse tekrar açma ikonu
          if (!motivationService.isBannerVisible)
            IconButton(
              icon: Icon(
                Icons.auto_awesome_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              tooltip: 'Günün Motivasyonunu Göster',
              onPressed: () => motivationService.setBannerVisible(true),
            ),

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
              ? _buildEmptyState(context, theme, isDark, motivationService)
              : _buildHabitsList(activeHabits, habitController, motivationService, theme, isDark),
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

  /// Hugging Face Motivasyon Kartı
  Widget _buildHuggingFaceMotivationCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    MotivationService motivationService,
  ) {
    if (!motivationService.isBannerVisible) {
      return const SizedBox.shrink();
    }

    final quote = motivationService.currentQuote;
    if (quote == null && !motivationService.isLoading) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: isDark ? 0.22 : 0.10),
            theme.colorScheme.primaryContainer.withValues(alpha: isDark ? 0.15 : 0.20),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.35 : 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Satır: Hugging Face Rozeti ve Butonlar (Yenileme + Gizleme)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.3 : 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🤗', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      'Hugging Face Motivasyonu',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: motivationService.isLoading
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : Icon(
                            Icons.refresh_rounded,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                    tooltip: 'Hugging Face\'ten Yeni Söz Al',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: motivationService.isLoading
                        ? null
                        : () => motivationService.fetchQuote(force: true),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    tooltip: 'Motivasyonu Gizle',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    onPressed: () => motivationService.setBannerVisible(false),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Alıntı Metni
          if (quote != null) ...[
            Text(
              '“${quote.text}”',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.45,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            if (quote.originalText != null && quote.originalText != quote.text) ...[
              const SizedBox(height: 4),
              Text(
                '“${quote.originalText}”',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '— ${quote.author}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (quote.tag != null)
                  Text(
                    '#${quote.tag}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
              ],
            ),
          ] else
            const Text('Hugging Face\'ten ilham verici söz yükleniyor...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    MotivationService motivationService,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          if (motivationService.isBannerVisible)
            _buildHuggingFaceMotivationCard(context, theme, isDark, motivationService),
          const SizedBox(height: 32),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.track_changes_rounded,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
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
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('İlk Alışkanlığını Ekle'),
                    onPressed: () => _openHabitForm(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList(
    List<Habit> activeHabits,
    HabitController habitController,
    MotivationService motivationService,
    ThemeData theme,
    bool isDark,
  ) {
    final showBanner = motivationService.isBannerVisible;
    final bannerOffset = showBanner ? 1 : 0;

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 84),
      itemCount: activeHabits.length + bannerOffset,
      itemBuilder: (context, index) {
        if (showBanner && index == 0) {
          return _buildHuggingFaceMotivationCard(context, theme, isDark, motivationService);
        }

        final habit = activeHabits[index - bannerOffset];
        final progress = habitController.getProgress(habit.id);
        final streak = habitController.getHabitStreak(habit);

        return HabitCard(
          key: ValueKey(habit.id),
          habit: habit,
          progress: progress,
          streak: streak,
          onTap: () => _openHabitDetail(habit),
          onToggle: () => habitController.toggleProgress(habit.id),
          onIncrement: () => habitController.incrementProgress(habit.id),
          onDecrement: () => habitController.decrementProgress(habit.id),
          onEdit: () => _openHabitForm(habit),
        );
      },
    );
  }
}
