//1. Ennumları (derleme zamanı güvnliği yazım hatalarını engellemek için)

enum HizmetKategorisi { ciltYenileme, medikalEstetik, lazerEpilasyon, Lipo }

enum SeansDurumu { bekliyor, odadaIslemde, tamamlandi, iptalEdildi }

enum OdemeYontemi { krediKarti, havaleEft, nakit, klinikPaketKredisi }

//Danisan (müşteri) Modeli
class Danisan {
  final String id;
  final String adSoyad;
  final String telefon;
  final bool vipUyeMi;
  final List<String> alerjiler; // boş olabilir ama null olamaz
  final String? ozelCiltNotu; //Opsiyonel Null olabililr

  const Danisan({
    required this.id,
    required this.adSoyad,
    required this.telefon,
    this.vipUyeMi = false,
    this.alerjiler = const [],
    this.ozelCiltNotu,
  });

  bool get hassasCiltMi =>
      alerjiler.isNotEmpty; //sonradan kullanabilmek için get verdik

  //bilgi özet kartı
  String get bilgiOzeti {
    final String alerjiBilgisi = alerjiler.isEmpty
        ? "Kayıtlı Alerji Yok"
        : "Alerjiler: ${alerjiler.join(',')}";
    final String notBilgisi = ozelCiltNotu ?? "Özel medikal not girilmemiş";
    final String vipRozeti = vipUyeMi ? "VİP" : "Standart";
    return "$vipRozeti $adSoyad ($telefon) | $alerjiBilgisi | Not: $notBilgisi";
  }
}

//seans (randevu modeli)

class SeansKaydi {
  final String seansKodu;
  final Danisan danisan;
  final HizmetKategorisi kategori;
  final String islemAdi;
  final double birimFiyat;
  final int seansSayisi;
  final double indirimOrani; // örn 10.0
  final String? sorumluUzman;
  SeansDurumu durum;
  OdemeYontemi? odemeTipi;

  SeansKaydi({
    required this.seansKodu,
    required this.danisan,
    required this.kategori,
    required this.islemAdi,
    required this.birimFiyat,
    this.seansSayisi = 1,
    this.indirimOrani = 0.0,
    this.sorumluUzman,
    this.durum = SeansDurumu.bekliyor,
    this.odemeTipi,
  });

  double get brutTutar => birimFiyat * seansSayisi;

  double get indirimTutari {
    double toplamOran = indirimOrani;
    if (danisan.vipUyeMi) {
      toplamOran += 10.0;
    }
    return brutTutar * (toplamOran / 100);
  }

  double get netTutar => brutTutar - indirimTutari;
}

//Yonetim servisi

class KlinikYoneticisi {
  final String subeAdi;
  final List<SeansKaydi> _seanslar = [];
  final Map<String, Danisan> _danissanRehberi = {};

  KlinikYoneticisi({required this.subeAdi});

  //Danisan kaydetme

  void danisanKaydet(Danisan danisan) {
    _danissanRehberi[danisan.id] = danisan;
    print(
      "Rehbere eklendi: ${danisan.adSoyad} ( ${danisan.vipUyeMi ? "vip" : "standart"})",
    );
  }

  void randevuOlustur(SeansKaydi seans) {
    _seanslar.add(seans);
    print(
      "Randevu kaydedildi [${seans.seansKodu}] : ${seans.danisan.adSoyad} -> ${seans.islemAdi}",
    );
  }

  void seansiTamamla({required String seansKodu, required OdemeYontemi odeme}) {
    for (var seans in _seanslar) {
      if (seans.seansKodu == seansKodu) {
        seans.durum = SeansDurumu.tamamlandi;
        seans.odemeTipi = odeme;
        print(
          "Seans Tamamlandi: [${seans.seansKodu}]: ${seans.netTutar.toStringAsFixed(2)} tahsil edildi (${odeme.name})",
        );
      }
    }
    print("Hata [${seansKodu}] kodlu seans bulunamadı");
    return;
  }

