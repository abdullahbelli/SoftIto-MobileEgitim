enum CihazTipi {
  //cihaz tiplerini belirli seçeneklerle tutmak için enum kullanır yazım hatalarını azaltır ve kod daha güvenli olur
  sensor,
  gateway,
  edgeServer,
  router,
} //1. Cihaz Tiplerini Oluşturun

//2. IoTCihaz Sınıfını Oluşturun
class IoTCihaz {
  //aynı yapıya sahip nesneler oluşturmak içn class kullanılır yani iot ağındaki cihazların ortak özellikleri tek bir model altında toplandı
  final String seriNo;
  final String cihazAdi;
  final CihazTipi tip; //chiazın hangi türde olduğu enumdan geliyor
  final double cpuYukYuzdesi;
  final int bellekMB;
  final Set<String> acikPortlar; //set aynı elemanın tekrar bulunmasını engeller
  final bool sslSertifikasiGecerliMi;
  final bool acikMi;

  const IoTCihaz({
    //Constructor, yeni bir IoTCihaz oluştururken değerleri sınıfın değişkenlerine aktarıyor.
    required this.seriNo, //zorunlu değerler required
    required this.cihazAdi,
    required this.tip,
    required this.cpuYukYuzdesi,
    required this.bellekMB,
    required this.acikPortlar,
    this.sslSertifikasiGecerliMi = false, //değer verilmezse oto false olacak
    this.acikMi = true, //değişik bir durum yoksa oto true olacak
  });

  bool get guvenlikAcigiVarMi => //
      !sslSertifikasiGecerliMi ||
      acikPortlar.contains(
        "23/TELNET",
      ); //.contains acikPortların içerisinde var mı?
} //! boolean değeri tersine çevirir.

//6. Seri Numarasına Göre Cihaz Bulma
//seri numarasına göre cihaz arayan fonksiyon
//record birden falza bilgyi tek seferde döndürebilir
({String seriNo, String cihazAdi, CihazTipi tip, bool alarmDurumu})? cihazBul(
  //cihaz bulunamama durumu için ? ile nullable yaptım
  List<IoTCihaz> cihazlar, //hangi listede arama yapılacak
  String seriNo,
) {
  final bulunanCihazlar = cihazlar.where((c) => c.seriNo == seriNo);

  if (bulunanCihazlar.isEmpty) {
    print("Bu seri numarasına ait cihaz bulunamadı: $seriNo");
    return null; //eğer bulunamazsa null dönsün ve fonksiyondan çıksın
  }

  final cihaz = bulunanCihazlar
      .first; //where birden fazla sonuç içerebilen bi yapı döner first ilk eşleşeni alır

  return (
    seriNo: cihaz.seriNo,
    cihazAdi: cihaz.cihazAdi,
    tip: cihaz.tip,
    alarmDurumu: cihaz.guvenlikAcigiVarMi || cihaz.cpuYukYuzdesi > 85.0,
  );
}

//7. Cihaz Tipine Göre İzolasyon Bölgesi
String tipBolgeAtama(CihazTipi tip) {
  return switch (tip) {
    CihazTipi.sensor => "ZONE-S",
    CihazTipi.gateway => "ZONE-G",
    CihazTipi.edgeServer => "ZONE-E",
    CihazTipi.router => "ZONE-R",
  };
}

//8. Cihaz Erişilemiyorsa Exception Fırlatın
class CihazErisilemezException implements Exception {
  //kendi hata türünü oluşturma implements exception bu sınıfın bir hata türü olarak kullanılacağına söyler
  final String mesaj;
  CihazErisilemezException(this.mesaj);

  @override
  String toString() => mesaj;
  //exception ekrana yazdırıldığında kendi hata mesajımızın görünmesi için toString metodunu override edilir
}

// Cihaza bağlanmayı deneyen metot
void cihazaBaglan(IoTCihaz cihaz) {
  // Cihaz kapalıysa hata fırlatıyoruz
  if (!cihaz.acikMi) {
    throw CihazErisilemezException(
      //throw ile fırlatılaan hata try catch ile yakalanabilir
      "${cihaz.cihazAdi} cihazına erişilemiyor. Cihaz kapalı.",
    );
  }
  print("${cihaz.cihazAdi} cihazına başarıyla bağlanıldı.");
}

