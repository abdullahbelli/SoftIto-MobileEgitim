// LİSKOV İHLALİ:  kare - dikdörtgen gibi burada da kargoUcretiHesapla DijitalUrunu' e Urun dediğimiz içimn sorun yaratır. alt sınıf üst sınıfın yerini alamaz.
//class Urun {
//   String id;
//   String ad;
//   double fiyat;
//   int stok;
//   String tip;

//   Urun(this.id, this.ad, this.fiyat, this.stok, this.tip);

//   double kargoUcretiHesapla() {
//     return 29.90;
//   }
// }

// class DijitalUrun extends Urun {
//   DijitalUrun(String id, String ad, double fiyat, int stok)
//       : super(id, ad, fiyat, stok, "DIJITAL");

//   @override
//   double kargoUcretiHesapla() {
//     throw Exception("Dijital urunlerde kargo hesaplanamaz!");
//   }
// }

class Urun {
    String id;
    String ad;
    double fiyat;
    int stok;
    String tip;

    Urun(this.id, this.ad, this.fiyat, this.stok, this.tip);
}

abstract class Kargolanabilir {
    double kargoUcretiHesapla();
}

class FizikselUrun extends Urun implements Kargolanabilir{
    FizikselUrun(String id, String ad, double fiyat, int stok)
      : super(id, ad, fiyat, stok, "FIZIKSEL");

    
    @override
    double kargoUcretiHesapla() {
        return 29.90;
    }
}

class DijitalUrun extends Urun {
    DijitalUrun(String id, String ad, double fiyat, int stok)
        : super(id, ad, fiyat, stok, "DIJITAL");
}


// ISP İHLALİ çok fazla farklı işlem tek interface içinde toplanmış.
// abstract class ISiparisIslemleri {
//   void siparisKaydet(String orderId, double tutar);
//   void odemeYap(String tip, double tutar);
//   void kargoGonder(String orderId, String adres);
//   void mailGonder(String email, String mesaj);
//   void smsGonder(String tel, String mesaj);
//   void faturaYazdir(String orderId);
// }

abstract class ISiparisKaydedici {
    void siparisKaydet(String orderId, double tutar);
}

abstract class IOdemeServisi{
    void odemeYap(double tutar);
}

class KrediKartiOdemesi implements IOdemeServisi{
    @override
    void odemeYap(double tutar) => print("$tutar TL Kredi kartindan POS ile cekildi.");
}

class HavaleOdemesi implements IOdemeServisi{
    @override
    void odemeYap(double tutar) => print("$tutar TL Havale kontrol edildi.");
}

class KapidaOdemeOdemesi implements IOdemeServisi{
    @override
    void odemeYap(double tutar) => print("$tutar TL Kapida odeme tahsil edilecek (Komisyon +15 TL).");
}

class KriptoOdemesi implements IOdemeServisi{
    @override
    void odemeYap(double tutar) => print("$tutar TL USDT transferi onaylandi.");
}

abstract class IKargoServisi{
    void kargoGonder(String orderId, String adres);
}

abstract class IMailServisi{
    void mailGonder(String email, String mesaj);
}

abstract class ISmsServisi{
    void smsGonder(String tel, String mesaj);
}

abstract class IFaturaServisi{
    void faturaYazdir(String orderId);
}

abstract class IKuponServisi{
    double indirimYap(double toplam);
}

class Indirim10Kuponu implements IKuponServisi{
    @override
    double indirimYap(double toplam) => toplam * 0.90;
}

class Yaz20Kuponu implements IKuponServisi{
    @override
    double indirimYap(double toplam) => toplam * 0.80;
}

class Sepette50Kuponu implements IKuponServisi{
    @override
    double indirimYap(double toplam) {
        return toplam >= 50 ? toplam - 50 : 0;
    }
}


class SqliteVeritabani {
    void kaydet(String sql) {
        print("DB calistirildi: " + sql);
    }
}

class SmtpMailServisi {
    void mailAt(String to, String body) {
        print("SMTP Mail gonderildi: " + to);
    }
}

class NetgsmSmsServisi {
    void smsYolla(String gsm, String text) {
        print("SMS iletildi: " + gsm);
    }
}


class SiparisKaydediciServis implements ISiparisKaydedici {
    SqliteVeritabani db = SqliteVeritabani();

    @override
    void siparisKaydet(String orderId, double tutar) {
        db.kaydet("INSERT INTO siparisler VALUES ('$orderId', $tutar)");
    }
}

class KargoServis implements IKargoServisi {
    @override
    void kargoGonder(String orderId, String adres) {
        print("MNG Kargo takip fis basildi: $adres");
    }
}

class MailServis implements IMailServisi {
    SmtpMailServisi mailci = SmtpMailServisi();

    @override
    void mailGonder(String email, String mesaj) {
        mailci.mailAt(email, mesaj);
    }
}

class SmsServis implements ISmsServisi {
    NetgsmSmsServisi smsci = NetgsmSmsServisi();

    @override
    void smsGonder(String tel, String mesaj) {
        smsci.smsYolla(tel, mesaj);
    }
}

