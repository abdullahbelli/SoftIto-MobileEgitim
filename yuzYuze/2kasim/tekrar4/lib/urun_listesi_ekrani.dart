
import 'package:flutter/material.dart';
import 'tekrar4_katmanli_mimari.dart';

class UrunListesiEkrani extends StatefulWidget {
  const UrunListesiEkrani({super.key});

  @override
  State<UrunListesiEkrani> createState() => _UrunListesiEkraniState();
}

class _UrunListesiEkraniState extends State<UrunListesiEkrani> {

  final IUrunServisi _servis = CanliApiUrunServisi();

  List<UrunModel> _tumUrunler = [];

  bool _yukleniyor = true;
  // Ağ veya sunucu hatası oluştuğunda hata metnini tutan değişken (hata yoksa null'dır)
  String? _hataMesaji;

  @override
  // initState metodunun gövdesi
  void initState() {
    // Üst sınıfın initState metodunu çağırır
    super.initState();
    // Sayfa açılır açılmaz ürünleri API'den çekmeye başlar
    _urunleriYukle();
  // initState metodunun kapanış parantezi
  }

  // Widget ağaçtan kaldırıldığında bellek sızıntısını önleyen yaşam döngüsü metodu
  @override
  // dispose metodunun gövdesi
  void dispose() {
    // Arama kontrolcüsünü bellekten serbest bırakır
    
    // Üst sınıfın dispose metodunu çağırır
    super.dispose();
  // dispose metodunun kapanış parantezi
  }

  Future<void> _urunleriYukle() async {
    // Ekranı 'Yükleniyor' moduna sokmak ve eski hataları temizlemek için setState çağrılır
    setState(() {
      // Yüklenme animasyonunu başlatır
      _yukleniyor = true;
      // Varsa önceki hata mesajını sıfırlar
      _hataMesaji = null;
    // setState kapanışı
    });

    // Olası ağ kopmaları, zaman aşımı ve format hataları için try bloğu
    try {
      // Servis üzerinden HTTP GET isteğini atar ve ürün listesini bekler
      final urunler = await _servis.urunleriGetir();
      // Widget ağaçta hâlâ aktif mi kontrol eder (kullanıcı sayfa yüklenirken geri çıktıysa hata almamak için)
      if (!mounted) return;

      // Veriler başarıyla geldiyse durumu günceller
      setState(() {
        // Ham ürün listesini kaydeder
        _tumUrunler = urunler;
        // Başlangıçta tüm ürünleri filtreli listeye de aktarır
        
        // Yüklenme bayrağını kapatır
        
      // setState kapanışı
      });
      // Varsa mevcut filtreleri yeni listeye uygular
      
    // Ağ, zaman aşımı veya sunucu kaynaklı bir hata yakalandığında
    } catch (hata) {
      // Widget ağaçta hâlâ aktif mi kontrol eder
      if (!mounted) return;
      // Ekranı 'Hata' durumuna geçirmek için setState çağrılır
      setState(() {
        // Kullanıcıya gösterilecek anlaşılır hata metnini oluşturur
        _hataMesaji = 'Ürünler yüklenirken bir sorun oluştu.\nİnternet bağlantınızı kontrol edin.';
        // Yüklenme durumunu kapatır
        _yukleniyor = false;
      // setState kapanışı
      });
    // try-catch kapanışı
    }
  // _urunleriYukle fonksiyonu kapanış parantezi
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}