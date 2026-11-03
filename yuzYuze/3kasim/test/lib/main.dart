import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_yonetim_ekrani.dart';


//firebaseden önce motor kuurlması gerekli yoksa uygulama çöker
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // yerel kanallar ayağa kaldırılırı bu olmadan firebsae bağlanırsa uygulam çöker
  await Firebase.initializeApp();//başlangıçta bir kez çalışır
  runApp(const SoftitoFirestoreUygulamasi());
}

class SoftitoFirestoreUygulamasi extends StatelessWidget{
  const SoftitoFirestoreUygulamasi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Cloud FireStore",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,

      ),
      home : const FirestoreYonetimEkrani(),
    );
  }
}