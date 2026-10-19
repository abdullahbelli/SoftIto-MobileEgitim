//1. Enumları (derleme zamanı güvnliği yazım hatalarını engellemek için enum kulanık. String olsaydı lazerEpilaasyon yeine lazerepilasyon falan yazabilirdik.)

enum HizmetKategorisi { ciltYenileme, medikalEstetik, lazerEpilasyon, Lipo }

enum SeansDurumu {
  bekliyor,
  odadaIslemde,
  tamamlandi,
  iptalEdildi,
} //seansın alabileceği değerleri sınırlamak için enum kullandık SeansDurumu sadece bu değerlerden birini alabilir.

enum OdemeYontemi {
  krediKarti,
  havaleEft,
  nakit,
  klinikPaketKredisi,
} //OdemeYontemi sadece belirlediğimiz değerlerder bşrini alabilir.

//Danisan (müşteri) Modeli
class Danisan {
  //Danışan bilgilerini tek bir yapı altında tutmak için
  final String
  id; //final yaptık çünkü oluşturulduktan sonra değiştirlsin istemiyoruz
  final String adSoyad;
  final String telefon;
  final bool vipUyeMi; // vip mi değil mi true false bool kullnadık
  final List<String>
  alerjiler; // boş olabilir ama null olamaz       bir danışanın birden fazla alaerjisi olabilir diye List kullandık
  final String?
  ozelCiltNotu; //Opsiyonel Null olabililr   //her danşanın özel notu olmak zorunda değil String? null oalbileceği anlamıd gelir

  const Danisan({
    //const constructor çünkü DAnısan nesnesinin alanlrı final ve uygun durumlarda değişmeyen nesneler oluşturmak istiyoruz
    required this.id, // zornlu olanlarda required kullanılır
    required this.adSoyad,
    required this.telefon,
    this.vipUyeMi =
        false, //vip bilgisi verilmezse danışan normal üye kabul edilsin diye false verdik
    this.alerjiler =
        const [], //alerji bilgisi girilmezse null yerine boş liste olsun diye çünkü alerjiler boş olabilir ama null olmaz
    this.ozelCiltNotu, //ozelCiltNotu yoksa null olur
  });

  bool get hassasCiltMi =>
      alerjiler.isNotEmpty; //sonradan kullanabilmek için get verdik
  //hassa cilt mi bilgisini her seferinde hsaplamamak için get verdik
  //alerji listsi boş değilse en az bir eleman varsa hassa cilt kabul ediyoruz

  //bilgi özet kartı

  // Danışanın bilgilerini tek bir String halinde döndürmek için getter kullandık.
  // Fonksiyon gibi çalışıyor ama dışarıdan değişken gibi kullanabiliyoruz.
  String get bilgiOzeti {
    final String alerjiBilgisi = alerjiler.isEmpty
        ? "Kayıtlı Alerji Yok"
        : "Alerjiler: ${alerjiler.join(',')}";
    // Ternary operatör
    // Liste boşsa kayıtlı alerji yok yazıyoruz.
    // Liste doluysa alerjileri ekrana yazıyoruz.

    final String notBilgisi = ozelCiltNotu ?? "Özel medikal not girilmemiş";
    // ?? kullandık çünkü ozelCiltNotu null olabilir.
    // Eğer null ise sağ taraftaki varsayılan yazıyı kullanıyoruz.

    final String vipRozeti = vipUyeMi ? "VİP" : "Standart";
    // VIP üyelik true ise VİP, değilse Standart yazdırıyoruz.

    return "$vipRozeti $adSoyad ($telefon) | $alerjiBilgisi | Not: $notBilgisi";
    //hazırlanan bütün bilgileri te bir String halinde geri döndürür.
  }
}

//seans (randevu modeli)

class SeansKaydi {
  // Bir danışanın randevu/seans bilgileri
  final String seansKodu; //her seansın birbirinden farklı seasn kodu var
  final Danisan danisan;
  // Sadece danışanın adını değil tüm bilgilerini kullanabilmek için Danisan tipini kullandık.
  final HizmetKategorisi kategori;
  // Hizmet kategorisini sadece enumdaki değerlerden seçebilmek için HizmetKategorisi tipinde tuttuk.
  final String islemAdi;
  final double birimFiyat; // Fiyat küsuratlı olabileceği için double
  final int seansSayisi;
  final double indirimOrani;
  // örn 10.0  // indirimOrani küsuratlı olabileceği için double
  final String? sorumluUzman;
  // Bazı seanslara henüz uzman atanmayabileceği için String?
  SeansDurumu durum;
  // Seansın durumu sonradan değişeceği için final kullanmadık.
  OdemeYontemi? odemeTipi;
  //ödeme seasn oluşturulduğu anda yapılmayabilir nullable