  void seansIptalEt(String seansKodu, {String? iptalNedeni}) {
    for (var seans in _seanslar) {
      if (seans.seansKodu == seansKodu) {
        seans.durum = SeansDurumu.iptalEdildi;
        print(
          "Seans iptal edildi [${seans.seansKodu}] : ${iptalNedeni ?? "Gerekçe belirtilmedi"}",
        );
      }
      ;
      return;
    }
  }

  //Finansla Rapor Metotları(fonksiyonel dart)
  double get toplamTahsilEdilenCiro => _seanslar
      .where((s) => s.durum == SeansDurumu.tamamlandi)
      .fold(0.0, (toplam, s) => toplam + s.netTutar);

  double get beklenenPotansiyelCiro => _seanslar
      .where(
        (s) =>
            s.durum == SeansDurumu.bekliyor ||
            s.durum == SeansDurumu.odadaIslemde,
      )
      .fold(0.0, (toplam, s) => toplam + s.netTutar);

  // kategori bazlı seans sayıları

  Map<HizmetKategorisi, int> kategoriBazliSeansDagilimi() {
    final Map<HizmetKategorisi, int> dagilim = {};
    for (var kat in HizmetKategorisi.values) {
      dagilim[kat] = 0;
    }
    for (var s in _seanslar) {
      dagilim[s.kategori] = (dagilim[s.kategori] ?? 0) + 1;
    }
    return dagilim;
  }

  Set<String> gorevliUzmanKadrosu() {
    return _seanslar.map((s) => s.sorumluUzman).whereType<String>().toSet();
  }

  //Uzmansız kalan seanslar
  List<SeansKaydi> uzmansizSeanslariGetir() {
    return _seanslar.where((s) => s.sorumluUzman == null).toList();
  }

  void gunSonuRaporuYazdir() {
    print("Günlük Seans ve İşlem Çizelgesi");
    print("-------------------------------");
    print(
      "${'Kod'.padRight(20)} | "
      "${'Danışan'.padRight(16)} | "
      "${'İşlem'.padRight(20)} | "
      "${'Uzman'.padRight(18)} | "
      "${'Tutar'.padRight(10)} | "
      "${'Durum'} | ",
    );
    print("-------------------------------");

    for (var s in _seanslar) {
      final String uzman = s.sorumluUzman ?? "Nöbetçi bekliyor";
      final String durumRozet = switch (s.durum) {
        SeansDurumu.tamamlandi => "Tamamlandı",
        SeansDurumu.odadaIslemde => "İşlemde",
        SeansDurumu.bekliyor => "Bekliyor",
        SeansDurumu.iptalEdildi => "İptal",
      };
      print(
        "${s.seansKodu.padRight(10)} | "
        "${s.danisan.adSoyad.padRight(10)} | "
        "${s.islemAdi.padRight(10)} | "
        "${uzman.padRight(10)} | "
        "${s.netTutar.toStringAsFixed(2).padRight(10)} | "
        "${durumRozet} | ",
      );
    }

    print("--------------------------");

    print("Finansal Özet:");
    print(
      " * Gerçekleşen (kasadaki net cire) : ${toplamTahsilEdilenCiro.toStringAsFixed(2)}",
    );
    print(
      " * Bekleyen Potansiyel Alacak : ${beklenenPotansiyelCiro.toStringAsFixed(2)}",
    );
    print(" * Toplam Seeans : ${_seanslar.length} Randevu");

    print("--------------------------");
    print("Aktif Uzmanlar");
    final uzmanlar = gorevliUzmanKadrosu();
    if (uzmanlar.isEmpty) {
      print("Kayıtlı uzman bulunamadı");
    } else {
      print("${uzmanlar.join(', ')}");
    }

    final uzmansizlar = uzmansizSeanslariGetir();
    if (uzmansizlar.isNotEmpty) {
      print(
        "Dikkat: ${uzmansizlar.length} adet seansa henüz uzman atanmamıştır",
      );
      for (var u in uzmansizlar) {
        print("->[${u.seansKodu}] ${u.danisan.adSoyad} (${u.islemAdi})");
      }
    }
    print("--------------------------");
  }
}

