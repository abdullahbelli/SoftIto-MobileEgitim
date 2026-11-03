import 'package:flutter/material.dart';
import 'package:test/models/ogrenci_model.dart';

void notGuncelleDialog(
  //not güncelleme penceresini açan fonksiyon
  BuildContext context, //pencerenin hangi widget üzerinden açılacağını belirler
  OgrenciModel ogrenci, //notu güncellenecek öğrencinin bilgilerini alır
  FireStoreOgrenciServisi
  servis, //firestore güncelleme işlemini yapacak servis nesnesini alır
) {
  //mevcut notu kutunun içine yazılır
  final TextEditingController yeniNotKontrolcusu = TextEditingController(
    //yeni notun yazılacağı kutuyu kontrol eder
    text: ogrenci.notu
        .toString(), //öğrencinin mevcut notunu metne çevirip kutuya yerleştirir
  );

  showDialog(
    //ekranda açılır pencere gösterir
    context: context, //pencerenin açılacağı ekranın context bilgisini kullanır
    builder: (context) {
      //açılacak pencerenin arayüzünü oluşturur
      return AlertDialog(
        //başlık içerik ve butonlardan oluşan uyarı penceresi oluşturur
        title: const Text("Not Güncelle"), //pencerenin üst başlığı
        content: TextField(
          //yeni notun girileceği metin kutusu
          controller:
              yeniNotKontrolcusu, //girilen not bilgisini kontrolcüye bağlar
          keyboardType: TextInputType.number, //sayısal klavyenin açılır
          decoration: const InputDecoration(
            labelText: "Yeni Not",
          ), //metin kutusunun açıklama yazısı
        ),
        actions: [
          //pencerenin alt kısmındaki butonlar
          TextButton(
            //iptal işlemi için metin butonu
            onPressed: () {
              //iptal butonuna basıldığında çalışır
              Navigator.pop(context); //pencereyi kapatma
            },
            child: const Text("İptal"), //butonun üzerinde gösterilecek yazı
          ),
          ElevatedButton(
            //notu güncellemek için buton
            onPressed: () {
              //güncelle butonuna basıldığında çalışır
              //girilen yeni notu sayıya çevirir
              final yeniNot =
                  int.tryParse(yeniNotKontrolcusu.text.trim()) ??
                  0; //girilen metni tam sayıya çevirir çevrilemezse 0 kullanır

              //servisteki güncelleme metodunu çağrılır
              servis.ogrenciNotuGuncelle(ogrenci.id, yeniNot); //öğrencinin id bilgisiyle yeni notu firestore veritabanına gönderir

              Navigator.pop(context); //pencereyi kapatma
            },
            child: const Text("Güncelle"), //butonun üzerinde gösterilecek yazıs
          ),
        ],
      );
    },
  );
}
