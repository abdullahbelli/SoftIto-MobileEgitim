// ==============================================================================
// Dosya: sample_screen.dart
// Konum: .agents/skills/examples/sample_screen.dart
// Proje: Susadım (Fitness Su Takip Uygulaması)
// Standart: project.md & SKILL.md (flutter-feature-scaffold)
// Açıklama: Clean UI, reaktif ValueNotifier mimarisi, immutable veri modeli,
//           <40 satır parçalı widget kuralı ve const zorunluluğuna tam uyumlu
//           eksiksiz örnek ekran şablonu.
// ==============================================================================

import 'package:flutter/material.dart';

// ==============================================================================
// 1. İMMUTABLE VERİ MODELİ (MODEL KATMANI)
// ==============================================================================

/// Su tüketim geçmiş kaydı modeli (İmmutable mimari)
@immutable
class SampleWaterLog {
  final String id;
  final int amount; // ml cinsinden tüketim miktarı
  final String note;
  final DateTime timestamp;

  const SampleWaterLog({
    required this.id,
    required this.amount,
    required this.note,
    required this.timestamp,
  });

  /// Değişen alanları güncelleyerek yeni kopya üretir
  SampleWaterLog copyWith({
    String? id,
    int? amount,
    String? note,
    DateTime? timestamp,
  }) {
    return SampleWaterLog(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// JSON haritasından model üretir
  factory SampleWaterLog.fromJson(Map<String, dynamic> json) {
    return SampleWaterLog(
      id: json['id'] as String? ?? '',
      amount: json['amount'] as int? ?? 0,
      note: json['note'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  /// Modeli JSON haritasına dönüştürür
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SampleWaterLog &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          amount == other.amount;

  @override
  int get hashCode => id.hashCode ^ amount.hashCode;
}

// ==============================================================================
// 2. REAKTİF KONTROLCÜ (CONTROLLER KATMANI)
// ==============================================================================

/// Reaktif durum ve iş mantığı yöneticisi (ValueNotifier mimarisi)
class SampleWaterController {
  /// Mevcut tüketilen toplam su miktarı (ml)
  final ValueNotifier<int> currentWater = ValueNotifier<int>(0);

  /// Günlük tüketim geçmiş listesi
  final ValueNotifier<List<SampleWaterLog>> logs =
      ValueNotifier<List<SampleWaterLog>>(<SampleWaterLog>[]);

  /// Günlük hedef (ml)
  final int dailyGoal = 2500;

  /// Su ekleme metodu
  void addWater(int amount, {String note = 'Hızlı Su Girişi'}) {
    currentWater.value += amount;

    final newLog = SampleWaterLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      note: note,
      timestamp: DateTime.now(),
    );

    logs.value = [newLog, ...logs.value];
  }

  /// Verileri sıfırlama metodu
  void reset() {
    currentWater.value = 0;
    logs.value = <SampleWaterLog>[];
  }

  /// Bellek sızıntılarını önlemek için dinleyicileri serbest bırakır
  void dispose() {
    currentWater.dispose();
    logs.dispose();
  }
}

// ==============================================================================
// 3. PARÇALI WIDGET'LAR (WIDGET KATMANI - <40 SATIR BUILD KURALI)
// ==============================================================================

/// İlerleme Kartı Bileşeni (<40 satır build kuralına tam uyumlu)
class SampleProgressCard extends StatelessWidget {
  final int current;
  final int goal;

  const SampleProgressCard({
    super.key,
    required this.current,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = (goal > 0) ? (current / goal).clamp(0.0, 1.0) : 0.0;
    final percent = (ratio * 100).toInt();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Günlük Hedef',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '%$percent',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$current ml / $goal ml',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hızlı Aksiyon Butonları (<40 satır build kuralına tam uyumlu)
class SampleQuickActions extends StatelessWidget {
  final void Function(int amount) onAdd;
  final VoidCallback onReset;

  const SampleQuickActions({
    super.key,
    required this.onAdd,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => onAdd(250),
            icon: const Icon(Icons.water_drop),
            label: const Text('+250 ml'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: () => onAdd(500),
            icon: const Icon(Icons.local_drink),
            label: const Text('+500 ml'),
          ),
        ),
        const SizedBox(width: 8),
        IconButton.outlined(
          onPressed: onReset,
          icon: const Icon(Icons.refresh),
          tooltip: 'Sıfırla',
        ),
      ],
    );
  }
}

/// Tüketim Geçmiş Liste Öğesi (<40 satır build kuralına tam uyumlu)
class SampleLogTile extends StatelessWidget {
  final SampleWaterLog log;

  const SampleLogTile({
    super.key,
    required this.log,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr =
        '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(Icons.water_drop, color: theme.colorScheme.primary, size: 20),
        ),
        title: Text('${log.amount} ml', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(log.note),
        trailing: Text(timeStr, style: theme.textTheme.bodySmall),
      ),
    );
  }
}

/// Tüketim Geçmiş Listesi (<40 satır build kuralına tam uyumlu)
class SampleLogList extends StatelessWidget {
  final List<SampleWaterLog> logs;

  const SampleLogList({
    super.key,
    required this.logs,
  });

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text('Bugün henüz su tüketimi kaydedilmedi.'),
        ),
      );
    }

    return Column(
      children: logs.map((item) => SampleLogTile(key: ValueKey(item.id), log: item)).toList(),
    );
  }
}

// ==============================================================================
// 4. ANA GÖRÜNÜM (VIEW KATMANI - STATELESSWIDGET & <40 SATIR BUILD KURALI)
// ==============================================================================

/// Örnek Su Takip Ekran Görünümü (StatelessWidget + ValueNotifier mimarisi)
class SampleScreenView extends StatelessWidget {
  final SampleWaterController controller;

  const SampleScreenView({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Susadım • Reaktif Su Takibi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: controller.currentWater,
              builder: (context, current, _) {
                return SampleProgressCard(
                  current: current,
                  goal: controller.dailyGoal,
                );
              },
            ),
            const SizedBox(height: 20),
            SampleQuickActions(
              onAdd: controller.addWater,
              onReset: controller.reset,
            ),
            const SizedBox(height: 24),
            Text(
              'Günlük Tüketim Kayıtları',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<List<SampleWaterLog>>(
              valueListenable: controller.logs,
              builder: (context, logs, _) {
                return SampleLogList(logs: logs);
              },
            ),
          ],
        ),
      ),
    );
  }
}
