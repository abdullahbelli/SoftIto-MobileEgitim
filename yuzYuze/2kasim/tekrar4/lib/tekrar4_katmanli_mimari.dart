import 'dart:convert'; // JSON verilerini Dart nesnelerine dönüştürmeyi sağlar

import 'package:http/http.dart'
    as http; // API'ye HTTP istekleri göndermeyi sağlar

class UrunModel {
  // API'den gelen ürün bilgilerini temsil eden veri modeli
  final int id;
  final String baslik;
  final double fiyat;
  final String resimUrl;
  final String kategori;

  const UrunModel({
    // Ürün nesnesinin oluşması için grekli alanlar
    required this.id,
    required this.baslik,
    required this.fiyat,
    required this.resimUrl,
    required this.kategori,
  });

  factory UrunModel.fromJson(Map<String, dynamic> json) {
    // API'den gelen JSON verisini UrunModel nesnesine dönüştürür
    return UrunModel(
      // JSON alanlarından yeni bir ürün nesnesi oluşturur
      id: json['id'] as int? ?? 0, // ID yoksa varsayılan olarak 0 kullanır
      baslik:
          json['title'] as String? ??
          'İsimsiz Ürün', // Başlık yoksa varsayılan  'İsimsiz Ürün' kullanır
      fiyat:
          (json['price'] as num?)?.toDouble() ??
          0.0, // Fiyatı double türüne çevirir yoksa 0 kullanır
      resimUrl: json['image'] as String? ?? 'https://via.placeholder.com/150', // Görsel adresi yoksa varsayılan adres kullanır
      kategori:
          json['category'] as String? ??
          'Genel', // Kategori yoksa Genel değerini kullanır
    );
  }
}

abstract class IUrunServisi {
  // Ürün servislerinin uygulaması gereken ortak sözleşme
  Future<List<UrunModel>> urunleriGetir(); // Asenkron olarak ürün listesi döndüren metodun uygulanmasını zorunlu kılar
}

class CanliApiUrunServisi implements IUrunServisi {
  // Ürün servisi sözleşmesini uygulayarak API'den veri çeker
  static const String _base_url = "https://fakestoreapi.com/products"; // Ürünlerin alınacağı API adresi (sabit)

  @override // Arayüzde tanımlanan urunleriGetir metodunu (interface neyi kllnacağıızı belirler nasıl kullanacağımız burada belli olur)
  Future<List<UrunModel>> urunleriGetir() async {
    // API'den ürünleri asenkron olarak getirir
    try {
      // API isteği sırasında oluşabilecek hataları yakalamak için kullanılır
      final yanit = await http
          .get(Uri.parse(_base_url))
          .timeout(
            // API'ye GET isteği gönderir ve yanıtı bekler
            const Duration(
              seconds: 10,
            ), // İsteğin en fazla 10 saniye beklemesini sağlar
            onTimeout: () {
              // Belirlenen süre aşılırsa çalışır belirlenen hatayı fırlatır
              throw Exception('Ağ zaman aşımına upradı.');
            },
          );
      if (yanit.statusCode == 200) {
        // Sunucudan başarılı HTTP yanıtı gelip gelmediğini kontrol eder (200 başarılı kod)
        final List<dynamic> hamListe = jsonDecode(
          yanit.body,
        ) as List<dynamic>; // JSON yanıtını Dart listesine dönüştürür

        return hamListe
            .map((eleman) => UrunModel.fromJson(eleman as Map<String, dynamic>))
            .toList(); // Listedeki her JSON nesnesini UrunModele dönüştürür
      } else {
        // Sunucu başarılı yanıt göndermediğinde çalışır
        throw Exception(
          'Sunucu atası : ${yanit.statusCode}',
        ); // HTTP durum kodunu içeren hata oluşturur
      }
    } catch (e) {
      // API isteği veya veri dönüştürme sırasında oluşan hataları yakalar
      print('Ağ hatası: $e'); // Hata bilgisini konsola yazdırır
      rethrow; // Hatayı üst katmana ileterek ekranın hata göstermesini sağlar
    }
  }
}
