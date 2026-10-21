import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Flutter Web platformu için dosya indirme yardımcısı
void downloadBytesPlatform(Uint8List bytes, String filename, String mimeType) {
  final jsArray = bytes.toJS;
  final blob = web.Blob([jsArray].toJS, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = filename;
  anchor.click();
  web.URL.revokeObjectURL(url);
}

/// Flutter Web platformu için metin indirme yardımcısı
void downloadTextPlatform(String text, String filename, String mimeType) {
  final blob = web.Blob([text.toJS].toJS, web.BlobPropertyBag(type: mimeType));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = filename;
  anchor.click();
  web.URL.revokeObjectURL(url);
}
