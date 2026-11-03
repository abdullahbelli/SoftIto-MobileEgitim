import 'package:flutter/material.dart';

import '../../widgets/ogrenci_formu.dart';
import '../../widgets/ogrenci_listesi.dart';

class FirestoreYonetimEkrani extends StatefulWidget {
  //durumu değişebilen bir widget oluşturur
  const FirestoreYonetimEkrani({
    super.key,
  }); //widgetın constructor metodu key bilgisini üst sınıfa gönderir

  @override //üst sınıftaki metodu yeniden yazdığımızı belirtir
  State<FirestoreYonetimEkrani> createState() => _FirestoreYonetimEkraniState(); //widgetın state nesnesini oluşturur
}

class _FirestoreYonetimEkraniState extends State<FirestoreYonetimEkrani> {
  //ekranın durumunu ve arayüzünü yöneten sınıf
  @override //üst sınıftaki build metodunu yeniden yazar
  Widget build(BuildContext context) {
    //ekranın arayüzünü oluşturur context widgetın ağaçtaki konumunu belirtir
    return Scaffold(
      //sayfanın temel iskeleti
      appBar: AppBar(
        //sayfanın üst başlık çubuğu
        title: const Text('Canlı Firestore Ekranı'), //üst çubuktakii başlık
        backgroundColor: Colors.amber.shade600, //üst çubuğun arka plan rengi
      ),
      body: Column(
        //sayfanın içindeki widgetları dikey olarak sıralar
        children: [
          //column içinde gösterilecek widgetların listesi
          const OgrenciFormu(), //öğrenci ekleme formunu ekrana yerleştirir
          const Divider(thickness: 2), //form ile liste arasına çizgi
          const Expanded(
            child: OgrenciListesi(),
          ), //öğrenci listesinin kalan dikey alanı kaplamasını sağlar
        ],
      ),
    );
  }
}
