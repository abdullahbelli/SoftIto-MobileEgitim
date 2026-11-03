import 'package:flutter/material.dart';
import 'package:test/models/ogrenci_model.dart';

class OgrenciFormu extends StatefulWidget {
  //durum bilgisi tutabilen öğrenci formu widgetı
  const OgrenciFormu({
    super.key,
  }); //constructor metodu key bilgisini üst sınıfa gönderir

  @override //üst sınıftaki metodu yeniden yazdığımızı belirtir
  State<OgrenciFormu> createState() => _OgrenciFormuState(); //formun state nesnesini oluşturur
}

class _OgrenciFormuState extends State<OgrenciFormu> {
  //formun durumunu ve işlemlerini yöneten sınıf
  final FireStoreOgrenciServisi _servis = FireStoreOgrenciServisi(); //firebase işlemlerini yapmak için servis nesnesi oluşturur

  final TextEditingController _adSoyadKontrolcusu =
      TextEditingController(); //ad soyad alanındaki metni kontrol eder
  final TextEditingController _projeKontrolcusu =
      TextEditingController(); //proje adı alanındaki metni kontrol eder
  final TextEditingController _notKontrolcusu =
      TextEditingController(); //not alanındaki metni kontrol eder

  @override //üst sınıftaki dispose metodunu yeniden yazar
  void dispose() {
    //widget kaldırılırken kullanılan kaynakları temizler
    _adSoyadKontrolcusu.dispose(); //ad soyad kontrolcüsünü temizler
    _notKontrolcusu.dispose(); //not kontrolcüsünü temizler
    _projeKontrolcusu.dispose(); //proje kontrolcüsünü temizler
    super.dispose(); //üst sınıfın dispose metodunu çalıştırır
  }

  @override //üst sınıftaki build metodunu yeniden yazar
  Widget build(BuildContext context) {
    //formun arayüzü
    return Padding(
      //formun dışına boşluk
      padding: const EdgeInsets.all(
        12.0,
      ), //formun dört tarafına 12 birim boşluk
      child: Padding(
        //formun içine ikinci bir boşluk
        padding: const EdgeInsets.all(12.0), //dört tarafa 12 birim daha boşluk
        child: Column(
          //form elemanlarını dikey olarak sıralar
          children: [
            //column içindeki widgetların listesi
            TextField(
              //ad soyad girişi için metin kutusu
              controller: _adSoyadKontrolcusu, //girilen ad soyad bilgisini kontrolcüye bağlar
              decoration: const InputDecoration(
                //metin kutusunun görünümü
                labelText: "Öğrenci Adı Soyadı", //kutunun açıklama yazısı
                prefixIcon: Icon(Icons.person), //kutunun başına kişi ikonu
              ),
            ),
            const SizedBox(height: 8), //elemanlar arasına 8 birim dikey boşluk
            Row(
              //proje ve not alanlarını yatay olarak sıralar
              children: [
                //row içindeki widgetların listesi
                Expanded(
                  //proje alanının kalan yatay boşluğu kaplar
                  child: TextField(
                    //proje adı için metin kutusu
                    controller: _projeKontrolcusu, //girilen proje adını kontrolcüye bağlar
                    decoration: const InputDecoration(
                      //metin kutusunun görünümü
                      labelText: "Proje Adı", //kutunun açıklama yazısı
                      prefixIcon: Icon(
                        Icons.assignment,
                      ), //kutunun başına proje ikonu
                    ),
                  ),
                ),
                SizedBox(
                  //not alanına belirli bir genişlik verir
                  width: 150, //not kutusunun genişliğini 150 birim
                  child: TextField(
                    //not girişi için metin kutusu
                    controller: _notKontrolcusu, //girilen not bilgisini kontrolcüye bağlar
                    keyboardType:
                        TextInputType.number, //sayısal klavyenin açılır
                    decoration: const InputDecoration(
                      //not kutusunun görünümü
                      labelText: "Not (0-100)", //kutunun açıklama yazısı
                      prefixIcon: Icon(Icons.grade), //kutunun başına not ikonu
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12), //butondan önce 12 birim boşluk
            ElevatedButton.icon(
              //ikonlu ve yükseltilmiş buton
              style: ElevatedButton.styleFrom(
                //butonun tasarım özellikleri
                backgroundColor: Colors.pink, //butonun arka plan rengi pembe
                foregroundColor:
                    Colors.brown, //butonun yazı ve ikon rengi kahverengi
                minimumSize: const Size.fromHeight(
                  44,
                ), //butonun min yüksekliği 44 ve genişliği doldurur
              ),
              onPressed: _yeniOgrenciKaydet, //butona basılınca öğrenci kaydetme metodunu çağırır
              icon: const Icon(Icons.cloud_upload), //buluta yükleme ikonu
              label: const Text(
                "Buluta kaydet",
              ), //butonun üzerinde gösterilecek yazı
            ),
          ],
        ),
      ),
    );
  }

  void _yeniOgrenciKaydet() {
    //formdaki bilgileri alarak öğrenci kaydetme işlemini başlatır
    final adSoyad = _adSoyadKontrolcusu.text
        .trim(); //ad soyadı alır ve gereksiz boşlukları siler
    final proje = _projeKontrolcusu.text
        .trim(); //proje adını alır ve gereksiz boşlukları siler
    final not =
        int.tryParse(_notKontrolcusu.text.trim()) ??
        0; //notu tam sayıya çevirir çevrilemezse 0 verir

    if (adSoyad.isEmpty || proje.isEmpty) {
      //ad soyad veya proje adı boşsa bu bloğa girer
      ScaffoldMessenger.of(context).showSnackBar(
        //ekranın alt kısmında uyarı mesajı gösterir
        const SnackBar(
          //kısa süreli bildirim
          content: Text(
            'Lütfen ad soyad ve proje adını giriniz.',
          ), //kullanıcıya gösterilecek hata mesajı
        ),
      );
      return; //metodu burada bitirir ve kayıt işlemini engeller
    }
    _servis.ogrenciEkle(
      adSoyad: adSoyad,
      projeAdi: proje,
      notu: not,
    ); //öğrenci bilgilerini firestore servisine gönderir
    _adSoyadKontrolcusu.clear(); //ad soyad kutusunu temizler
    _projeKontrolcusu.clear(); //proje adı kutusunu temizler
    _notKontrolcusu.clear(); //not kutusunu temizler
  }
}
