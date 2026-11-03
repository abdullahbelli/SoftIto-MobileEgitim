import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/models/ogrenci_model.dart';

import 'not_guncelle_dialog.dart';

class OgrenciListesi extends StatefulWidget {
  //öğrenci listesini göstermek için durum tutabilen widget oluşturur
  const OgrenciListesi({
    super.key,
  }); //constructor metodu key bilgisini üst sınıfa gönderir

  @override //üst sınıftaki metodu yeniden yazdığımızı belirtir
  State<OgrenciListesi> createState() => _OgrenciListesiState(); //widgetın state nesnesini oluşturur
}

class _OgrenciListesiState extends State<OgrenciListesi> {
  //öğrenci listesinin arayüzünü ve işlemlerini yöneten sınıf
  final FireStoreOgrenciServisi _servis = FireStoreOgrenciServisi(); //öğrenci silme işlemini yapmak için servis nesnesi oluşturur

  @override //üst sınıftaki build metodunu yeniden yazar
  Widget build(BuildContext context) {
    //öğrenci listesinin arayüzü
    return StreamBuilder<QuerySnapshot>(
      //firestore verilerini canlı olarak dinleyen widget
      stream: FirebaseFirestore
          .instance //firebase firestore veritabanına erişir
          .collection('ogrenciler') //ogrenciler isimli koleksiyonu seçer
          .orderBy(
            'notu',
            descending: true,
          ) //öğrencileri notlarına göre büyükten küçüğe sıralar
          .snapshots(), //verilerdeki değişiklikleri canlı olarak dinleyen stream
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        //gelen verinin durumuna göre arayüz oluşturur
        if (snapshot.hasError) {
          //veri alınırken hata oluşup oluşmadığını kontrol eder
          return Center(
            child: Text("Bulut hatası : ${snapshot.error}"),
          ); //hata mesajını ekranın ortasında gösterir
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          //ilk verilerin gelmesini bekleyip beklemediğini kontrol eder
          return const Center(
            child: CircularProgressIndicator(),
          ); //veriler yüklenirken dönen yükleme işareti gösterir
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          //veri yoksa veya gelen belge listesi boşsa kontrol eder
          return const Center(
            //içindeki widgetı ekranın ortasına yerleştirir
            child: Text(
              "Henüz bulutta kaıtlı öğrenci yoktur",
            ), //öğrenci bulunmadığında gösterilecek mesaj
          );
        }
        final List<DocumentSnapshot> dokumanlar = snapshot
            .data!
            .docs; //firestoredan gelen öğrenci belgelerini listeye alır

        return ListView.builder(
          //öğrencileri kaydırılabilir liste halinde oluşturur
          itemCount:
              dokumanlar.length, //listede kaç öğrenci gösterileceğini belirler
          itemBuilder: (context, index) {
            //listedeki her öğrenci için ayrı widget oluşturur
            final doc = dokumanlar[index]; //o sıradaki öğrenci belgesini alır
            final ogrenci = OgrenciModel.fromFireStore(
              doc,
            ); //firestore belgesini öğrenci modeline dönüştürür
            return Dismissible(
              //kaydırark llisteden silme kilt ekranındaki bildirimler gibi
              //kaydırarak silme işlemi yapıyoruz ve firestoredan da siliyoruz
              key: Key(
                ogrenci.id,
              ), //her öğrenciyi benzersiz belge idsi ile tanımlar
              direction: DismissDirection
                  .endToStart, //kullanıcının sağdan sola kaydırılmasını sağlar
              background: Container(
                //kaydırma sırasında arkada görünecek alan
                alignment:
                    Alignment.centerRight, //içindeki ikonu sağ tarafa hizalar
                padding: const EdgeInsets.only(
                  right: 20,
                ), //sağ taraftan 20 birim boşluk
                color: Colors.red,
                child: const Icon(Icons.delete_forever, color: Colors.white),
              ),
              onDismissed: (direction) {
                //öğrenci kaydırılarak silindiğinde çalışır
                _servis.ogrenciSil(ogrenci.id); //öğrenciyi firestore veritabanından silmek için servisi çağırır
                ScaffoldMessenger.of(context).showSnackBar(
                  //ekranın altında bildirim gösterir
                  SnackBar(
                    //kısa süreli bildirim
                    content: Text(
                      '${ogrenci.adSoyad} buluttan silindi.',
                    ), //silinen öğrencinin adını mesajda gösterir
                  ),
                );
              },
              child: ListTile(
                //öğrenci bilgilerini tek satırlık liste elemanı şeklinde gösterir
                leading: CircleAvatar(
                  //liste elemanının soluna yuvarlak alan ekler
                  backgroundColor:
                      ogrenci.notu >=
                          80 //öğrencinin notu 80 veya üzerindeyse kontrol eder
                      ? Colors
                            .green //not 80 veya üzerindeyse yeşil renk kullanır
                      : (ogrenci.notu >= 50 ? Colors.orange : Colors.red), //not 50-79 arasındaysa turuncu değilse kırmızı kullanır
                  child: Text(
                    //yuvarlak alanın içine yazı ekler
                    '${ogrenci.notu}', //öğrencinin notunu metin olarak gösterir
                    style: const TextStyle(
                      //not yazısının görünümü
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  //liste elemanının ana başlığı
                  '${ogrenci.adSoyad}', //öğrencinin adını ve soyadını gösterir
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Proje: ${ogrenci.projeAdi}',
                ), //öğrencinin proje adını alt başlık olarak gösterir
                trailing: IconButton(
                  //liste elemanının sağına tıklanabilir ikon ekler
                  onPressed: () => notGuncelleDialog(
                    context,
                    ogrenci,
                    _servis,
                  ), //ikona basılınca not güncelleme penceresini açar
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.amberAccent,
                  ), //sarı tonunda düzenleme ikonu
                ),
              ),
            );
          },
        );
      },
    );
  }
}
