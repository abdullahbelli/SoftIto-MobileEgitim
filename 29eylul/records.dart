//dart record ve api durum kontrolü
//({String nodeAdi, int statusCode, double latencyMs, bool baglantiBasarili}) fonksiyonun dönüş tipi Yani fonksiyon tek bir String ya da int döndürmüyor. Birden fazla değeri tek pakette döndürüyor. Bu yapıya Dart’ta Record denir
({String nodeAdi, int statusCode, double latencyMs, bool baglantiBasarili})
sunucuPingAt({required String hedefIP}) {
  //sunucuPingAt fonksiyon adı
  final double gecikme = 24.8;
  final int kod = 200;

  return (
    nodeAdi: "edge-router-ist-$hedefIP",
    statusCode: kod,
    latencyMs: gecikme,
    baglantiBasarili: kod == 505, //burada bir true false kontrolü yapıyor
  );
}

void main() {
  print("Dart Record Kayıtları");
  final probeSunucu = sunucuPingAt(hedefIP: "10.0.1.50");
  print("IP adı            : ${probeSunucu.nodeAdi}");
  print("Http kodu         : ${probeSunucu.statusCode}");
  print("Gecikme süresi    : ${probeSunucu.latencyMs}");
  print(
    "Ağ durumu         : ${probeSunucu.baglantiBasarili ? "Stabil" : "Kopuk"}",
  );

  //Tek hamlede değişkenlere parçalama
  final (:nodeAdi, :statusCode, :latencyMs, :baglantiBasarili) = probeSunucu;
  print("Değişkenler -> $nodeAdi [Kod: $statusCode,Gecikme: ${latencyMs}ms ]");

  final (String podID, int cpuCores, double ramGb) = ("k8s-pod-77x", 8, 32.0);
  print("Pod Özeti: $podID | Çekirdek: $cpuCores | Ram: ${ramGb} GB");
}
