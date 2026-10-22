import 'package:flutter/material.dart';

/// Rozet tanım modeli.
/// 7 gün (İlk Kıvılcım), 30 gün (Sağlam Ritim) ve 365 gün (Ritmin Ustası) eşiklerini içerir.
class BadgeDefinition {
  final String id;
  final String title;
  final String description;
  final int thresholdDays;
  final IconData icon;
  final Color color;

  const BadgeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.thresholdDays,
    required this.icon,
    required this.color,
  });

  static const List<BadgeDefinition> allBadges = [
    BadgeDefinition(
      id: 'badge_spark_7',
      title: 'İlk Kıvılcım',
      description: 'Bir alışkanlıkta 7 ardışık planlı gün serisine ulaştın.',
      thresholdDays: 7,
      icon: Icons.local_fire_department_rounded,
      color: Color(0xFFF97316), // Turuncu / Bronz
    ),
    BadgeDefinition(
      id: 'badge_rhythm_30',
      title: 'Sağlam Ritim',
      description: 'Bir alışkanlıkta 30 ardışık planlı gün serisini tamamladın.',
      thresholdDays: 30,
      icon: Icons.all_inclusive_rounded,
      color: Color(0xFF8B5CF6), // Gümüş / Mor
    ),
    BadgeDefinition(
      id: 'badge_master_365',
      title: 'Ritmin Ustası',
      description: 'Tam 365 gün boyunca alışkanlık ritmini bozmadın.',
      thresholdDays: 365,
      icon: Icons.workspace_premium_rounded,
      color: Color(0xFFEAB308), // Altın / Işıltılı
    ),
  ];
}