class FaturaServis implements IFaturaServisi {
    @override
    void faturaYazdir(String orderId) {
        print("Fatura PDF cikarildi: $orderId");
    }
}

//SRP İHLALİ Bu sınıf ödeme kargo mail vb. birden fazla sorumluluk stlenmiş.
class SiparisYoneticisi  {
    // DIP İHLAİ veritabanı, mail ve SMS servislerinin somut sınıflarını doğrudan oluşturuyor.
    final ISiparisKaydedici kaydedici;
    final IKargoServisi kargoServis;
    final IMailServisi mailServis;
    final ISmsServisi smsServis;
    final IFaturaServisi faturaServis;

    SiparisYoneticisi(
        this.kaydedici,
        this.kargoServis,
        this.mailServis,
        this.smsServis,
        this.faturaServis,
    );

//   @override
//   void siparisKaydet(String orderId, double tutar) {
//     db.kaydet("INSERT INTO siparisler VALUES ('$orderId', $tutar)");
//   }

// // OCP İHLALİ yeni bir ödeme tipi eklendiğinde odemeYap() metodu değiştirilimek zzorunda kalıyor. 
// //   @override
// //   void odemeYap(String tip, double tutar) {
// //     if (tip == "KREDI_KARTI") {
// //       print("$tutar TL Kredi kartindan POS ile cekildi.");
// //     } else if (tip == "HAVALE") {
// //       print("$tutar TL Havale kontrol edildi.");
// //     } else if (tip == "KAPIDA_ODEME") {
// //       print("$tutar TL Kapida odeme tahsil edilecek (Komisyon +15 TL).");
// //     } else if (tip == "CRYPTO") {
// //       print("$tutar TL USDT transferi onaylandi.");
// //     } else {
// //       print("Gecersiz odeme yontemi");
// //     }
// //   }

    

//   @override
//   void kargoGonder(String orderId, String adres) {
//     print("MNG Kargo takip fis basildi: $adres");
//   }

//   @override
//   void mailGonder(String email, String mesaj) {
//     mailci.mailAt(email, mesaj);
//   }

//   @override
//   void smsGonder(String tel, String mesaj) {
//     smsci.smsYolla(tel, mesaj);
//   }

//   @override
//   void faturaYazdir(String orderId) {
//     print("Fatura PDF cikarildi: $orderId");
//   }

    void siparisTamamla(
        String orderId,
        List<Urun> sepet,
        //String odemeTipi,
        IOdemeServisi odemeStratejisi,
        String musteriAdi,
        String email,
        String tel,
        String adres,
        //String kuponKodu
        IKuponServisi kuponStratejisi) {
        
        double toplam = 0;
        bool kargolanacakUrunVar = false;

        for (var i = 0; i < sepet.length; i++) {
        if (sepet[i].stok <= 0) {
            print("Hata: " + sepet[i].ad + " tukenmis!");
            return;
        }
        toplam += sepet[i].fiyat;
        if (sepet[i] is Kargolanabilir) {
            toplam += (sepet[i] as Kargolanabilir).kargoUcretiHesapla();
            kargolanacakUrunVar = true;
            }
        sepet[i].stok--;
        }

        // OCP İHLALİ yeni bir kuopn eklendiğinde if else yapısı değitirlmek zoruna kalıyor
        // if (kuponKodu == "INDIRIM10") {
        //   toplam = toplam * 0.90;
        // } else if (kuponKodu == "YAZ20") {
        //   toplam = toplam * 0.80;
        // } else if (kuponKodu == "SEPETTE50") {
        //   toplam = toplam - 50;
        // }

        // double kdv = toplam * 0.20;
        // double sonTutar = toplam + kdv;

        // daha kısa yazılabilir ama anlaşılırlık açısından zorluk yaratabilir.
        toplam = kuponStratejisi.indirimYap(toplam);
        double sonTutar = toplam * 1.20;
        

        odemeStratejisi.odemeYap(sonTutar);
        kaydedici.siparisKaydet(orderId, sonTutar);
        faturaServis.faturaYazdir(orderId);
        mailServis.mailGonder(email, "Sayin $musteriAdi, siparisiniz alindi. Tutar: $sonTutar TL");
        smsServis.smsGonder(tel, "Siparisiniz onaylandi: $orderId");
        if (kargolanacakUrunVar) {
            kargoServis.kargoGonder(orderId, adres);
        }
    }
}

void main() {
    var siparisci = SiparisYoneticisi(
        SiparisKaydediciServis(),
        KargoServis(),
        MailServis(),
        SmsServis(),
        FaturaServis(),
    );

    var urun1 = FizikselUrun("1", "Kablosuz Mouse", 450.0, 5);
    var urun2 = DijitalUrun("2", "Flutter Kursu E-Kitap", 150.0, 100);

    var sepet = <Urun>[urun1, urun2];

    siparisci.siparisTamamla(
        "SP-9921",
        sepet,
        //"KREDI_KARTI",
        KrediKartiOdemesi(),
        "Selahaddin",
        "selahaddin@kodvance.com",
        "05551112233",
        "Kadikoy / Istanbul",
        // "INDIRIM10",
        Indirim10Kuponu(),
    );
}