import 'package:flutter/material.dart'; // Flutter Material renk (Color) ve koordinat (Offset) sınıflarını içe aktarır.

/// Tuvaldeki katılımcı modeli (WhiteboardParticipant)
/// Gerçek zamanlı ortak çalışmada odada bulunan kullanıcıları, imleç/çizim pozisyonlarını ve ayırt edici renklerini temsil eder.
class WhiteboardParticipant {
  final String id; // Katılımcının benzersiz kullanıcı kimliği.
  final String name; // Katılımcının ekranda görünecek ismi.
  final Color
  color; // Kullanıcının imleç ve çizimlerini ayırt etmeye yarayan özel renk.
  final Offset worldPosition; // Kullanıcının imlecinin veya farenin tuval dünya koordinatlarındaki (x, y) konumu.
  final bool isActive; // Kullanıcının odada aktif (çevrim içi) olup olmadığını belirten bayrak.
  final String? avatarUrl; // Katılımcının profil fotoğrafı URL'i (varsa).

  // Değişmez kurucu fonksiyon.
  const WhiteboardParticipant({
    required this.id,
    required this.name,
    required this.color,
    this.worldPosition = const Offset(
      0,
      0,
    ), // Varsayılan başlangıç konumu (0, 0).
    this.isActive = true, // Varsayılan olarak aktif.
    this.avatarUrl,
  });

  /// Katılımcının konum veya durum değişimlerinde yeni bir kopya oluşturmasını sağlayan fonksiyon.
  WhiteboardParticipant copyWith({
    String? id,
    String? name,
    Color? color,
    Offset? worldPosition,
    bool? isActive,
    String? avatarUrl,
  }) {
    return WhiteboardParticipant(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      worldPosition: worldPosition ?? this.worldPosition,
      isActive: isActive ?? this.isActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  // Odaya yeni giren katılımcılara sırayla atanacak canlı ve ayırt edici renk paleti.
  static const List<Color> participantColors = [
    Color(0xFF06B6D4), // Camgöbeği (Cyan)
    Color(0xFF10B981), // Zümrüt Yeşili (Emerald)
    Color(0xFFF97316), // Sıcak Turuncu (Orange)
    Color(0xFFF59E0B), // Amber Sarısı (Amber)
    Color(0xFFA855F7), // Mor (Purple)
    Color(0xFFEC4899), // Pembe (Pink)
    Color(0xFF3B82F6), // Okyanus Mavisi (Blue)
    Color(0xFF14B8A6), // Deniz Yeşili (Teal)
  ];
}
