extension AltinFormatUzantisi on int {
  // sayıyı formatlı altın metnine çevir
  String get toAltinKese => "${this} Altın";
}

extension AgirlikFormatuzantisi on double {
  //Ağırlık Kg olarak göster
  String get toAgirlikKg => "${this.toStringAsFixed(1)} kg";
}

// eşyaların nadirlik dereceleri
enum EsyaNadirligi { yaygin, nadir, destansi, efsanevi }

//genel zindan hata sınıfları
class ZindanException implements Exception {
  final String hataKodu;
  final String mesaj;
  final DateTime zaman = DateTime.now();

  ZindanException(this.hataKodu, this.mesaj);

  @override
  String toString() => "[$hataKodu] $mesaj ($zaman)";
}

//çanta ağırlık aşıldığında hata kodu
class CantadaYerYokException extends ZindanException {
  CantadaYerYokException(double asim)
    : super(
        "ERR_BAG_FULL",
        "Çanta Kapasitesi $asim kg Aşıldı. Eşyayı Alamazsınız",
      );
}

//Yetersiz altın durumudnda hata
class YetersizAltinException extends ZindanException {
  YetersizAltinException(int eksik)
    : super("ERR_NO_GOLD", "Bu işlem için $eksik altın daha gerekiyor");
}

//--------
//Mixiler
//----------

//parcalanıp büyü tozuna dönüşebilen eşyalar
mixin ParcalanabilirYeisi {
  void tozaDonustur(String esyaAdi) {
    print("Demirci $esyaAdi parçalandı ve 5 adet mavi büyü tozu elde edildi.");
  }
}

//rün basılarak extra güç kazandıran eşyalar
mixin RuneBasmaYetisi {
  void runKusa(String runeTuru) {
    print(
      "Rüm Büyüsü : Eşyaya '$runeTuru' rünü mühürlendi. (+15 büyü hsarı eklendi)",
    );
  }
}

//-------------------------
//Esya/item modeli
//---------------------------

class Esya with ParcalanabilirYeisi, RuneBasmaYetisi {
  final String id;
  final String ad;
  final double agirlik;
  final EsyaNadirligi nadirlik;
  final String? aciklama;
  final bool efsunlumu;

  Esya({
    required this.ad,
    required this.id,
    required this.agirlik,
    required this.nadirlik,
    this.aciklama,
    this.efsunlumu = false,
  });
  Esya.kucukCanIksiri()
    : id = "POT-001",
      ad = "Küçük Şifa İksiri",
      agirlik = 0.5,
      nadirlik = EsyaNadirligi.yaygin,
      aciklama = "İçildiğinde anında 30 can yeniler",
      efsunlumu = false;

  //records
  ({String etiket, double carpan, int satisFiyati}) degerlemeYap() {
    final (etiket, carpan, bazFiyat) = switch (nadirlik) {
      EsyaNadirligi.yaygin => ("Yaygın", 1.0, 50),
      EsyaNadirligi.nadir => ("Nadir", 1.5, 200),
      EsyaNadirligi.destansi => ("Destansı", 2.5, 750),
      EsyaNadirligi.efsanevi when efsunlumu => ("Kadim Efsanevi", 5.0, 3000),
      EsyaNadirligi.efsanevi => ("Efsanevi", 4.0, 2000),
    };
    return (
      etiket: etiket,
      carpan: carpan,
      satisFiyati: (bazFiyat * carpan).toInt(),
    );
  }
}

//Oyuncunun Çantası

class OyuncuCantasi {
  final String sahipAdi;
  final double maxAgiirlikKapasitesi;
  final List<Esya> _esyalar = [];
  int _altin = 500;

  OyuncuCantasi({required this.sahipAdi, this.maxAgiirlikKapasitesi = 25.0});

  int get altin => _altin;

  //altın harcama metodu

  void altinHarca(int miktar) {
    if (miktar > _altin) {
      throw YetersizAltinException(miktar - _altin);
    }
    _altin -= miktar;
    print(
      "[Ticaret]: $miktar altın harcandı. Kalan CüzdanÇ ${_altin.toAltinKese}",
    );
  }

