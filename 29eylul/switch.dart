enum OlaySeviyesi { info, warning, error, critical }

String alarmaKanaliniBelirle(OlaySeviyesi seviye, int tekrarSayisi) {
  return switch (seviye) {
    OlaySeviyesi.info => "dev-logs",
    OlaySeviyesi.warning => "dev-warning",
    OlaySeviyesi.error when tekrarSayisi >= 5 =>
      "Sms veya Email (mükerrer hata)",
    OlaySeviyesi.error => "Email:dev@sit.com",
    OlaySeviyesi.critical => "ACİL DURUM:Kriz odası otomatik node kapanışı",
  };
}

String httpKoduYorumla(int kod) {
  return switch (kod) {
    >= 200 && < 300 => "2xx Başarılı İstek",
    >= 400 && < 500 => "4xx İstemci Hatası (client error)",
    >= 500 && < 600 => "5xx Sunucu hatası (internal server error)",
    _ => "Tanımsız Hata Kodu",
  };
}

void main() {
  print("Swiitch Exporressions");
  print("Warning Kanalı ${alarmaKanaliniBelirle(OlaySeviyesi.warning, 1)}");
  print("Tekli Error Kanalı ${alarmaKanaliniBelirle(OlaySeviyesi.error, 2)}");
  print(
    "5 Kez Tekrarlanan Error Kanalı ${alarmaKanaliniBelirle(OlaySeviyesi.error, 5)}",
  );
  print("Kritik Kanalı ${alarmaKanaliniBelirle(OlaySeviyesi.critical, 1)}");

  print("HTTP 204 : ${httpKoduYorumla(204)}");
  print("HTTP 404 : ${httpKoduYorumla(404)}");
  print("HTTP 502 : ${httpKoduYorumla(502)}");
}
