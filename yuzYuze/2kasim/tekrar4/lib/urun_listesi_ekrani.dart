import 'package:flutter/material.dart';

import 'tekrar4_katmanli_mimari.dart';

class UrunListesiEkrani extends StatefulWidget {
  const UrunListesiEkrani({super.key});

  @override
  State<UrunListesiEkrani> createState() => _UrunListesiEkraniState();
}

class _UrunListesiEkraniState extends State<UrunListesiEkrani> {
  // Ürünleri getirecek servis
  final IUrunServisi _servis = CanliApiUrunServisi();

  // API'den gelen ürünler
  List<UrunModel> _tumUrunler = [];

  // Yükleme durumu
  bool _yukleniyor = true;

  // Hata mesajı
  String? _hataMesaji;

  @override
  void initState() {
    super.initState();

    // Ekran açılınca ürünleri getir
    _urunleriYukle();
  }

  Future<void> _urunleriYukle() async {
    setState(() {
      _yukleniyor = true;
      _hataMesaji = null;
    });

    try {
      // Servisten ürünleri al
      final urunler = await _servis.urunleriGetir();

      if (!mounted) return;

      setState(() {
        _tumUrunler = urunler;
        _yukleniyor = false;
      });
    } catch (hata) {
      if (!mounted) return;

      setState(() {
        _hataMesaji = 'Ürünler yüklenemedi: $hata';
        _yukleniyor = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ürün Listesi')),

      body: _yukleniyor
          // Veriler gelene kadar yükleniyor göster
          ? const Center(child: CircularProgressIndicator())
          // Hata varsa mesaj ve tekrar dene butonu
          : _hataMesaji != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_hataMesaji!),
                  ElevatedButton(
                    onPressed: _urunleriYukle,
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            )
          // Ürünler geldiyse listele
          : ListView.builder(
              itemCount: _tumUrunler.length,

              itemBuilder: (context, index) {
                final urun = _tumUrunler[index];

                return ListTile(
                  leading: Image.network(
                    urun.resimUrl,
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported);
                    },
                  ),

                  title: Text(urun.baslik),

                  subtitle: Text(urun.kategori),

                  trailing: Text('${urun.fiyat} TL'),
                );
              },
            ),
    );
  }
}
