import 'package:flutter/material.dart';

/// Tuval arka plan desen türleri
enum CanvasBackgroundPattern {
  plain, // Düz / boş
  grid, // Kareli
  ruled, // Çizgili
  dots, // Kâğıt hissi / Noktalı
}

extension CanvasBackgroundPatternExt on CanvasBackgroundPattern {
  String get label {
    switch (this) {
      case CanvasBackgroundPattern.plain:
        return 'Düz';
      case CanvasBackgroundPattern.grid:
        return 'Kareli';
      case CanvasBackgroundPattern.ruled:
        return 'Çizgili';
      case CanvasBackgroundPattern.dots:
        return 'Kâğıt / Noktalı';
    }
  }

  IconData get icon {
    switch (this) {
      case CanvasBackgroundPattern.plain:
        return Icons.crop_din_rounded;
      case CanvasBackgroundPattern.grid:
        return Icons.grid_4x4_rounded;
      case CanvasBackgroundPattern.ruled:
        return Icons.format_align_justify_rounded;
      case CanvasBackgroundPattern.dots:
        return Icons.grain_rounded;
    }
  }
}