  //canta ağırlığı hesapla
  double get mevcutAgirlik => _esyalar.fold(0.0, (acc, e) => acc + e.agirlik);

  //cantaya eşya ekelme
  void esyaEkle(Esya yeniEsya) {
    if (mevcutAgirlik + yeniEsya.agirlik > maxAgiirlikKapasitesi) {
      final double asim =
          (mevcutAgirlik + yeniEsya.agirlik) - maxAgiirlikKapasitesi;
      throw CantadaYerYokException(asim);
    }
    _esyalar.add(yeniEsya);
    print(
      "[Çanta]: '${yeniEsya.ad}' çantaya eklendi. (${yeniEsya.agirlik.toAgirlikKg})",
    );
  }

  //sadece değerli eşyaları fitrele
  List<Esya> get degerliEsyalar => _esyalar
      .where(
        (e) =>
            e.nadirlik == EsyaNadirligi.destansi ||
            e.nadirlik == EsyaNadirligi.efsanevi,
      )
      .toList();

  // Çanta döküm raporu

  void envanterRaporuBas() {
    print("""
===========================================
Kahraman Envanter Raporu
Sahip: $sahipAdi | Altın: ${_altin.toAltinKese} | Yük: ${mevcutAgirlik.toAgirlikKg}/${maxAgiirlikKapasitesi.toAgirlikKg};
=============================================
""");

    for (var esya in _esyalar) {
      final deger = esya.degerlemeYap();
      final aciklamaMetni = esya.aciklama ?? "Özel Nitelik Belirtilmemiş";
      print(
        "${deger.etiket.padRight(20)} | ${esya.ad.padRight(24)} | ${esya.agirlik.toAgirlikKg.padLeft(8)} | Değer: ${deger.satisFiyati.toAltinKese}",
      );
      print("Not: $aciklamaMetni");
    }
    print("Değerli Eşya Sayısı: ${degerliEsyalar.length} adet");
    print("==================================");
  }
}

void main() {
  print("Zindan & Envanter Motoru Balatılıyor....");

  final bool vipUyelik = true;

  // çantamızı oluşturuyoruz

  final canta = OyuncuCantasi(sahipAdi: "AbdBel", maxAgiirlikKapasitesi: 20.0);
  final List<Esya> zindanGirisPaketi = [
    Esya.kucukCanIksiri(),
    Esya(
      id: "SWD-101",
      ad: "Gümüş Ejder Kılıcı",
      agirlik: 4.5,
      nadirlik: EsyaNadirligi.destansi,
      aciklama: "Karanlık yaratıklara karşı %25 ek hasar",
      efsunlumu: true,
    ),

    if (vipUyelik)
      Esya(
        id: "RNG-999",
        ad: "Zamanın Sonu Yüzüğü",
        agirlik: 0.2,
        nadirlik: EsyaNadirligi.efsanevi,
        aciklama: "Bekleme Sürelerini %20 azaltır",
        efsunlumu: true,
      ),
  ];

  //esyaları cantaya ekleme
  for (var esya in zindanGirisPaketi) {
    canta.esyaEkle(esya);
  }

  print("Zanaat ve büyü masası");
  final kilic = zindanGirisPaketi[1];
  kilic.runKusa("Kutsal Işık");
  kilic.tozaDonustur(kilic.ad);

  print("Ticaret ve altın harcama");

  try {
    canta.altinHarca(200);
    canta.altinHarca(800);
  } on YetersizAltinException catch (e) {
    print("Hata Yakalandı ${e.mesaj}");
  } catch (e) {
    print("Genel hata $e");
  }

  //kapasite aşım testi
  print("Çanta kapasitesi Aşımı");
  try {
    final devKaya = Esya(
      ad: "Gök Taşı Parçaşı",
      id: "BLD-777",
      agirlik: 28.0,
      nadirlik: EsyaNadirligi.yaygin,
    );
    canta.esyaEkle(devKaya);
  } on CantadaYerYokException catch (e) {
    print("Aşırı yük engellendi -> ${e.mesaj}");
  }
  canta.envanterRaporuBas();
}