  SeansKaydi({
    //seans nesnesi oluştrumak için constructor
    required this.seansKodu, //zorunlu olanlara required
    required this.danisan,
    required this.kategori,
    required this.islemAdi,
    required this.birimFiyat,
    this.seansSayisi = 1, //seans sayısı verilmezse varsayılan 1
    this.indirimOrani = 0.0, // indirim oranı verilmezse varsayılan 0
    this.sorumluUzman, // Uzman henüz belli olmayabilir
    this.durum = SeansDurumu.bekliyor,
    // Yeni oluşturulan seans varsayılan olarak bekliyor durumunda başlar
    this.odemeTipi, // Ödeme henüz yapılmamış olabilir
  });

  double get brutTutar =>
      birimFiyat *
      seansSayisi; // Brüt tutarı hesaplamak için getter kullandık. birimTutar * seansSayisi

  double get indirimTutari {
    // Toplam indirim tutarını hesaplamak için getter kullandık.
    double toplamOran =
        indirimOrani; //seansa verilen normal indirim oranını toplamtura olarak alıyoruz
    if (danisan.vipUyeMi) {
      toplamOran += 10.0; //sanışan vip üye ise %10 indirim daha ekliyoruz
    }
    return brutTutar * (toplamOran / 100);
    //en son indirim tutarını topla orana göre hesaplarız
  }

  double get netTutar => brutTutar - indirimTutari;
  //son ödenecek tutar hesaplanır
}

//Yonetim servisi

// Danışanları, randevuları ve finansal işlemleri tek yerden yönetebilmek için yönetici class

class KlinikYoneticisi {
  final String subeAdi;
  final List<SeansKaydi> _seanslar = []; //birden fazla seasn olablilr list
  // _ kullanmamızın sebebi bu listenin class dışından doğrudan değiştirilmesini istemememiz.
  final Map<String, Danisan> _danissanRehberi = {};
  // Danışanları ID değerleri üzerinden hızlı şekilde tutabilmek için Map kullandık.
  // String = danışanın ID'si
  // Danisan = danışanın kendisi

  KlinikYoneticisi({
    required this.subeAdi,
  }); //klinik yönerticisined sadece şube adını zorunlu olarak istiyoruz

  //Danisan kaydetme

  void danisanKaydet(Danisan danisan) {
    _danissanRehberi[danisan.id] = danisan;
    // Map içerisinde key olarak danışanın id sini value olarak danışan nesnesini tutuyoruz.
    print(
      // Kayıt işleminin sonucunu ekranda görmek
      "Rehbere eklendi: ${danisan.adSoyad} ( ${danisan.vipUyeMi ? "vip" : "standart"})",
      // Ternary kullanarak VIP ise "vip", değilse "standart" yazdırıyoruz.
    );
  }

  void randevuOlustur(SeansKaydi seans) {
    _seanslar.add(seans); // Gelen seansı seans listesine ekler
    print(
      // hangii randevunun eklendiğini ekranda gösterir
      "Randevu kaydedildi [${seans.seansKodu}] : ${seans.danisan.adSoyad} -> ${seans.islemAdi}",
    );
  }

  void seansiTamamla({required String seansKodu, required OdemeYontemi odeme}) {
    // Named parameter çağırırken hangi değerin ne olduğu daha anlaşılır
    for (var seans in _seanslar) {
      // Aradığımız seansı bulmak için bütün seansları dolaşıyoruz.
      if (seans.seansKodu == seansKodu) {
        // Listedeki seansın kodu aradığımız kod ile aynı mı?
        seans.durum = SeansDurumu.tamamlandi;
        //seans bulununca seans durumu tamamlandı oluyor
        seans.odemeTipi = odeme; //hangi yöntemle ödeme yapıldığı kaydedilir
        print(
          "Seans Tamamlandi: [${seans.seansKodu}]: ${seans.netTutar.toStringAsFixed(2)} tahsil edildi (${odeme.name})",
        );
        return; //seans bulunduktan sonra metotdan çıkılır
      }
    }
    print("Hata [${seansKodu}] kodlu seans bulunamadı");
    //seans bulunmazsa hata mesajı
    return; // metotdan çıkılır
  }

