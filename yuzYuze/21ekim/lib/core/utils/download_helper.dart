import 'dart:typed_data'; // Bayt (byte) dizilerini işlemek için Uint8List veri tipini içe aktarır.

// Koşullu içe aktarma (conditional import):
// Uygulama Web platformunda derlendiğinde (dart.library.js_interop mevcutsa) tarayıcıya özel indirme kodunu (download_helper_web.dart),
// Masaüstü veya Mobil platformlarda ise stub (taslak/yer tutucu) kodunu (download_helper_stub.dart) bağlar.
import 'download_helper_stub.dart'
    if (dart.library.js_interop) 'download_helper_web.dart';

/// Platformlar arası dosya indirme köprüsü
/// Çizilen beyaz tahtayı PNG (ikili bayt) veya SVG (vektörel metin) olarak kullanıcının cihazına kaydeder.
class DownloadHelper {
  /// Bayt dizisi (örneğin PNG resmi) halinde gelen veriyi dosya olarak indirir.
  /// [bytes]: İndirilecek dosyanın ham ikili (binary) bayt verisi.
  /// [filename]: Kullanıcının bilgisayarına/telefonuna kaydedilecek dosya adı (Örn: tahta.png).
  /// [mimeType]: Dosyanın internet ortamındaki medya tipi (Örn: 'image/png').
  static void downloadBytes(Uint8List bytes, String filename, String mimeType) {
    downloadBytesPlatform(
      bytes,
      filename,
      mimeType,
    ); // Platforma özgü indirme fonksiyonunu çağırır.
  }

  /// Metin formatındaki veriyi (örneğin SVG XML kodu) dosya olarak indirir.
  /// [text]: İndirilecek metin içeriği (Örn: `<svg>...</svg>`).
  /// [filename]: Dosya adı (Örn: tahta.svg).
  /// [mimeType]: Dosyanın medya tipi (Örn: 'image/svg+xml').
  static void downloadText(String text, String filename, String mimeType) {
    downloadTextPlatform(
      text,
      filename,
      mimeType,
    ); // Platforma özgü metin indirme fonksiyonunu çağırır.
  }
}
