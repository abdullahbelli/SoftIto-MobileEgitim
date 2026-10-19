import 'package:flutter/foundation.dart';
import '../../../core/services/diary_storage_service.dart';
import '../models/diary_model.dart';

/// Günlük iş mantığını ve durumunu yöneten controller.
/// Reaktif değişiklikleri `ValueNotifier` ile bildirir.
class DiaryController {
  final DiaryStorageService _storageService;

  final ValueNotifier<DiaryModel?> selectedDiary =
      ValueNotifier<DiaryModel?>(null);

  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);

  DiaryController({DiaryStorageService? storageService})
      : _storageService = storageService ?? DiaryStorageService();

  /// Belirtilen tarihe ait günlüğü yerel depolamadan yükler.
  Future<void> loadDiaryForDate(DateTime date) async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final diary = await _storageService.getDiary(date);
      selectedDiary.value = diary;
    } catch (e) {
      errorMessage.value = 'Günlük yüklenirken bir hata oluştu: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Yeni günlük kaydeder veya mevcut günlüğü günceller.
  /// Başlık ve içerik boş olamaz.
  Future<bool> saveOrUpdateDiary({
    required DateTime date,
    required String title,
    required String content,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedContent = content.trim();

    if (trimmedTitle.isEmpty || trimmedContent.isEmpty) {
      errorMessage.value = 'Başlık ve günlük içeriği boş bırakılamaz.';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final newDiary = DiaryModel(
        date: DateTime(date.year, date.month, date.day),
        title: trimmedTitle,
        content: trimmedContent,
      );

      await _storageService.saveDiary(newDiary);
      selectedDiary.value = newDiary;
      return true;
    } catch (e) {
      errorMessage.value = 'Günlük kaydedilemedi: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Seçili günlüğü depolamadan siler.
  Future<bool> deleteCurrentDiary() async {
    final current = selectedDiary.value;
    if (current == null) return false;

    isLoading.value = true;
    errorMessage.value = null;

    try {
      final success = await _storageService.deleteDiary(current.date);
      if (success) {
        selectedDiary.value = null;
      }
      return success;
    } catch (e) {
      errorMessage.value = 'Günlük silinirken hata oluştu: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Seçimi temizler.
  void clearSelection() {
    selectedDiary.value = null;
    errorMessage.value = null;
  }

  /// Dinleyicileri kapatır ve bellek temizliği yapar.
  void dispose() {
    selectedDiary.dispose();
    isLoading.dispose();
    errorMessage.dispose();
  }
}
