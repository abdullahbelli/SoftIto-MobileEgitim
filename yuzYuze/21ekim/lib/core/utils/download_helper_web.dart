import 'dart:js_interop'; // Modern Dart-JavaScript birlikte çalışabilirlik (interop) API'sini içe aktarır.
import 'dart:typed_data'; // Bayt dizilerini temsil eden Uint8List sınıfını içe aktarır.

import 'package:web/web.dart' as web; // W3C standartlarındaki resmi modern Web API'lerini sağlayan paketi içe aktarır.

/// Flutter Web platformu için dosya indirme yardımcısı
/// Tarayıcıda bir sanal 'a' (anchor) bağlantı etiketi oluşturup tıklatarak dosyanın kullanıcıya inmesini sağlar.
void downloadBytesPlatform(Uint8List bytes, String filename, String mimeType) {
  // Dart Uint8List nesnesini JavaScript Uint8Array türüne dönüştürür.
  final jsArray = bytes.toJS;
  // JavaScript Blob (Binary Large Object) nesnesi oluşturur ve medya tipini (MIME type) belirler.
  final blob = web.Blob([jsArray].toJS, web.BlobPropertyBag(type: mimeType));
  // Bellekteki bu Blob verisine işaret eden geçici bir 'blob:http...' URL adresi oluşturur.
  final url = web.URL.createObjectURL(blob);
  // DOM ağacında gizli bir <a> HTML bağlantı elemanı oluşturur.
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url; // Bağlantı adresini Blob URL'ine ayarlar.
  anchor.download = filename; // İndirilecek dosyanın adını belirler.
  anchor.click(); // Kullanıcı tıklamış gibi programatik olarak tetikler ve indirmeyi başlatır.
  web.URL.revokeObjectURL(url); // Bellek sızıntısını (memory leak) önlemek için oluşturulan geçici URL'i serbest bırakır.
}

/// Flutter Web platformu için metin (SVG vb.) indirme yardımcısı
void downloadTextPlatform(String text, String filename, String mimeType) {
  // String metni JS dizesine çevirip bir Blob içine sarar.
  final blob = web.Blob([text.toJS].toJS, web.BlobPropertyBag(type: mimeType));
  // Blob için geçici bir erişim URL'i oluşturur.
  final url = web.URL.createObjectURL(blob);
  // HTML anchor (a) etiketi yaratır.
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url; // URL'i bağlar.
  anchor.download = filename; // Dosya ismini atar.
  anchor.click(); // İndirme işlemini simüle ederek başlatır.
  web.URL.revokeObjectURL(url); // Kaynakları temizler.
}
