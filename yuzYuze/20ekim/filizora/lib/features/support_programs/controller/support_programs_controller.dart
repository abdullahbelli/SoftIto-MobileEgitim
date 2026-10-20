import 'package:flutter/foundation.dart';
import '../models/support_program.dart';

/// Destek Programları Durum Yöneticisi
class SupportProgramsController {
  final ValueNotifier<List<SupportProgram>> programs;
  final ValueNotifier<String?> selectedCategory;
  final ValueNotifier<bool> showOnlyApplied;

  static final List<SupportProgram> _defaultPrograms = [
    const SupportProgram(
      id: 'sp1',
      title: 'İleri Girişimci Destek Programı',
      institution: 'KOSGEB',
      amountLimit: '1.000.000 ₺',
      category: 'Hibe',
      deadline: 'Sürekli Açık',
      eligibility: 'İmalat ve teknoloji odaklı yeni kurulan girişimler.',
      summary:
          'Makine, teçhizat ve yazılım giderleri ile mentörlük, danışmanlık ve işletme kuruluş desteğini içeren kapsamlı hibe programı.',
    ),
    const SupportProgram(
      id: 'sp2',
      title: '1812 - Yatırım Tabanlı BİGG',
      institution: 'TÜBİTAK',
      amountLimit: '900.000 ₺',
      category: 'Tohum Yatırım',
      deadline: '15 Kasım 2026',
      eligibility: 'Ar-Ge ve inovasyon içeren teknolojik iş fikri olan lisans/lisansüstü girişimciler.',
      summary:
          'Teknoloji tabanlı iş fikirlerinin şirketleşmesi için TÜBİTAK BİGG Fonu üzerinden hisse karşılığı tohum yatırım desteği.',
    ),
    const SupportProgram(
      id: 'sp3',
      title: 'Geleneksel Girişimci Destek Programı',
      institution: 'KOSGEB',
      amountLimit: '130.000 ₺',
      category: 'Hibe',
      deadline: 'Sürekli Açık',
      eligibility: 'Hizmet ve ticaret sektöründe faaliyete başlayan yeni işletmeler.',
      summary:
          'Yeni girişim kuracak girişimciler için kuruluş ve personel istihdam desteği sağlayan temel hibe paketi.',
    ),
    const SupportProgram(
      id: 'sp4',
      title: 'Bölgesel Girişim Hızlandırma Desteği',
      institution: 'Kalkınma Ajansı',
      amountLimit: '500.000 ₺',
      category: 'Hızlandırıcı',
      deadline: '30 Aralık 2026',
      eligibility: 'Bölgesel kalkınma ve yeşil dönüşüm odaklı yenilikçi girişimler.',
      summary:
          'Hızlandırıcı eğitimleri, prototip atölye imkanları ve pazar erişim teşvikleri içeren hibrit destek.',
    ),
  ];

  SupportProgramsController({List<SupportProgram>? initialPrograms})
      : programs = ValueNotifier<List<SupportProgram>>(initialPrograms ?? _defaultPrograms),
        selectedCategory = ValueNotifier<String?>(null),
        showOnlyApplied = ValueNotifier<bool>(false);

  List<SupportProgram> get filteredPrograms {
    var list = programs.value;
    if (showOnlyApplied.value) {
      list = list.where((p) => p.isApplied).toList();
    }
    final cat = selectedCategory.value;
    if (cat != null && cat.isNotEmpty) {
      list = list.where((p) => p.category == cat).toList();
    }
    return list;
  }

  int get appliedCount => programs.value.where((p) => p.isApplied).length;

  void filterByCategory(String? category) {
    selectedCategory.value = category;
  }

  void toggleShowOnlyApplied(bool value) {
    showOnlyApplied.value = value;
  }

  void toggleSave(String programId) {
    programs.value = programs.value.map((p) {
      if (p.id == programId) {
        return p.copyWith(isSaved: !p.isSaved);
      }
      return p;
    }).toList();
  }

  bool applyToProgram(
    String programId, {
    String? projectTitle,
    String? requestedAmount,
  }) {
    programs.value = programs.value.map((p) {
      if (p.id == programId) {
        return p.copyWith(
          isApplied: true,
          applicationStatus: 'Değerlendirmede',
          applicationDate: DateTime.now(),
          projectTitle: projectTitle,
          requestedAmount: requestedAmount,
        );
      }
      return p;
    }).toList();
    return true;
  }

  void cancelApplication(String programId) {
    programs.value = programs.value.map((p) {
      if (p.id == programId) {
        return p.copyWith(
          isApplied: false,
          applicationStatus: null,
          applicationDate: null,
          projectTitle: null,
          requestedAmount: null,
        );
      }
      return p;
    }).toList();
  }

  void dispose() {
    programs.dispose();
    selectedCategory.dispose();
    showOnlyApplied.dispose();
  }
}