void main() {
  print("Kliik yönetim sistemi başlatılıyor....");
  final yonetici = KlinikYoneticisi(subeAdi: "Sofİto Bğcılar Şubesi");

  //danışanlar
  final d1 = Danisan(
    id: "DAN-101",
    adSoyad: "Abdullah Belli",
    telefon: "0555 555 55 55",
    vipUyeMi: true,
    alerjiler: ["Retinol,Aspirin"],
    ozelCiltNotu: "Cilt bariyeri Hassas",
  );

  final d2 = Danisan(
    id: "DAN-102",
    adSoyad: "Abdullah Yılmaz",
    telefon: "0555 555 55 55",
    vipUyeMi: false,
    alerjiler: [],
  );

  final d3 = Danisan(
    id: "DAN-103",
    adSoyad: "Ahmet Belli",
    telefon: "0555 555 55 55",
    vipUyeMi: true,
    alerjiler: ["Retinol,Aspirin"],
  );

  final d4 = Danisan(
    id: "DAN-104",
    adSoyad: "Ahmet Yılmaz",
    telefon: "0555 555 55 55",
    vipUyeMi: true,
    alerjiler: [],
    ozelCiltNotu: "Cilt bariyeri Hassas",
  );

  yonetici.danisanKaydet(d1);
  yonetici.danisanKaydet(d2);
  yonetici.danisanKaydet(d3);
  yonetici.danisanKaydet(d4);

  print("Danışan güvenlik kontrolü");
  print(d1.bilgiOzeti);
  print(d2.bilgiOzeti);
  print("------------------------");

  //randevu oluşturma
  final seans1 = SeansKaydi(
    seansKodu: "SNS-2026-1",
    danisan: d1,
    kategori: HizmetKategorisi.Lipo,
    islemAdi: "Lipo gerisini bilmiyorum",
    birimFiyat: 6500.0,
    seansSayisi: 2,
    indirimOrani: 5.0,
    sorumluUzman: "Uzman Abdullah",
  );

  final seans2 = SeansKaydi(
    seansKodu: "SNS-2026-2",
    danisan: d2,
    kategori: HizmetKategorisi.ciltYenileme,
    islemAdi: "Siverex ile yüz temizleme",
    birimFiyat: 2500.0,
    seansSayisi: 5,
    indirimOrani: 15.0,
    sorumluUzman: null,
  );

  final seans3 = SeansKaydi(
    seansKodu: "SNS-2026-3",
    danisan: d3,
    kategori: HizmetKategorisi.lazerEpilasyon,
    islemAdi: "Tüm vücut",
    birimFiyat: 25000.0,
    seansSayisi: 15,
    indirimOrani: 0.0,
    sorumluUzman: "Tuba Aydın",
  );

  final seans4 = SeansKaydi(
    seansKodu: "SNS-2026-4",
    danisan: d4,
    kategori: HizmetKategorisi.medikalEstetik,
    islemAdi: "Burun Estetiği",
    birimFiyat: 1500.0,
    seansSayisi: 3,
    sorumluUzman: "Furkan Belli",
  );

  yonetici.randevuOlustur(seans1);
  yonetici.randevuOlustur(seans2);
  yonetici.randevuOlustur(seans3);
  yonetici.randevuOlustur(seans4);
  print("Seanslar Gönderiliyor");

  //seans 1 basşarıyla tamammlanıyor(Kredi kartı ile ödeme)
  yonetici.seansiTamamla(
    seansKodu: "SNS-2026-1",
    odeme: OdemeYontemi.krediKarti,
  );
  //seans 2 basariyle tamalanıyor (nakit ödeme)
  yonetici.seansiTamamla(seansKodu: "SNS-2026-2", odeme: OdemeYontemi.nakit);
  //seans 4 ipta
  yonetici.seansIptalEt(
    "SNS-2026-4",
    iptalNedeni: "Danışanın misafiri var o yüzden gelemz",
  );

  yonetici.gunSonuRaporuYazdir();
}
