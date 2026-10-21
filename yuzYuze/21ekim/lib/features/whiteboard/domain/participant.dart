import 'package:flutter/material.dart';

/// Tuvaldeki katılımcı modeli
class WhiteboardParticipant {
  final String id;
  final String name;
  final Color color;
  final Offset worldPosition;
  final bool isActive;
  final String? avatarUrl;

  const WhiteboardParticipant({
    required this.id,
    required this.name,
    required this.color,
    this.worldPosition = const Offset(0, 0),
    this.isActive = true,
    this.avatarUrl,
  });

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

  // Katılımcılara atanacak ayırt edici renk paleti
  static const List<Color> participantColors = [
    Color(0xFF06B6D4), // Cyan
    Color(0xFF10B981), // Emerald
    Color(0xFFF97316), // Orange
    Color(0xFFF59E0B), // Amber
    Color(0xFFA855F7), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF3B82F6), // Blue
    Color(0xFF14B8A6), // Teal
  ];
}
