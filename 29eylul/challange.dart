// Bir bulut kümesinde çalışan servislerin isimlerini içeren bir Set<String> tanımlayın (mükerrer kayıtları elemek için). Ardından bir boolean bool isProduction = true; bayrağı tanımlayın. Eğer ortam prodüksiyon ise listeye "vault-secret-manager" servisini Collection if ile ekleyen ve tüm servisleri içeren bir List<String> oluşturup ekrana yazdırın.
void main() {
  print("Çalışan Servisler");

  final Set<String> calisanServisler = {
    "auth-service",
    "payment-service",
    "user-service",
  };

  final bool isProduction = true;

  final List<String> tumServisler = [
    ...calisanServisler, //spread ...

    if (isProduction) "vault-secret-manager", //collection if
  ];
  print("Tüm servisler $tumServisler");
}
