import 'package:flutter/foundation.dart';
import '../../../core/services/diary_storage_service.dart';
import '../../diary/models/diary_model.dart';
import '../models/calendar_model.dart';

/// Takvim mantığını, ay geçişlerini ve işaretli günleri yöneten controller.
class CalendarController {
  final DiaryStorageService _storageService;

  /// Gösterilen ay ve yıl
  final ValueNotifier<DateTime> focusedMonth;

  /// Seçili gün
  final ValueNotifier<DateTime> selectedDate;

  /// Günlük kaydı bulunan günlerin YYYY-MM-DD anahtarları
  final ValueNotifier<Set<String>> markedDates =
      ValueNotifier<Set<String>>(<String>{});

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  CalendarController({
    DateTime? initialDate,
    DiaryStorageService? storageService,
  })  : _storageService = storageService ?? DiaryStorageService(),
        focusedMonth = ValueNotifier<DateTime>(
          DateTime(
            initialDate?.year ?? DateTime.now().year,
            initialDate?.month ?? DateTime.now().month,
            1,
          ),
        ),
        selectedDate = ValueNotifier<DateTime>(
          DateTime(
            initialDate?.year ?? DateTime.now().year,
            initialDate?.month ?? DateTime.now().month,
            initialDate?.day ?? DateTime.now().day,
          ),
        );

  /// Günlük bulunan tarihlerin listesini depolamadan günceller.
  Future<void> refreshMarkedDates() async {
    isLoading.value = true;
    try {
      final keys = await _storageService.getMarkedDateKeys();
      markedDates.value = keys;
    } catch (_) {
      // Hata durumunda mevcut seti korur
    } finally {
      isLoading.value = false;
    }
  }

  /// Bir sonraki aya geçer. Yıl geçişini otomatik yönetir.
  void nextMonth() {
    final current = focusedMonth.value;
    if (current.month == 12) {
      focusedMonth.value = DateTime(current.year + 1, 1, 1);
    } else {
      focusedMonth.value = DateTime(current.year, current.month + 1, 1);
    }
  }

  /// Bir önceki aya geçer. Yıl geçişini otomatik yönetir.
  void previousMonth() {
    final current = focusedMonth.value;
    if (current.month == 1) {
      focusedMonth.value = DateTime(current.year - 1, 12, 1);
    } else {
      focusedMonth.value = DateTime(current.year, current.month - 1, 1);
    }
  }

  /// Takvimden bir gün seçer.
  void selectDate(DateTime date) {
    selectedDate.value = DateTime(date.year, date.month, date.day);
    // Seçilen gün farklı bir aydaysa, gösterilen ayı da seçilen güne taşır
    if (date.month != focusedMonth.value.month ||
        date.year != focusedMonth.value.year) {
      focusedMonth.value = DateTime(date.year, date.month, 1);
    }
  }

  /// Pazartesi başlangıçlı olacak şekilde mevcut ayın takvim grid hücrelerini üretir.
  List<CalendarDayModel> getDaysGrid() {
    final monthStart = focusedMonth.value;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = selectedDate.value;

    // Ayın ilk gününün haftanın hangi günü olduğu (1 = Pazartesi ... 7 = Pazar)
    final firstWeekday = monthStart.weekday;
    final leadDays = firstWeekday - 1;

    // Ayın kaç gün çektiği
    final daysInCurrentMonth =
        DateTime(monthStart.year, monthStart.month + 1, 0).day;

    final totalGridCells = ((leadDays + daysInCurrentMonth + 6) ~/ 7) * 7;
    final List<CalendarDayModel> cells = [];

    final startDate = monthStart.subtract(Duration(days: leadDays));

    for (int i = 0; i < totalGridCells; i++) {
      final cellDate = DateTime(
        startDate.year,
        startDate.month,
        startDate.day + i,
      );

      final isCurrentMonth = cellDate.month == monthStart.month;
      final isToday = CalendarHelper.isSameDay(cellDate, today);
      final isSelected = CalendarHelper.isSameDay(cellDate, selected);
      final dateKey = DiaryModel.formatDateKey(cellDate);
      final hasDiary = markedDates.value.contains(dateKey);

      cells.add(
        CalendarDayModel(
          date: cellDate,
          isCurrentMonth: isCurrentMonth,
          isToday: isToday,
          isSelected: isSelected,
          hasDiary: hasDiary,
        ),
      );
    }

    return cells;
  }

  /// Controller kaynaklarını temizler.
  void dispose() {
    focusedMonth.dispose();
    selectedDate.dispose();
    markedDates.dispose();
    isLoading.dispose();
  }
}
