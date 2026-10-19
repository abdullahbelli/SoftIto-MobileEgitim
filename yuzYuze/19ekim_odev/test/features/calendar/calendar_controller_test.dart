import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dijital_gunlugum/core/services/diary_storage_service.dart';
import 'package:dijital_gunlugum/features/calendar/controllers/calendar_controller.dart';
import 'package:dijital_gunlugum/features/diary/models/diary_model.dart';

void main() {
  group('CalendarController Tests', () {
    late DiaryStorageService storageService;
    late CalendarController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storageService = DiaryStorageService(prefs);
      controller = CalendarController(
        initialDate: DateTime(2026, 10, 15),
        storageService: storageService,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('Ay geçişleri sonraki ve önceki aylara doğru ilerlemeli', () {
      expect(controller.focusedMonth.value.month, 10);
      expect(controller.focusedMonth.value.year, 2026);

      // Sonraki ay: Kasım 2026
      controller.nextMonth();
      expect(controller.focusedMonth.value.month, 11);
      expect(controller.focusedMonth.value.year, 2026);

      // Sonraki ay: Aralık 2026
      controller.nextMonth();
      expect(controller.focusedMonth.value.month, 12);
      expect(controller.focusedMonth.value.year, 2026);

      // Sonraki ay: Ocak 2027 (Yıl geçişi)
      controller.nextMonth();
      expect(controller.focusedMonth.value.month, 1);
      expect(controller.focusedMonth.value.year, 2027);

      // Önceki ay: Aralık 2026 (Yıl geriye dönüş)
      controller.previousMonth();
      expect(controller.focusedMonth.value.month, 12);
      expect(controller.focusedMonth.value.year, 2026);
    });

    test('Tarih seçimi seçili tarihi ve gerekiyorsa odaklanan ayı güncellemeli', () {
      controller.selectDate(DateTime(2026, 10, 25));
      expect(controller.selectedDate.value.day, 25);
      expect(controller.focusedMonth.value.month, 10);

      // Farklı bir ay seçildiğinde odaklanan ay da o aya geçmeli
      controller.selectDate(DateTime(2026, 11, 5));
      expect(controller.selectedDate.value.month, 11);
      expect(controller.focusedMonth.value.month, 11);
    });

    test('Günlük kaydedildiğinde takvim gridinde hasDiary doğru işaretlenmeli', () async {
      final diaryDate = DateTime(2026, 10, 20);
      await storageService.saveDiary(
        DiaryModel(
          date: diaryDate,
          title: 'İşaretli Gün',
          content: 'Nokta kontrolü',
        ),
      );

      await controller.refreshMarkedDates();
      expect(controller.markedDates.value.contains('2026-10-20'), isTrue);

      final grid = controller.getDaysGrid();
      final day20 = grid.firstWhere(
        (day) =>
            day.date.year == 2026 &&
            day.date.month == 10 &&
            day.date.day == 20,
      );

      expect(day20.hasDiary, isTrue);
    });

    test('Takvim matrisi her zaman 7 nin tam katı hücre üretmeli', () {
      final grid = controller.getDaysGrid();
      expect(grid.length % 7, 0);
    });
  });
}
