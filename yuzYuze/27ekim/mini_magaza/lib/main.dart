import 'package:flutter/material.dart';
import 'screens/urun_listesi_ekrani.dart';
void main(){
  runApp(const MiniMagazaUygulamasi());
}

class MiniMagazaUygulamasi extends StatelessWidget {
  const MiniMagazaUygulamasi({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      debugShowCheckedModeBanner: false, // SAĞ ÜSTEKİ DEBUG YAZISINI KAPATIR
      title: "Mini Mağaza",
      theme:ThemeData(
        useMaterial3: true, // M3 tasarım motorunu aktif eder.
        colorScheme:ColorScheme.fromSeed( //fromSeed M3 temele renk algoritmalarıyla renkleri oluşturur.
          seedColor: Colors.indigo,
          brightness:Brightness.light, // Aydınlık tema
          

          ),
      ),
    
      home:const UrunListesiEkrani(),
    );
  }
}