void main() {
  //3. Cihazları Oluşturun
  final List<IoTCihaz> cihazlar = [
    IoTCihaz(
      seriNo: "SN001",
      cihazAdi: "Sicaklik Sensoru",
      tip: CihazTipi.sensor,
      cpuYukYuzdesi: 35.5,
      bellekMB: 512,
      acikPortlar: {"80/HTTP", "443/HTTPS"},
      sslSertifikasiGecerliMi: true,
    ),

    IoTCihaz(
      seriNo: "SN002",
      cihazAdi: "Ana Gateway",
      tip: CihazTipi.gateway,
      cpuYukYuzdesi: 72.3,
      bellekMB: 1024,
      acikPortlar: {"443/HTTPS", "23/TELNET"},
      sslSertifikasiGecerliMi: true,
    ),

    IoTCihaz(
      seriNo: "SN003",
      cihazAdi: "Edge Server 1",
      tip: CihazTipi.edgeServer,
      cpuYukYuzdesi: 91.5,
      bellekMB: 4096,
      acikPortlar: {"443/HTTPS", "22/SSH"},
      sslSertifikasiGecerliMi: true,
    ),

    IoTCihaz(
      seriNo: "SN004",
      cihazAdi: "Ana Router",
      tip: CihazTipi.router,
      cpuYukYuzdesi: 45.8,
      bellekMB: 2048,
      acikPortlar: {"80/HTTP", "443/HTTPS"},
      sslSertifikasiGecerliMi: false,
    ),

    IoTCihaz(
      seriNo: "SN005",
      cihazAdi: "Nem Sensoru",
      tip: CihazTipi.sensor,
      cpuYukYuzdesi: 25.4,
      bellekMB: 256,
      acikPortlar: {"443/HTTPS"},
      sslSertifikasiGecerliMi: true,
    ),

    IoTCihaz(
      seriNo: "SN006",
      cihazAdi: "Yedek Gateway",
      tip: CihazTipi.gateway,
      cpuYukYuzdesi: 88.7,
      bellekMB: 1024,
      acikPortlar: {"443/HTTPS"},
      sslSertifikasiGecerliMi: true,
      acikMi: false,
    ),
  ];

  //4. Riskli Cihazları Bulun

  final riskliCihazlar = cihazlar
      .where((c) => c.guvenlikAcigiVarMi || c.cpuYukYuzdesi > 85.0)
      .toList();
  print("--------------------------------------");
  print("Riskli cihazlar bulundu:");
  for (var cihaz in riskliCihazlar) {
    // riskli cihazlar listesindeki her cihazı sırayla dolaşıp ekrana yazar
    print("${cihaz.cihazAdi}  -  CPU:%${cihaz.cpuYukYuzdesi}");
  }

  //5. Toplam Bellek Kullanımını Hesaplayın

  final toplamBellekKullanimi = cihazlar.fold(
    0,
    (toplam, cihaz) => toplam + cihaz.bellekMB,
  );
  print("Toplam Bellek Kullanımı: $toplamBellekKullanimi MB");

  //6. Seri Numarasına Göre Cihaz Bulma
  final arananSeriNo = "SN999";
  final bulunanCihaz = cihazBul(cihazlar, arananSeriNo);
  print("--------------------------------------");
  if (bulunanCihaz != null) {
    print("--------------------------------------");
    print("Aranan Cihaz: ${bulunanCihaz.seriNo}");
    print("Cihaz Adı: ${bulunanCihaz.cihazAdi}");
    print("Cihaz Tipi: ${bulunanCihaz.tip}");
    print("Alarm Durumu: ${bulunanCihaz.alarmDurumu}");
  }

  //7. Cihaz Tipine Göre İzolasyon Bölgesi
  print("Sensor  : ${tipBolgeAtama(CihazTipi.sensor)}");
  print("Gateway : ${tipBolgeAtama(CihazTipi.gateway)}");
  print("EdgeServer : ${tipBolgeAtama(CihazTipi.edgeServer)}");
  print("Router : ${tipBolgeAtama(CihazTipi.router)}");

  //8. Cihaz Erişilemiyorsa Exception Fırlatın
  print("--------------------------------------");
  print("Cihaza bağlantı deneniyor...");

  final baglanilacakCihaz = cihazlar.where((c) => c.seriNo == "SN006").first;

  try {
    cihazaBaglan(
      baglanilacakCihaz,
    ); //try ile buradakini çalıştır eğer bir hata varsa aşağıdaki catch bloklarına git oradaki çıktıyı yaz
  } on CihazErisilemezException catch (e) {
    //sadece CihazErisilemezException türündeki hataları burada yakalar
    print("Cihaz erişim hatası yakalandı.");
    print("Hata: ${e.mesaj}");
  } catch (e) {
    print("Bilinmeyen bir hata oluştu: $e");
  } finally {
    //hata olsa da olmasa da çalışır
    print("Cihaz bağlantı işlemi tamamlandı.");
  }
}
