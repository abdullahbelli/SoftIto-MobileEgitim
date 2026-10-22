import 'package:flutter/foundation.dart';
import '../services/calendar_service.dart';

/// Takvim ekranının durumunu yöneten MVC Controller.
/// Seçili ay, seçili gün ve alışkanlık filtrelerini koordine eder.
class CalendarController extends ChangeNotifier {
  final CalendarService _calendarService;

  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDay;
  String? _selectedHabitFilter;

  CalendarController(this._calendarService);

  DateTime get selectedMonth => _selectedMonth;
  DateTime? get selectedDay => _selectedDay;
  String? get selectedHabitFilter => _selectedHabitFilter;
  CalendarService get calendarService => _calendarService;

  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    notifyListeners();
  }

  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    notifyListeners();
  }

  void goToToday() {
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);
    notifyListeners();
  }

  void selectDay(DateTime? day) {
    _selectedDay = day;
    notifyListeners();
  }

  void setHabitFilter(String? habitId) {
    _selectedHabitFilter = habitId;
    notifyListeners();
  }
}
