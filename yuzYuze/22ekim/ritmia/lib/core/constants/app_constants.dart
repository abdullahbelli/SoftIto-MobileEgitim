import 'package:flutter/material.dart';

/// Ritmia genel sabitleri, lig isimleri, kategoriler ve motivasyon metinleri.
abstract final class AppConstants {
  static const String appName = 'Ritmia';
  static const String appSlogan = 'Küçük adımlar, güçlü alışkanlıklar.';

  // Alışkanlık Kategorileri
  static const List<String> habitCategories = [
    'Sağlık',
    'Spor',
    'Öğrenme',
    'Zihin',
    'Üretkenlik',
    'Diğer',
  ];

  // Kategori İkonları
  static IconData categoryIcon(String category) {
    return switch (category) {
      'Sağlık' => Icons.favorite_rounded,
      'Spor' => Icons.fitness_center_rounded,
      'Öğrenme' => Icons.menu_book_rounded,
      'Zihin' => Icons.self_improvement_rounded,
      'Üretkenlik' => Icons.bolt_rounded,
      _ => Icons.category_rounded,
    };
  }

  // Kategori Renkleri
  static Color categoryColor(String category) {
    return switch (category) {
      'Sağlık' => const Color(0xFFE11D48),
      'Spor' => const Color(0xFFF97316),
      'Öğrenme' => const Color(0xFF2563EB),
      'Zihin' => const Color(0xFF8B5CF6),
      'Üretkenlik' => const Color(0xFF059669),
      _ => const Color(0xFFDB2777),
    };
  }

  // Hedef Tipleri
  static const String targetTypeCheck = 'check'; // Tamamlandı/Tamamlanmadı
  static const String targetTypeCount = 'count'; // Adet (Örn: 20 sayfa)
  static const String targetTypeDuration = 'duration'; // Dakika (Örn: 30 dk)

  // Lig Kademeleri (En alt: Tohum -> En üst: Yıldız)
  static const List<String> leagueTiers = [
    'Tohum',
    'Filiz',
    'Tomurcuk',
    'Çiçek',
    'Yıldız',
  ];

  static const int maxLeagueMembers = 15;

  // Streak gün sayısına göre motivasyon mesajları (project.md Bölüm 4)
  static String motivationMessage(int streakDays) {
    if (streakDays <= 0) {
      return 'Bugün ilk adımını at!';
    } else if (streakDays <= 6) {
      return 'Harika gidiyorsun, seriyi koru!';
    } else if (streakDays <= 29) {
      return 'Bir haftayı aştın, ritmi yakaladın!';
    } else if (streakDays <= 364) {
      return 'İstikrarın ilham veriyor!';
    } else {
      return 'Bir yılı geride bıraktın! Efsanesin!';
    }
  }

  // Gün adları (Pazartesi: 1 ... Pazar: 7)
  static const Map<int, String> weekdayShortNames = {
    1: 'Pzt',
    2: 'Sal',
    3: 'Çar',
    4: 'Per',
    5: 'Cum',
    6: 'Cmt',
    7: 'Paz',
  };

  static const Map<int, String> weekdayFullNames = {
    1: 'Pazartesi',
    2: 'Salı',
    3: 'Çarşamba',
    4: 'Perşembe',
    5: 'Cuma',
    6: 'Cumartesi',
    7: 'Pazar',
  };
}
