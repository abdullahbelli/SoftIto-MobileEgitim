// //JS teki gibi let x="Ahmet"; x=42;
// //print("İlk dersimiz -Dart SDK akitfi olmalı");
// //1. açık belirtilen veri tiplleri
// int seansSuresiDakike = 15;
// double seansUcretTL = 2750.50;
// String uzmanAdi = "Dr. Abdullah Belli";
// bool akitfMi = true;

// //2. String interpolation
// //JS teki `${}` yerine sadece $degisken işlem varsa {$degisken*2} kullanılır
// print(
//   "Uzman: $uzmanAdi | Süre: $seansSuresiDakike dk | Ücret: $seansUcretTL ₺",
// );
// print("KDV dahil (%20) ${seansUcretTL * 1.20} ₺");

// //3. var ile tip çıkarımı
// var tedaviAdi = "Kahve ile Peeling";
// //tedaviAdi = 99; //var ile string olarak girdik string tip olarak atadık

// //4. dynamic veri tipini bağımsız kullanabilirsiniz ancak flutterda önerilmez
// dynamic serbestKutu = "Lazer epilasyon";
// serbestKutu = 1000; //izin verilir ama veri tip güvenliğini yok eder

// //const: Derleme anında değeri belli olan veriler, bellekte tek biir yerde saklanıır
// const String KLINIK_ADI = "Sofito Güzellik Merkezi";
// const double KDV_ORANI = 0.20;

// // const DateTime suankiZaman =
// //     DateTime.now(); //Hta derleme anında bunu bilemeyiz

// //final: Çalışma anında hesaplanır bir kere atandıktan sonra değişmez
// final DateTime randevuZamani = DateTime.now();
// final String takipKodu =
//     "SOFT" + randevuZamani.microsecondsSinceEpoch.toString();
// print("Klinik Adı: $KLINIK_ADI");
// print("Oluşturulma tarihi $randevuZamani |Kod: $takipKodu");

// //Dartta değişken varsayılan olarak null olamaz bunun yrine null safety operatörleri kullanırız(?,??,!)

// String zorunluDanisanAdi = "Abdullah Belli";
// // zorunluDanisanAdi = null; //hata
// String? danisanAlerjiNotu;
// print("Alerji notu: $danisanAlerjiNotu");

// //ifNull operatörü-null ise varsayılan değer atamma
// String goruntulenecekNot = danisanAlerjiNotu ?? "Bilinen bir alerjsii yok";
// print("Rapor: $goruntulenecekNot");

// //null aware
// print("alerji metin uzunluğu: ${danisanAlerjiNotu?.length}");

//Klasik sıralı fonksiyon
double topla(double a, double b) => a + b;

//Modern Dart / Flutter standartları:Naed parameters({})

void seansKaydiOlustur({
  required String danisan,
  required String tedavi,
  required double birimFiyat,
  int seansSayisi = 1, //default değer
  double indirimOrani = 0.0, //default değer
  String? uzmanHekim, //null olabilir
}) {
  final double brutTutar = birimFiyat * seansSayisi;
  final double indirimTutari = brutTutar * (indirimOrani / 100);
  final double netTutar = brutTutar - indirimTutari;

  print("""
================================

Softİto Seans Sözleşmesi

--------------------------------

Danışan         : $danisan
Tedavi          : $tedavi (x$seansSayisi Seans)
Uzman Hekim     : ${uzmanHekim ?? "Nöbetçi Estetisyen"}
Brüt Tutar      : $brutTutar ₺
İndirim         : $indirimTutari ₺ ($indirimOrani)
Net Tutar       : $netTutar ₺

""");
}

void main() {
  seansKaydiOlustur(
    danisan: "Abdullah Belli",
    tedavi: "Medikal Cilt Yenileme",
    birimFiyat: 4500.0,
    seansSayisi: 3,
    indirimOrani: 15.0,
    uzmanHekim: "Dr.Abdullah",
  );
}
