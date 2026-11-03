import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'screens/firestore_yonetim_ekrani.dart';
import 'firebase_options.dart';

//firebase başlatılmadan önce flutter altyapısının hazır olması gerekiyor
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //flutter altyapısını hazırlar ve firebase başlatılmadan önce gerekli bağlantıları kurar
  await Firebase.initializeApp(
    //firebase başlatılana kadar bekler
    options: DefaultFirebaseOptions
        .currentPlatform, //çalışılan platforma göre firebase ayarlarını seçer
  ); //firebase uygulama başlangıcında bir kez başlatılır
  runApp(
    const SoftitoFirestoreUygulamasi(),
  ); //uygulamanın ana widgetını çalıştırır
}

class SoftitoFirestoreUygulamasi extends StatelessWidget {
  //durumu kendi içinde değişmeyen ana uygulama widgetı
  const SoftitoFirestoreUygulamasi({
    super.key,
  }); //widgetın constructor metodu super.key üst sınıfa key bilgisini gönderir

  @override //üst sınıftaki metodu yeniden yazdığımızı belirtir
  Widget build(BuildContext context) {
    //uygulamanın arayüzünü oluşturur context widgetın bulunduğu konumun bilgisini taşır
    return MaterialApp(
      //uygulamanın genel tema ve başlangıç ekranı ayarlarını yapar
      debugShowCheckedModeBanner: false, //debug yazısını gizler
      title: "Cloud FireStore", //uygulamanın başlığı
      theme: ThemeData(
        //uygulamanın genel tasarım ayarları
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
        ), //turuncu renkten uyumlu bir renk paleti
        useMaterial3: true, //material 3 tasarım sistemini kullanır
      ),
      home: const FirestoreYonetimEkrani(), //uygulama açıldığında gösterilecek ilk ekran
    );
  }
}
