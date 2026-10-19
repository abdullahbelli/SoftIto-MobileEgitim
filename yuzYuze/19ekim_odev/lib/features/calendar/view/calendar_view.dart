import 'package:flutter/material.dart';
import '../../../core/theme/theme_controller.dart';
import '../../diary/controllers/diary_controller.dart';
import '../../diary/view/diary_view.dart';
import '../controllers/calendar_controller.dart';
import '../models/calendar_model.dart';
import '../widgets/calendar_day_card.dart';

/// Kullanıcıyı karşılayan ana takvim ekranı.
class CalendarView extends StatefulWidget {
  final CalendarController calendarController;
  final DiaryController diaryController;
  final ThemeController themeController;

  const CalendarView({
    super.key,
    required this.calendarController,
    required this.diaryController,
    required this.themeController,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  @override
  void initState() {
    super.initState();
    widget.calendarController.refreshMarkedDates();
  }

  void _navigateToDiary(DateTime date) {
    widget.calendarController.selectDate(date);
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => DiaryView(
          selectedDate: date,
          controller: widget.diaryController,
          onDiarySaved: () => widget.calendarController.refreshMarkedDates(),
          onDiaryDeleted: () => widget.calendarController.refreshMarkedDates(),
        ),
      ),
    ).then((_) {
      // Geri dönüldüğünde takvim işaretlerini yenile
      widget.calendarController.refreshMarkedDates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/app_logo.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.auto_stories,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('Dijital Günlüğüm'),
          ],
        ),
        actions: [
          _ThemeToggleButton(themeController: widget.themeController),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _MonthNavigationHeader(
                  controller: widget.calendarController,
                ),
                const SizedBox(height: 12),
                const _WeekdayHeaders(),
                const SizedBox(height: 8),
                Expanded(
                  child: _CalendarGrid(
                    controller: widget.calendarController,
                    onDateTapped: _navigateToDiary,
                  ),
                ),
                _SelectedDateActionBar(
                  controller: widget.calendarController,
                  onOpenDiary: _navigateToDiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// AppBar üzerindeki açık/koyu tema geçiş butonu.
class _ThemeToggleButton extends StatelessWidget {
  final ThemeController themeController;

  const _ThemeToggleButton({required this.themeController});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController.themeMode,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        return IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode_outlined),
          tooltip: isDark ? 'Aydınlık Temaya Geç' : 'Karanlık Temaya Geç',
          onPressed: themeController.toggleTheme,
        );
      },
    );
  }
}

/// Ay değiştirme kontrollerini ve ay başlığını içeren bileşen.
class _MonthNavigationHeader extends StatelessWidget {
  final CalendarController controller;

  const _MonthNavigationHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: controller.focusedMonth,
      builder: (context, focusedMonth, _) {
        final title = CalendarHelper.formatMonthYear(focusedMonth);
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Önceki Ay',
                  onPressed: controller.previousMonth,
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Sonraki Ay',
                  onPressed: controller.nextMonth,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Haftanın günlerini (Pazartesi'den Pazar'a) gösteren başlık satırı.
class _WeekdayHeaders extends StatelessWidget {
  const _WeekdayHeaders();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: CalendarHelper.weekDayNamesShort.map((dayName) {
        return Expanded(
          child: Center(
            child: Text(
              dayName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Takvim günlerini 7 sütunlu ızgara biçiminde reaktif çizen bileşen.
class _CalendarGrid extends StatelessWidget {
  final CalendarController controller;
  final ValueChanged<DateTime> onDateTapped;

  const _CalendarGrid({
    required this.controller,
    required this.onDateTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        controller.focusedMonth,
        controller.selectedDate,
        controller.markedDates,
      ]),
      builder: (context, _) {
        final days = controller.getDaysGrid();
        return GridView.builder(
          physics: const ClampingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            childAspectRatio: 1.0,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            return CalendarDayCard(
              dayModel: day,
              onTap: () => onDateTapped(day.date),
            );
          },
        );
      },
    );
  }
}

/// Ekranın alt kısmında seçili günü ve günlüğe git butonunu gösteren çubuk.
class _SelectedDateActionBar extends StatelessWidget {
  final CalendarController controller;
  final ValueChanged<DateTime> onOpenDiary;

  const _SelectedDateActionBar({
    required this.controller,
    required this.onOpenDiary,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTime>(
      valueListenable: controller.selectedDate,
      builder: (context, selectedDate, _) {
        final dayStr =
            '${selectedDate.day} ${CalendarHelper.monthNames[selectedDate.month - 1]} ${selectedDate.year}';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => onOpenDiary(selectedDate),
              icon: const Icon(Icons.edit_note),
              label: Text('$dayStr Günlüğünü Aç'),
            ),
          ),
        );
      },
    );
  }
}