  void seansIptalEt(String seansKodu, {String? iptalNedeni}) {
    //iptal nedeni zorunlu değil String?
    for (var seans in _seanslar) {
      // İptal edilecek seansı bulabilmek için listeyi dolaşıyoruz.
      if (seans.seansKodu == seansKodu) {
        // Listedeki seansın kodu aradığımız kod ile aynı mı?
        seans.durum =
            SeansDurumu.iptalEdildi; //seans bulununca iptal edildi oluoyr
        print(
          "Seans iptal edildi [${seans.seansKodu}] : ${iptalNedeni ?? "Gerekçe belirtilmedi"}",
        ); // İptal nedeni null ise ?? sayesinde "Gerekçe belirtilmedi" yazıyoruz.
      }
      ;
      return; // döngüden metotdan  çıkılır
    }
  }

  //Finansla Rapor Metotları(fonksiyonel dart)
  double get toplamTahsilEdilenCiro => _seanslar
      .where((s) => s.durum == SeansDurumu.tamamlandi)
      //bütn seansları değişl sdece tamamlananlrı almka için where
      .fold(0.0, (toplam, s) => toplam + s.netTutar);
  //filtrelenen seansların net tutarlarını tek toplamda birleştirmek için fold

  double get beklenenPotansiyelCiro => _seanslar
      .where(
        //gelir oluşturabilecek seanslar beklyior işlemde bunları filtreliyoruz
        (s) =>
            s.durum == SeansDurumu.bekliyor ||
            s.durum == SeansDurumu.odadaIslemde,
      )
      .fold(
        0.0,
        (toplam, s) => toplam + s.netTutar,
      ); //filterelenenleri tek toplamda topluyoruz

  // kategori bazlı seans sayıları

  Map<HizmetKategorisi, int> kategoriBazliSeansDagilimi() {
    // Her kategoride kaç seans?
    final Map<HizmetKategorisi, int> dagilim = {};
    // Kategori -> seans sayısı şeklinde veri tutacağımız için Map kullandık.
    for (var kat in HizmetKategorisi.values) {
      // Enum içerisindeki bütün kategorileri dolaşır
      dagilim[kat] = 0; // Başlangıçta her kategorinin seans sayısını 0
    }
    for (var s in _seanslar) {
      // Sistemdeki bütün seansları dolaşır
      dagilim[s.kategori] = (dagilim[s.kategori] ?? 0) + 1;
      // Seansın kategorisinin mevcut sayısını 1 artırır
      // ?? 0 kullandık çünkü herhangi bir nedenle değer bulunamazsa 0 kabul edilir
    }
    return dagilim; //dağılım Map'ini geri döndürür
  }

  Set<String> gorevliUzmanKadrosu() {
    //aynı uzman birden fazla seansta olsa bile listede sadece bir kere görünmeli SET
    return _seanslar
        .map(
          (s) => s.sorumluUzman,
        ) // map ile her seanstan sadece sorumluUzman bilgisi
        .whereType<String>() //whereType<String>() sadece String olan değerler
        .toSet(); // Aynı uzmanların tekrar etmemesi için sonucu Sete çevirir
  }

  //Uzmansız kalan seanslar
  List<SeansKaydi> uzmansizSeanslariGetir() {
    return _seanslar
        .where(
          (s) => s.sorumluUzman == null,
        ) // sorumluUzman değeri null olan seansları filtrele
        .toList(); // where sonucu Iterable olduğu için bunu List'e çeviriyoruz.
    //Iterable = elemanları üzerinde tek tek dolaşılabilen veri yapısı.
  }

