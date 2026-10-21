import 'dart:typed_data'; // Ham ikili verileri temsil eden Uint8List tipini içe aktarır.

/// Web harici platformlar (Mobil, Masaüstü) için dosya indirme taslağı (stub)
/// Web dışı platformlarda web tarayıcı API'leri (HTML anchor, blob) bulunmadığı için
/// koşullu derleme bu fonksiyonu seçer. İleride path_provider ile yerel diske kaydetme eklenebilir.
void downloadBytesPlatform(Uint8List bytes, String filename, String mimeType) {
  // Masaüstü ve mobilde dosya kaydetme diyaloğu veya yerel dosya yazımı buraya eklenir.
}

/// Web harici platformlar için metin/SVG indirme taslağı
/// Metin formatındaki SVG verilerini yerel dosya sistemine yazmak için ayrılmış taslak metot.
void downloadTextPlatform(String text, String filename, String mimeType) {
  // Masaüstü ve mobilde metin/SVG kaydetme taslağı buraya eklenir.
}
