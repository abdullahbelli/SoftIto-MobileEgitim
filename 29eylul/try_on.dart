class Cloud implements Exception {
  final String hataKodu;
  final String mesaj;
  final DateTime zaman = DateTime.now();

  Cloud(this.hataKodu, this.mesaj);

  @override
  String toString() => "[$hataKodu] $mesaj ($zaman)";
}

class CpuOverload extends Cloud {
  final double mevcutCpu;
  final double limit;

  CpuOverload({required this.mevcutCpu, required this.limit})
    : super(
        //
        "Err_cpu_overload",
        "Cpu kullanımı eşik limitini ($limit) aştı: $mevcutCpu%",
      );
}

class NodeUnavailable extends Cloud {
  final String nodeID;
  NodeUnavailable(this.nodeID)
    : super("Err_node_offline", "Yanıt vermiyor: $nodeID");
}

void podKaynaginiTahsisEt(
  String podAdi,
  double talepEdilenCpu,
  double sistemKalanCpu,
) {
  if (talepEdilenCpu <= 0) {
    throw Cloud(
      "Err_invalid_param",
      "Talep edilen cpu pozitif bir değer olmalıdır. ",
    );
  }
  if (talepEdilenCpu > sistemKalanCpu) {
    throw CpuOverload(
      mevcutCpu: 100 - sistemKalanCpu + talepEdilenCpu,
      limit: 100.0,
    );
  }

  print(
    "Pod [$podAdi] başarıyla tahis edildi. Kalan boş CPU : ${sistemKalanCpu - talepEdilenCpu}%",
  );
}

void main() {
  print("Yönetim Bölümü");

  //başarılı tahsis
  try {
    podKaynaginiTahsisEt("ingress-controller", 15.0, 40.0);
  } catch (err) {
    print("Hata: $err");
  }

  //CPU
  try {
    podKaynaginiTahsisEt("ai-training-pd", 75.0, 20.0);
  } on CpuOverload catch (e) {
    print("Cpu hatası yakalandı");
    print("Hata kodu: ${e.hataKodu}");
    print("Mesaj: ${e.mesaj}");
    print("Aksiyon: Otomatik AWS Açma isteğii gönderildi");
  } on Cloud catch (e) {
    print("Bulurt hatası: ${e.mesaj}");
  } catch (e, stackTrace) {
    print("Bilinmedik Sirem hatası $e");
  } finally {
    print("Pod tahsis günlüğü kapatıldı");
  }
}
