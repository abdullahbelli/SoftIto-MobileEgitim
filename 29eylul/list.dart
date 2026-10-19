void main() {
  final List<String> aktifMikroservisler = [
    "auth-service:v2.1",
    "gateway-service:v1.9",
    "payment-processor:v3.0",
  ];
  aktifMikroservisler.add("telemetry-collector:v1.0");
  print(
    "Aktif servisler (${aktifMikroservisler.length} adet) adet: $aktifMikroservisler ",
  );

  //sabit uzunluktaki liste(fixed-length)
  final List<String> cekirdekYukDengegeleyiciler = List.filled(
    4,
    "\nPort-Kapalı",
    growable: false,
  );
  cekirdekYukDengegeleyiciler[0] = "\nLB-NODE-01; 192.168.1.10 (Online)";
  cekirdekYukDengegeleyiciler[1] = "\nLB-NODE-02; 192.168.1.11 (Online)";
  //cekirdekYukDengegeleyiciler.add("LB-NODE-05"); // HATA:FİXED-LENGTH LİSTEYE ELEMAN EKLENEMEZ
  print("Çekirdek Yük Dengleyeici Portları: $cekirdekYukDengegeleyiciler");

  //Programatik List Üretici
  final List<String> kubernetesPortlari = List.generate(
    3,
    (index) => "pod-node-eu-west-${index + 1} [Ram:16GB , CPU:4 Cores]",
  );
  print("Oluşturulan K8s Podları:$kubernetesPortlari");

  //Değiştirilemez List
  final List<String> guvenlikDuvariPortlari = List.unmodifiable([
    "22/TCP (SSH)",
    "443/TCP (HTTPS)",
    "6443/TCP (K8s-API)",
  ]);

  // guvenlikDuvariPortlari[0] = "80/TCP"; //HATA CANNOT MODIFY AN UNMODIFIBLE LIST
  print("Güvenlik duvarı korumalı portlar: $guvenlikDuvariPortlari");
}