  void gunSonuRaporuYazdir() {
    // Gün sonunda bütün seans ve finans bilgilerini konsola yazdırmak için
    print("Günlük Seans ve İşlem Çizelgesi"); // Raporun başlığ
    print("-------------------------------");
    print(
      // Tablo başlıkları padRight kolonların belirli genişlikte olması için
      "${'Kod'.padRight(20)} | "
      "${'Danışan'.padRight(16)} | "
      "${'İşlem'.padRight(20)} | "
      "${'Uzman'.padRight(18)} | "
      "${'Tutar'.padRight(10)} | "
      "${'Durum'} | ",
    );
    print("-------------------------------");

    for (var s in _seanslar) {
      // Bütün seansları rapora yazdırabilmek için listeyi dolaşıyoruz.
      final String uzman =
          s.sorumluUzman ??
          "Nöbetçi bekliyor"; //uzman null olabilir atanmamışsa nöbetçi bekleniyor yazar
      final String durumRozet = switch (s.durum) {
        SeansDurumu.tamamlandi => "Tamamlandı",
        SeansDurumu.odadaIslemde => "İşlemde",
        SeansDurumu.bekliyor => "Bekliyor",
        SeansDurumu.iptalEdildi => "İptal",
      }; //seans durumunu kullanıcıya metin olarak gösterir
      print(
        // Seansın bütün bilgilerini tablo şeklinde yazar
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
      // getter sayesinde tamamlanmış seansların toplam gelirini yazar
      " * Gerçekleşen (kasadaki net cire) : ${toplamTahsilEdilenCiro.toStringAsFixed(2)}", // .toStringAsFixed(2) sayıyı 2 ondalık basamakla yazıya çevirir.
    );
    print(
      // getter sayesinde beklenen toplam gelirini yazar
      " * Bekleyen Potansiyel Alacak : ${beklenenPotansiyelCiro.toStringAsFixed(2)}",
    );
    print(
      " * Toplam Seeans : ${_seanslar.length} Randevu",
    ); //lisitede toplam kaç seans var?

    print("--------------------------");
    print("Aktif Uzmanlar");
    final uzmanlar = gorevliUzmanKadrosu();
    // Uzman listesini tekrar tekrar hesaplamamak için değişkene alır

    if (uzmanlar.isEmpty) {
      print("Kayıtlı uzman bulunamadı"); //uzamnlar listesi boşsa ekrana yazar
    } else {
      print(
        "${uzmanlar.join(', ')}",
      ); //uzman varsa isimler virgülle birlşetirilip yazılır
    }

    final uzmansizlar = uzmansizSeanslariGetir();
    // Uzman atanmamış seansları getirir

    if (uzmansizlar.isNotEmpty) {
      print(
        "Dikkat: ${uzmansizlar.length} adet seansa henüz uzman atanmamıştır", //liste boş değilse bu kadar seansa uzman atanmadığı bildirilir
      );
      for (var u in uzmansizlar) {
        //hangi seanslar uzman atanmadığını tek tek göstermek için
        print(
          "->[${u.seansKodu}] ${u.danisan.adSoyad} (${u.islemAdi})",
        ); // Seans kodu, danışan ve işlem bilgisini yazdırr
      }
    }
    print("--------------------------");
  }
}

void main() {
  // Programın çalışmaya başladığı ana nokta
  print(
    "Kliik yönetim sistemi başlatılıyor....",
  ); // Programın başladığını konsolda görmek için
  final yonetici = KlinikYoneticisi(subeAdi: "Sofİto Bğcılar Şubesi");
  // Klinik işlemlerini yönetebilmek için KlinikYoneticisi class'ından nesne oluşturldu
  //final çünkü değişkene sonrada başka nesne atamayacğız

  //danışanlar
  //4 tane danışan oluşturduk
  final d1 = Danisan(
    id: "DAN-101", //farklı idler birbirnden ayırmak için
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

  //oluşturulan danışanlar yöneticiin rehberine kaydedilir
  yonetici.danisanKaydet(d1);
  yonetici.danisanKaydet(d2);
  yonetici.danisanKaydet(d3);
  yonetici.danisanKaydet(d4);

  print("Danışan güvenlik kontrolü");
  //bilgiözeti getter kullandıık danışanın özet bilgiis yazılır
  print(d1.bilgiOzeti);
  print(d2.bilgiOzeti);
  print("------------------------");

  //randevu oluşturma

  //4 tane seans kaydı oluştu
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

  //seanslar yönetim sistemindeki listeye eklneri
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
  //seans 4 iptal iptal nedeni opsiyonelparametre üzerinden gönderilir
  yonetici.seansIptalEt(
    "SNS-2026-4",
    iptalNedeni: "Danışanın misafiri var o yüzden gelemz",
  );

  yonetici
      .gunSonuRaporuYazdir(); //büün işlemler bittikten sonra gün sonu raporu konsola yazılır
}
