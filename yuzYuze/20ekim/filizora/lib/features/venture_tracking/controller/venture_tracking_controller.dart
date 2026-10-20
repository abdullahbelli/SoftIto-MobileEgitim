import 'package:flutter/foundation.dart';
import '../models/venture_stage.dart';

/// Girişim Süreci Takibi Durum Yöneticisi
class VentureTrackingController {
  final ValueNotifier<List<VentureStage>> stages;
  final ValueNotifier<List<BusinessOpportunity>> opportunities;

  static final List<VentureStage> _initialStages = [
    const VentureStage(
      id: 's1',
      title: '1. Fikir & Pazar Doğrulama',
      description: 'Hedef kitle mülakatları, rakip analizi ve problem tanımının netleştirilmesi.',
      isCompleted: true,
      isCurrent: false,
      startWeek: 1,
      endWeek: 4,
      duration: 'Hafta 1 - 4 (4 Hafta)',
      tasks: [
        VentureTask(id: 't1', title: '20 potansiyel müşteri ile derinlemesine mülakat', isDone: true),
        VentureTask(id: 't2', title: 'Rakip analizi matrisinin hazırlanması', isDone: true),
        VentureTask(id: 't3', title: 'Değer önerisi tuvali (Value Proposition Canvas)', isDone: true),
      ],
    ),
    const VentureStage(
      id: 's2',
      title: '2. Prototip & MVP Geliştirme',
      description: 'Çekirdek özelliklerin kodlanması, erken kullanıcı testleri.',
      isCompleted: false,
      isCurrent: true,
      startWeek: 4,
      endWeek: 9,
      duration: 'Hafta 4 - 9 (5 Hafta)',
      tasks: [
        VentureTask(id: 't4', title: 'Figma üzerinde interaktif wireframe ve UI akışı', isDone: true),
        VentureTask(id: 't5', title: 'Çekirdek özelliklerin Flutter ile prototiplenmesi', isDone: true),
        VentureTask(id: 't6', title: '10 pilot kullanıcı ile kullanılabilirlik testi', isDone: false),
      ],
    ),
    const VentureStage(
      id: 's3',
      title: '3. Şirketleşme & Destek Başvuruları',
      description: 'KOSGEB/TÜBİTAK başvuruları, vergi ve yasal altyapı.',
      isCompleted: false,
      isCurrent: false,
      startWeek: 8,
      endWeek: 14,
      duration: 'Hafta 8 - 14 (6 Hafta)',
      tasks: [
        VentureTask(id: 't7', title: 'Şirket ana sözleşmesi ve tescil işlemleri', isDone: false),
        VentureTask(id: 't8', title: 'KOSGEB İleri Girişimci Hibe başvuru dosyası', isDone: false),
      ],
    ),
    const VentureStage(
      id: 's4',
      title: '4. Büyüme & Yatırım Turu',
      description: 'Pazara çıkış (Go-to-Market), metrik takibi ve yatırımcı sunumu.',
      isCompleted: false,
      isCurrent: false,
      startWeek: 13,
      endWeek: 20,
      duration: 'Hafta 13 - 20 (7 Hafta)',
      tasks: [
        VentureTask(id: 't9', title: 'CAC, LTV ve MRR gösterge panelleri', isDone: false),
        VentureTask(id: 't10', title: 'Yatırımcı Pitch Deck sunumunun hazırlanması', isDone: false),
      ],
    ),
  ];

  static final List<BusinessOpportunity> _initialOpportunities = [
    const BusinessOpportunity(
      id: 'o1',
      title: 'Tarım Kooperatifi IoT Pilot Anlaşması',
      source: 'Mentor Yönlendirmesi',
      potentialValue: '180.000 ₺ / Yıl',
      status: 'Sözleşme Aşamasında',
    ),
    const BusinessOpportunity(
      id: 'o2',
      title: 'Bölgesel Teknokent Kuluçka Ofis Tahsisi',
      source: 'Destek Başvurusu',
      potentialValue: '%80 Kira & Altyapı İndirimi',
      status: 'Kabul Edildi',
    ),
    const BusinessOpportunity(
      id: 'o3',
      title: 'Özel Sermaye Melek Yatırımcı Ön Görüşmesi',
      source: 'Topluluk Etkinliği',
      potentialValue: '1.200.000 ₺ Tohum Öncesi',
      status: 'İlk Sunum Yapıldı',
    ),
  ];

  VentureTrackingController({
    List<VentureStage>? initialStages,
    List<BusinessOpportunity>? initialOpportunities,
  })  : stages = ValueNotifier<List<VentureStage>>(initialStages ?? _initialStages),
        opportunities = ValueNotifier<List<BusinessOpportunity>>(initialOpportunities ?? _initialOpportunities);

  void toggleTask(String stageId, String taskId) {
    stages.value = stages.value.map((stage) {
      if (stage.id == stageId) {
        final updatedTasks = stage.tasks.map((task) {
          if (task.id == taskId) {
            return task.copyWith(isDone: !task.isDone);
          }
          return task;
        }).toList();

        final allDone = updatedTasks.every((t) => t.isDone);
        return stage.copyWith(
          tasks: updatedTasks,
          isCompleted: allDone,
        );
      }
      return stage;
    }).toList();
  }

  void dispose() {
    stages.dispose();
    opportunities.dispose();
  }
}
