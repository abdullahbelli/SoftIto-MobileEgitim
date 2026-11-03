//Mğlakat için önemli: Sealed sınıflar dışarıdan extend edilmez. Switch içinde tüm alt sınıflar üketilmek zorundaır.

// sealed: Sınıfın yalnızca aynı kütüphane içinden genişletilmesini sağlar
sealed class OdemeDurumu {} // Başarılı ve başarısız ödeme sonuçlarının ortak üst sınıfı

class OdemeBasaili extends OdemeDurumu {
  // Başarılı ödeme sonucunu temsil eden alt sınıf
  final ({String referansKodu, double tutar})
  veri; // Referans kodu ve tutarı isimlendirilmiş record içinde saklar
  OdemeBasaili(this.veri); // Ödeme bilgilerini constructor aracılığıyla alır
}

class OdemeBasarisiz extends OdemeDurumu {
  // Başarısız ödeme sonucunu temsil eden alt sınıf
  final String hataNedeni; // Ödemenin neden başarısız olduğunu saklar
  OdemeBasarisiz(
    this.hataNedeni,
  ); // Hata nedenini constructor aracılığıyla alır
}

abstract class IBankaServisi {
  // Banka servislerinin uyması gereken ortak sözleşme
  Future<OdemeDurumu> odeme({required double miktar}); // Asenkron ödeme işleminin başarılı veya başarısız sonuç döndürmesini zorunlu kılar
}

mixin GuvenlikDenetmiMixin {
  // Farklı sınıflara tekrar kullanılabilir token kontrolü özelliği
  bool tokenGecerliMi(String token) {
    // Token uzunluğunu kontrol ederek geçerlilik sonucunu döndürür
    return token.isNotEmpty &&
        token.length >=
            10; // Token boş değilse ve en az 10 karakterse true döndürür
  }
}

mixin AuditLogMixin {
  // Sınıflara işlem kayıtlarını tutma özelliği kazandırır
  void islemKaydet(String mesaj) {
    // İşlem mesajını tarih ve saat bilgisiyle konsola yazar
    final zaman = DateTime.now()
        .toIso8601String(); // Güncel zamanı ISO 8601 metin formatına dönüştürür
    print(
      'Log - $zaman: $mesaj',
    ); // İşlem zamanını ve mesajını konsola yazdırır
  }
}

class GarantiBankasiServisi
    with GuvenlikDenetmiMixin, AuditLogMixin
    implements IBankaServisi {
  // Banka sözleşmesini uygular ve güvenlik ile loglama özelliklerini kullanır
  final String apiAnahtari; // Servisin kimlik doğrulamasında kullanacağı API anahtarını saklar

  GarantiBankasiServisi({
    required this.apiAnahtari,
  }); // Servis oluşturulurken API anahtarı girilmesini zorunlu kılar

  @override // IBankaServisi içinde tanımlanan ödeme metodunu uygular (ezer)
  Future<OdemeDurumu> odeme({required double miktar}) async {
    // Verilen tutar için asenkron ödeme işlemini başlatır
    if (!tokenGecerliMi(apiAnahtari)) {
      // API anahtarının belirlenen güvenlik koşullarını sağlayıp sağlamadığını kontrol eder
      islemKaydet(
        'Odeme Reddedildi. Geçersiz Api Anahtari',
      ); // Geçersiz anahtar nedeniyle reddedilen işlemi kaydeder
      return OdemeBasarisiz(
        'Yetkilendirme hatası: Geçersiz Token',
      ); // Hata nedenini içeren başarısız ödeme sonucu döndürür
    }

    await Future.delayed(const Duration(milliseconds: 1000)); // Gerçek hayatı ( gerçek api isteği senaryosu) taklit etmek için işlemi 1 saniye bekletir

    islemKaydet(
      '$miktar tutarındaki ödeme Garanti Banksaı tarafında ONAYLANDI',
    ); // Onaylanan ödemeyi konsola kaydeder

    return OdemeBasaili((
      referansKodu: 'GRNT - ${DateTime.now().millisecondsSinceEpoch}',
      tutar: miktar,
    )); // Referans kodu ve tutarı içeren başarılı ödeme sonucu döndürür
  }
}

void odemeSonucunuEkranaBas(OdemeDurumu durum) {
  // Ödeme sonucunun türüne göre kullanıcıya gösterilecek mesajı belirler
  final mesaj = switch (durum) {
    // Ödeme nesnesinin alt sınıfına göre uygun mesajı seçer
    OdemeBasaili b =>
      'Odeme Basarili. Ref : ${b.veri.referansKodu} , Tutar: ${b.veri.tutar} ₺', // Başarılı ödemede referans kodunu ve tutarı gösterir
    OdemeBasarisiz h => 'Ödeme Başarısız. Gerekçe : ${h.hataNedeni}', // Başarısız ödemede hata nedenini gösterir
  };
  print(mesaj); // Oluşturulan sonuç mesajını konsola yazar
}

void main() {
  // Programın çalışmaya başladığı ana metot
  GarantiBankasiServisi(apiAnahtari: "G_123456789")
      .odeme(miktar: 250.0)
      .then((durum) => odemeSonucunuEkranaBas(durum)); // Banka servisi oluşturur, 250 TL ödeme simülasyonu yapar ve sonuç tamamlandığında ekrana yazdırır
}
