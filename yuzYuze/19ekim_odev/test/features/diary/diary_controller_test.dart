import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dijital_gunlugum/core/services/diary_storage_service.dart';
import 'package:dijital_gunlugum/features/diary/controllers/diary_controller.dart';

void main() {
  group('DiaryController Tests', () {
    late DiaryStorageService storageService;
    late DiaryController controller;
    final testDate = DateTime(2026, 10, 20);

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storageService = DiaryStorageService(prefs);
      controller = DiaryController(storageService: storageService);
    });

    tearDown(() {
      controller.dispose();
    });

    test('Boş başlık veya içerik ile kayıt oluşturulması engellenmeli', () async {
      final successEmptyTitle = await controller.saveOrUpdateDiary(
        date: testDate,
        title: '   ',
        content: 'Geçerli içerik',
      );

      expect(successEmptyTitle, isFalse);
      expect(controller.errorMessage.value, isNotNull);

      final successEmptyContent = await controller.saveOrUpdateDiary(
        date: testDate,
        title: 'Geçerli Başlık',
        content: '   ',
      );

      expect(successEmptyContent, isFalse);
      expect(controller.errorMessage.value, isNotNull);
    });

    test('Günlük başarıyla kaydedilmeli ve yüklenebilmeli', () async {
      final saved = await controller.saveOrUpdateDiary(
        date: testDate,
        title: 'İlk Günlük',
        content: 'Test içeriği burada.',
      );

      expect(saved, isTrue);
      expect(controller.selectedDiary.value, isNotNull);
      expect(controller.selectedDiary.value?.title, 'İlk Günlük');

      // Başka bir controller örneği ile depolamadan yüklemeyi doğrula
      final newController = DiaryController(storageService: storageService);
      await newController.loadDiaryForDate(testDate);
      expect(newController.selectedDiary.value?.title, 'İlk Günlük');
      expect(newController.selectedDiary.value?.content, 'Test içeriği burada.');
      newController.dispose();
    });

    test('Mevcut günlük güncellenebilmeli', () async {
      await controller.saveOrUpdateDiary(
        date: testDate,
        title: 'Eski Başlık',
        content: 'Eski İçerik',
      );

      final updated = await controller.saveOrUpdateDiary(
        date: testDate,
        title: 'Güncellenmiş Başlık',
        content: 'Güncellenmiş İçerik',
      );

      expect(updated, isTrue);
      expect(controller.selectedDiary.value?.title, 'Güncellenmiş Başlık');
      expect(controller.selectedDiary.value?.content, 'Güncellenmiş İçerik');
    });

    test('Günlük silinebilmeli ve seçili durum null olmalı', () async {
      await controller.saveOrUpdateDiary(
        date: testDate,
        title: 'Silinecek Günlük',
        content: 'Silinecek içerik',
      );

      final deleted = await controller.deleteCurrentDiary();
      expect(deleted, isTrue);
      expect(controller.selectedDiary.value, isNull);

      // Depolamada da silindiğini doğrula
      final loaded = await storageService.getDiary(testDate);
      expect(loaded, isNull);
    });
  });
}
