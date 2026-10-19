class SunucuMetrigi {
  final String hostAdi;
  final String bolge;
  final double cpuYuzdesi;
  final double ramGB;
  final int aktifBaglantiSayisi;
  final bool kritikMi;

  const SunucuMetrigi({
    required this.hostAdi,
    required this.bolge,
    required this.cpuYuzdesi,
    required this.ramGB,
    required this.aktifBaglantiSayisi,
    this.kritikMi = false,
  });

  @override
  String toString() =>
      "$hostAdi [$bolge] (CPU: %$cpuYuzdesi , Ram: ${ramGB}GB ,Conn: $aktifBaglantiSayisi )";
}

void main() {
  print("Cloud Temelleri");

  final List<SunucuMetrigi> sunucuKumesi = [
    SunucuMetrigi(
      hostAdi: "srv-eu-01",
      bolge: "eu-west",
      cpuYuzdesi: 45.2,
      ramGB: 16.0,
      aktifBaglantiSayisi: 1200,
      kritikMi: true,
    ),
    SunucuMetrigi(
      hostAdi: "srv-eu-02",
      bolge: "eu-west",
      cpuYuzdesi: 88.5,
      ramGB: 32.0,
      aktifBaglantiSayisi: 4500,
      kritikMi: true,
    ),
    SunucuMetrigi(
      hostAdi: "srv-us-01",
      bolge: "us-east",
      cpuYuzdesi: 22.0,
      ramGB: 8.0,
      aktifBaglantiSayisi: 450,
      kritikMi: false,
    ),
    SunucuMetrigi(
      hostAdi: "srv-us-02",
      bolge: "eu-west",
      cpuYuzdesi: 94.6,
      ramGB: 64.0,
      aktifBaglantiSayisi: 8900,
      kritikMi: true,
    ),
    SunucuMetrigi(
      hostAdi: "srv-ap-01",
      bolge: "ap-south",
      cpuYuzdesi: 62.4,
      ramGB: 16.0,
      aktifBaglantiSayisi: 2000,
      kritikMi: false,
    ),
  ];

  //where() ile filtreleme: cpu kulanım %80 üzerinde olan sunucular
  final asiriYukluSunucular = sunucuKumesi
      .where((s) => s.cpuYuzdesi >= 80.0)
      .toList();
  print("Aşırı Yüklüü Sunucular (${asiriYukluSunucular.length})");
  asiriYukluSunucular.forEach((s) => print("* $s"));

  //map() ile dönüştürme. Sunucu adlarını ve bağlantı sayılarını alarm etiketine çevrime

  final List<String> alarmEtiketleri = sunucuKumesi
      .map(
        (s) =>
            "[Alert-Monitor] ${s.hostAdi.toUpperCase()}->Aktif Trafik ${s.aktifBaglantiSayisi}",
      )
      .toList();
  print("Alarm çıktıları (ilk 3 tane)");
  alarmEtiketleri.take(3).forEach((e) => print(" $e"));

  //fold()ile toplam aktfi trafik
  final int toplamBaglantiSayisi = sunucuKumesi.fold(
    0,
    (toplam, sunucu) => toplam + sunucu.aktifBaglantiSayisi,
  );
  print("Toplam Bağlantı: $toplamBaglantiSayisi");

  //every() ve any()
  final bool tumSunucularCalisiyorMu = sunucuKumesi.every(
    (s) => s.ramGB >= 8.0,
  );
  final bool tehlikleliSunucuVarMi = sunucuKumesi.any(
    (s) => s.cpuYuzdesi >= 90.0,
  );
  print(
    "Tüm sunucuların Ram i en az 8 GB mi? : ${tumSunucularCalisiyorMu ? "Evet" : "Hayır"}",
  );
  print(
    "Cpu kullanımı %90 ı aşan var mı? : ${tehlikleliSunucuVarMi ? "Evet" : "Hayır"}",
  );

  final euWestSunuculari = sunucuKumesi
      .where((s) => s.bolge == "eu-west" && s.kritikMi)
      .toList();
  final double euWestOrtalamaCpu =
      euWestSunuculari
          .map((s) => s.cpuYuzdesi)
          .fold(0.0, (acc, cpu) => acc + cpu) /
      euWestSunuculari.length;
  print(
    "Eu West BÖlgesi Kritik Sunucu ortalama CPU: ${euWestOrtalamaCpu.toStringAsFixed(2)} ",
  );
}
