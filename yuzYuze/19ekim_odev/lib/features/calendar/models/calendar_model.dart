import 'package:flutter/foundation.dart';

/// Takvimdeki tek bir gün hücresinin durumunu temsil eden model.
@immutable
class CalendarDayModel {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final bool hasDiary;

  const CalendarDayModel({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
    required this.hasDiary,
  });

  CalendarDayModel copyWith({
    DateTime? date,
    bool? isCurrentMonth,
    bool? isToday,
    bool? isSelected,
    bool? hasDiary,
  }) {
    return CalendarDayModel(
      date: date ?? this.date,
      isCurrentMonth: isCurrentMonth ?? this.isCurrentMonth,
      isToday: isToday ?? this.isToday,
      isSelected: isSelected ?? this.isSelected,
      hasDiary: hasDiary ?? this.hasDiary,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalendarDayModel &&
        other.date.year == date.year &&
        other.date.month == date.month &&
        other.date.day == date.day &&
        other.isCurrentMonth == isCurrentMonth &&
        other.isToday == isToday &&
        other.isSelected == isSelected &&
        other.hasDiary == hasDiary;
  }

  @override
  int get hashCode => Object.hash(
        date.year,
        date.month,
        date.day,
        isCurrentMonth,
        isToday,
        isSelected,
        hasDiary,
      );
}

/// Türkçe takvim hesaplamaları ve isimleri için yardımcı sınıf.
abstract final class CalendarHelper {
  static const List<String> monthNames = [
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  /// Haftanın günleri (Pazartesi başlangıçlı: DateTime.monday = 1 ... DateTime.sunday = 7)
  static const List<String> weekDayNamesShort = [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  /// Verilen tarihin ay ve yılını Türkçe olarak formatlar (Örn: "Ekim 2026")
  static String formatMonthYear(DateTime date) {
    final monthName = monthNames[date.month - 1];
    return '$monthName ${date.year}';
  }

  /// İki tarihin gün, ay ve yıl olarak aynı olup olmadığını kontrol eder.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
