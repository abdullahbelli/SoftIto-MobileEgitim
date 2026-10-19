// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

// ============================================================================
// 1. MODEL KATMANI (Immutable Data Model)
// ============================================================================
// Model katmanı yalnızca veriyi ve verinin taşınma kurallarını barındırır.
// Tüm alanlar `final` olmalı, `copyWith` ve JSON dönüşüm metotları bulunmalıdır.
@immutable
class SampleDiaryEntry {
  final String id;
  final DateTime date;
  final String title;
  final String content;

  const SampleDiaryEntry({
    required this.id,
    required this.date,
    required this.title,
    required this.content,
  });

  /// Yeni değerlerle güncellenmiş yeni bir nesne kopyası üretir.
  SampleDiaryEntry copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? content,
  }) {
    return SampleDiaryEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      content: content ?? this.content,
    );
  }

  /// JSON verisinden model nesnesi üretir.
  factory SampleDiaryEntry.fromJson(Map<String, dynamic> json) {
    return SampleDiaryEntry(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );
  }

  /// Model nesnesini JSON haritasına dönüştürür.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'content': content,
    };
  }
}

// ============================================================================
// 2. CONTROLLER KATMANI (Business Logic & State Management)
// ============================================================================
// Controller iş mantığını yönetir ve UI'dan tamamen bağımsızdır.
// Durum değişiklikleri ValueNotifier aracılığıyla reaktif olarak iletilir.
class SampleDiaryController {
  /// Seçili günlük kaydını tutan reaktif notifier.
  final ValueNotifier<SampleDiaryEntry?> currentEntry =
      ValueNotifier<SampleDiaryEntry?>(null);

  /// Yükleniyor durumunu bildiren notifier.
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  /// Günlük kaydını yükler veya oluşturur.
  Future<void> loadSampleEntry() async {
    isLoading.value = true;
    // Sahte gecikme (asenkron veri çekme benzetimi)
    await Future.delayed(const Duration(milliseconds: 300));

    currentEntry.value = SampleDiaryEntry(
      id: 'sample-1',
      date: DateTime.now(),
      title: 'Örnek Günlük Başlığı',
      content: 'Bugün harika bir gün geçti. Flutter mimarisini öğreniyorum.',
    );
    isLoading.value = false;
  }

  /// Günlük içeriğini günceller.
  void updateEntry({required String title, required String content}) {
    final existing = currentEntry.value;
    if (existing == null) return;

    currentEntry.value = existing.copyWith(
      title: title,
      content: content,
    );
  }

  /// Günlük kaydını siler.
  void clearEntry() {
    currentEntry.value = null;
  }

  /// Notifier kaynaklarını serbest bırakır.
  void dispose() {
    currentEntry.dispose();
    isLoading.dispose();
  }
}

// ============================================================================
// 3. VIEW KATMANI (User Interface & Presentation)
// ============================================================================
// View katmanı StatelessWidget olarak tasarlanır ve reaktif güncellemeleri
// ValueListenableBuilder ile dinler. 40 satırı aşan metotlar alt widget'lara ayrılır.
class SampleDiaryScreen extends StatelessWidget {
  final SampleDiaryController controller;

  const SampleDiaryScreen({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Örnek Günlük Ekranı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Yeniden Yükle',
            onPressed: controller.loadSampleEntry,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Temizle',
            onPressed: controller.clearEntry,
          ),
        ],
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: controller.isLoading,
        builder: (context, isLoading, _) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return _SampleDiaryContent(controller: controller);
        },
      ),
    );
  }
}

/// Ayrı bir widget olarak izole edilmiş ana içerik bileşeni.
class _SampleDiaryContent extends StatelessWidget {
  final SampleDiaryController controller;

  const _SampleDiaryContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SampleDiaryEntry?>(
      valueListenable: controller.currentEntry,
      builder: (context, entry, _) {
        if (entry == null) {
          return const Center(
            child: Text(
              'Henüz bir günlük seçilmedi veya oluşturulmadı.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tarih: ${entry.date.day}.${entry.date.month}.${entry.date.year}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                entry.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Divider(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    entry.content,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
