import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../habits/controllers/habit_controller.dart';
import '../controllers/calendar_controller.dart';
import 'widgets/day_detail_sheet.dart';

/// Alışkanlık Takvimi Ekranı (Calendar View).
/// Günlük tamamlanma oranına göre ısı haritası renklendirmesi (%100 koyu yeşil,
/// %0 kırmızı), ay gezinmesi, alışkanlık filtreleme ve gün detay raporu sunar.
class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  void _showDayDetail(
    BuildContext context,
    DateTime date,
    CalendarController calendarCtrl,
    HabitController habitCtrl,
  ) {
    final report = calendarCtrl.calendarService.getDayReport(
      date: date,
      habits: habitCtrl.habits,
      progressMap: habitCtrl.progressMap,
      habitIdFilter: calendarCtrl.selectedHabitFilter,
    );

    final targetHabits = calendarCtrl.selectedHabitFilter != null
        ? habitCtrl.habits.where((h) => h.id == calendarCtrl.selectedHabitFilter).toList()
        : habitCtrl.habits;

    final plannedForDay = targetHabits.where((h) => h.isScheduledOn(date)).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DayDetailSheet(
        date: date,
        report: report,
        plannedHabits: plannedForDay,
        progressMap: habitCtrl.progressMap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final calendarCtrl = context.watch<CalendarController>();
    final habitCtrl = context.watch<HabitController>();

    final selectedMonth = calendarCtrl.selectedMonth;
    final daysInGrid = calendarCtrl.calendarService.generateMonthDays(selectedMonth);
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alışkanlık Takvimi'),
        actions: [
          TextButton(
            onPressed: () => calendarCtrl.goToToday(),
            child: const Text('Bugün'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Alışkanlık Filtre Seçimi
            if (habitCtrl.activeHabits.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String?>(
                    value: calendarCtrl.selectedHabitFilter,
                    isExpanded: true,
                    hint: const Text('Görünüm: Tüm Alışkanlıklar'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('Tüm Alışkanlıklar (Genel Görünüm)'),
                      ),
                      ...habitCtrl.activeHabits.map(
                        (h) => DropdownMenuItem<String?>(
                          value: h.id,
                          child: Text(h.name),
                        ),
                      ),
                    ],
                    onChanged: (val) => calendarCtrl.setHabitFilter(val),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Ay Gezinme Çubuğu (< Ekim 2026 >)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filledTonal(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () => calendarCtrl.previousMonth(),
                ),
                Text(
                  AppDateUtils.formatMonthYear(selectedMonth),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton.filledTonal(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () => calendarCtrl.nextMonth(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Haftanın Gün Başlıkları (Pzt, Sal, ...)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final dayNum = i + 1;
                final name = AppConstants.weekdayShortNames[dayNum] ?? '';
                return SizedBox(
                  width: 38,
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),

            // Takvim Hücreleri Matrisi
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: daysInGrid.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final date = daysInGrid[index];
                if (date == null) {
                  return const SizedBox.shrink();
                }

                final isToday = AppDateUtils.isSameDay(date, today);
                final isFuture = date.isAfter(DateTime(today.year, today.month, today.day));

                final report = calendarCtrl.calendarService.getDayReport(
                  date: date,
                  habits: habitCtrl.habits,
                  progressMap: habitCtrl.progressMap,
                  habitIdFilter: calendarCtrl.selectedHabitFilter,
                );

                final bgColor = calendarCtrl.calendarService.getHeatMapColor(
                  report: report,
                  isFuture: isFuture,
                  isDark: isDark,
                );

                final isDarkBackground = report.isPlannedDay &&
                    !isFuture &&
                    (report.completionRatio >= 0.67 || report.completionRatio == 0.0);

                return InkWell(
                  onTap: () => _showDayDetail(context, date, calendarCtrl, habitCtrl),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isToday
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        width: isToday ? 2.0 : 0.0,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                            color: isDarkBackground
                                ? Colors.white
                                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          ),
                        ),
                        if (report.isPlannedDay && !isFuture) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${report.completedCount}/${report.totalPlanned}',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isDarkBackground ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Isı Haritası Açıklaması (Legend)
            _buildLegend(isDark),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Renk Göstergeleri',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _legendItem(AppColors.heatMap100, '%100 Tamam'),
              _legendItem(AppColors.heatMap75, '%67-99'),
              _legendItem(AppColors.heatMap50, '%34-66'),
              _legendItem(AppColors.heatMap25, '%1-33'),
              _legendItem(AppColors.heatMap0, '%0 Eksik'),
              _legendItem(
                isDark ? AppColors.heatMapNeutralDark : AppColors.heatMapNeutralLight,
                'Plan Yok / Gelecek',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
