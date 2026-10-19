import 'package:flutter_test/flutter_test.dart';
import 'package:dijital_gunlugum/features/diary/models/diary_model.dart';

void main() {
  group('DiaryModel Tests', () {
    final testDate = DateTime(2026, 10, 20);

    test('Model nesnesi doğru alanlarla oluşturulabilmeli', () {
      final diary = DiaryModel(
        date: testDate,
        title: 'Harika Bir Gün',
        content: 'Bugün çok güzel şeyler öğrendim.',
      );

      expect(diary.date, testDate);
      expect(diary.title, 'Harika Bir Gün');
      expect(diary.content, 'Bugün çok güzel şeyler öğrendim.');
      expect(diary.dateKey, '2026-10-20');
    });

    test('copyWith metodu istenen alanları güncellemeli', () {
      final diary = DiaryModel(
        date: testDate,
        title: 'Eski Başlık',
        content: 'Eski İçerik',
      );

      final updated = diary.copyWith(
        title: 'Yeni Başlık',
        content: 'Yeni İçerik',
      );

      expect(updated.date, testDate);
      expect(updated.title, 'Yeni Başlık');
      expect(updated.content, 'Yeni İçerik');
    });

    test('toJson ve fromJson dönüşümleri veri kaybetmeden çalışmalı', () {
      final original = DiaryModel(
        date: testDate,
        title: 'JSON Testi',
        content: 'Serileştirme ve deserileştirme kontrolü.',
      );

      final jsonMap = original.toJson();
      final fromJsonDiary = DiaryModel.fromJson(jsonMap);

      expect(fromJsonDiary.date.year, original.date.year);
      expect(fromJsonDiary.date.month, original.date.month);
      expect(fromJsonDiary.date.day, original.date.day);
      expect(fromJsonDiary.title, original.title);
      expect(fromJsonDiary.content, original.content);
      expect(fromJsonDiary.dateKey, original.dateKey);
    });

    test('formatDateKey ve parseDateKey birbirini doğrulamalı', () {
      final date = DateTime(2026, 5, 9);
      final key = DiaryModel.formatDateKey(date);
      expect(key, '2026-05-09');

      final parsed = DiaryModel.parseDateKey(key);
      expect(parsed.year, 2026);
      expect(parsed.month, 5);
      expect(parsed.day, 9);
    });
  });
}
