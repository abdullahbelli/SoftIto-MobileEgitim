import 'package:flutter/material.dart'; // Flutter Material simgeleri (IconData) için içe aktarır.

/// Tuval arka plan desen türleri (CanvasBackgroundPattern)
/// Kullanıcının beyaz tahta zemininde görmek istediği ızgara/kılavuz desenlerini temsil eden numaralandırma (enum) tipidir.
enum CanvasBackgroundPattern {
  plain, // Desensiz, tamamen düz ve boş zemin.
  grid, // Matematik defteri gibi kareli ızgara deseni.
  ruled, // Çizgili not defteri deseni.
  dots, // Noktalı ajanda / defter (bullet journal) kağıt dokusu hissi veren nokta deseni.
}

/// CanvasBackgroundPattern enum değerlerine yardımcı özellikler ekleyen genişletme (extension) yapısı
extension CanvasBackgroundPatternExt on CanvasBackgroundPattern {
  /// Desenin arayüz menüsünde kullanıcıya Türkçe gösterilecek adını döndürür.
  String get label {
    // Mevcut enum değerine göre metin seçimi yapan switch kontrol yapısı.
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

  /// Deseni menüde temsil eden Flutter Material simgesini döndürür.
  IconData get icon {
    switch (this) {
      case CanvasBackgroundPattern.plain:
        return Icons.crop_din_rounded; // Boş kare simgesi.
      case CanvasBackgroundPattern.grid:
        return Icons.grid_4x4_rounded; // 4x4 ızgara simgesi.
      case CanvasBackgroundPattern.ruled:
        return Icons.format_align_justify_rounded; // Yatay çizgiler simgesi.
      case CanvasBackgroundPattern.dots:
        return Icons.grain_rounded; // Noktacıklar simgesi.
    }
  }
}
