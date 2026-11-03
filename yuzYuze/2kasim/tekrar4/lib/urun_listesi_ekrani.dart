import 'package:flutter/material.dart';

import 'tekrar4_katmanli_mimari.dart'; // Ürün modelini ve API servis sınıflarını kullanmak i.in

class UrunListesiEkrani extends StatefulWidget {
  // API verilerine göre güncellenebilen ürün listesi ekranı
  const UrunListesiEkrani({
    super.key,
  }); // Widget'ın oluşturulmasını ve flutter tarafından takip edilmesini sağlar

  @override // Üst sınıftaki createState metodunu yeniden tanımlar (ezer)
  State<UrunListesiEkrani> createState() => _UrunListesiEkraniState(); // Ekranın değişen durumunu yönetecek State nesnesi
}

class _UrunListesiEkraniState extends State<UrunListesiEkrani> {
  // Ürünleri, yükleme durumunu ve hataları yönetir
  // Ürünleri getirecek servis nesnesi
  final IUrunServisi _servis = CanliApiUrunServisi();

  // API'den gelen ürünler
  List<UrunModel> _tumUrunler = []; // Gelen ürünlerin saklanacağı boş liste

  bool _yukleniyor =
      true; // Veriler gelene kadar yükleme göstergesinin görünmesini sağlar

  String? _hataMesaji; // Hata oluşursa mesajı tutar yoksa null değerini alır

  @override // Üst sınıftaki initState metodu
  void initState() {
    // Widget ilk oluşturulduğunda bir kez çalışır
    super.initState(); // Üst sınıfın başlangıç işlemleri gerçekleşir

    // Ekran açılınca ürünleri getir
    _urunleriYukle();
  }

  Future<void> _urunleriYukle() async {
    // API'den ürünleri getirip ekranın durumunu günceller
    setState(() {
      // Yükleme başladığında arayüzün güncellenmesini sağlar
      _yukleniyor = true; // Yükleme göstergesini aktif hale getirir
      _hataMesaji = null; // Önceki hata mesajını temizler
    });

    try {
      // Ürün yükleme sırasında oluşabilecek hataları yakalamak için kullanılır
      // Servisten ürünleri al asenkron
      final urunler = await _servis.urunleriGetir();

      if (!mounted) return; // Widget ekrandan kaldırılmışsa işlemi durdurur

      setState(() {
        // Gelen ürünleri kaydederek ekranın yeniden oluşturulmasını sağlar
        _tumUrunler = urunler; // API'den gelen ürünleri listeye aktarır
        _yukleniyor = false; // Yükleme işleminin tamamlandığını belirtir
      });
    } catch (hata) {
      // API isteğinde oluşan hataları yakalar
      if (!mounted)
        return; // Widget artık aktif değilse durum güncellemesini engeller

      setState(() {
        // Hata bilgisinin ekranda gösterilmesini sağlar
        _hataMesaji = 'Ürünler yüklenemedi: $hata'; // Kullanıcıya gösterilecek hata mesajı
        _yukleniyor = false; // Hata durumunda yükleme göstergesini kapatır
      });
    }
  }

  @override // Üst sınıftaki build metodu
  Widget build(BuildContext context) {
    // Yükleme, hata veya başarı durumuna göre arayüzü oluşturur
    return Scaffold(
      // Ekranın üst menüsünü ve ana içeriğini oluşturur
      appBar: AppBar(
        title: const Text('Ürün Listesi'),
      ), // Ekranın üst kısmında ürün listesi başlığı

      body:
          _yukleniyor // Yükleme durumuna göre gösterilecek içeriği belirler
          // Veriler gelene kadar yükleniyor göster
          ? const Center(
              child: CircularProgressIndicator(),
            ) // Veriler yüklenirken dönen yükleme animasyonu gösterir
          // Hata varsa mesaj ve tekrar dene butonu
          : _hataMesaji !=
                null // Yükleme hatası olup olmadığını kontrol eder
          ? Center(
              // Hata mesajını ve tekrar dene butonunu ekranın ortasına yerleştirir
              child: Column(
                // Hata mesajı ve butonu dikey sıralar
                mainAxisSize: MainAxisSize.min, // Sütunun yalnızca içerik kadar yer kaplamasını sağlar
                children: [
                  Text(
                    _hataMesaji!,
                  ), // Null olmadığı kontrol edilen hata mesajını gösterir
                  ElevatedButton(
                    // Kullanıcıya yeniden deneme imkanı sunan butonu oluşturur
                    onPressed: _urunleriYukle, // Butona basıldığında API isteğini tekrar başlatır
                    child: const Text('Tekrar Dene'), // Butonun üzerindeki yaz
                  ),
                ],
              ),
            )
          // Ürünler geldiyse listele
          : ListView.builder(
              // API'den gelen ürünleri dinamik liste halinde oluşturur
              itemCount: _tumUrunler.length, // Gösterilecek ürün sayısı

              itemBuilder: (context, index) {
                // Her ürün için ayrı liste elemanı oluşturur
                final urun =
                    _tumUrunler[index]; // Listedeki sıradaki ürünü alır

                return ListTile(
                  // Ürün görseli, adı, kategorisi ve fiyatını içeren satır oluşturur
                  leading: Image.network(
                    // Ürünün görselini internetten yükler
                    urun.resimUrl, // Görselin alınacağı URL adresini belirler
                    width: 50, // Görsel genişliği
                    height: 50, // Görsel yüksekliği
                    errorBuilder: (context, error, stackTrace) {
                      // Görsel yüklenemediğinde çalışır
                      return const Icon(
                        Icons.image_not_supported,
                      ); // Görsel yerine hata ikonunu gösterir
                    },
                  ),

                  title: Text(urun.baslik), // Ürünün adı

                  subtitle: Text(urun.kategori), // Ürünün kategorisi

                  trailing: Text(
                    '${urun.fiyat} TL',
                  ), // Ürünün fiyatı satırın sağ tarafında
                );
              },
            ),
    );
  }
}
