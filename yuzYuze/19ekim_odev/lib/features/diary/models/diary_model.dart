import 'package:flutter/foundation.dart';

/// Günlük kaydını temsil eden immutable veri modeli.
/// Aynı tarihe ait yalnızca tek bir günlük bulunabilir.
@immutable
class DiaryModel {
  final DateTime date;
  final String title;
  final String content;

  const DiaryModel({
    required this.date,
    required this.title,
    required this.content,
  });

  /// Tarih saatini sıfırlayarak sadece YYYY-MM-DD biçiminde normalize eden anahtar.
  String get dateKey => formatDateKey(date);

  /// Verilen DateTime nesnesini 'YYYY-MM-DD' anahtar stringine dönüştürür.
  static String formatDateKey(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// 'YYYY-MM-DD' anahtar stringini DateTime nesnesine dönüştürür.
  static DateTime parseDateKey(String key) {
    final parts = key.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    return DateTime(year, month, day);
  }

  /// Modelin güncellenmiş yeni bir kopyasını üretir.
  DiaryModel copyWith({
    DateTime? date,
    String? title,
    String? content,
  }) {
    return DiaryModel(
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  /// JSON verisinden DiaryModel nesnesi oluşturur.
  factory DiaryModel.fromJson(Map<String, dynamic> json) {
    return DiaryModel(
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );
  }

  /// DiaryModel nesnesini JSON haritasına dönüştürür.
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'title': title,
      'content': content,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DiaryModel &&
        other.dateKey == dateKey &&
        other.title == title &&
        other.content == content;
  }

  @override
  int get hashCode => Object.hash(dateKey, title, content);
}
