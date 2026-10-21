import 'dart:typed_data';

import 'download_helper_stub.dart'
    if (dart.library.js_interop) 'download_helper_web.dart';

/// Platformlar arası dosya indirme köprüsü
class DownloadHelper {
  static void downloadBytes(Uint8List bytes, String filename, String mimeType) {
    downloadBytesPlatform(bytes, filename, mimeType);
  }

  static void downloadText(String text, String filename, String mimeType) {
    downloadTextPlatform(text, filename, mimeType);
  }
}
