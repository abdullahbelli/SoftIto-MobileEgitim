//setState() bulunduğu State nesnesinin build() metodunu baştan aşağı tekrar tetikler.
//Scaffold appbar tabbar ve eğer varsa 20 tane container baştan hesaplanır.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SepetKontrolu {
  static final SepetKontrolu ornek = SepetKontrolu._dahili();
  SepetKontrolu._dahili();

  final ValueNotifier<int> urunSayisi = ValueNotifier<int>(0);

  void sepeteEkle(){
    urunSayisi.value++;
  }

  void sepetiSifirla(){
    urunSayisi.value = 0;
  }

  //const gibi değiştirlmeyen başka ne veri türü var ??? 


}

final GoRouter uygulamaRotalari = GoRouter(
  initialLocation :'/anasayfa',
  routes:[
    ShellRoute(
      builder: (BuildContext context, GoRouterState state,Widget child){
        return AnaKasaEkrani(ekranGovdesi:child);

      },
      routes:[
        GoRoute(
          path:'/vitrin',
          builder:(context,state) => const VitrinEkrani(),
        ),
        GoRoute(
          path:'/profil',
          builder:(context,state) => const ProfilEkrani(),
        ),
      ],
    ),
  ],
);

class AnaKasaEkrani extends StatelessWidget {//Stateless stateful farkı ?? 
  final Widget ekranGovdesi;
  const AnaKasaEkrani({super.key, required this.ekranGovdesi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ekranGovdesi,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aktifIndexiBul(context),
        onDestinationSelected: (yeniIndex) {
          if(yeniIndex == 0) {
            context.go('/vitrin');
          }
          if(yeniIndex == 1) {
            context.go('/profil');
          }
        },
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          const NavigationDestination(icon: Icon(Icons.store), label: 'Vitrin'),
          NavigationDestination(icon: ValueListenableBuilder<int>(valueListenable: SepetKontrolu.ornek.urunSayisi, builder: (context,sayi,child){
            return Badge(
              label: Text('Sayi'),
              isLabelVisible: sayi>0,
              child: const Icon(Icons.person),
            );
          },
        ), label: 'Profil',
        ),
        ],
      ),
    );
  }


  int _aktifIndexiBul(BuildContext context){
    final String konum = GoRouterState.of(context).uri.toString();
    if(konum.startsWith('/profil')) return 1;
    return 0;
  }

  
}

class VitrinEkrani extends StatelessWidget{
  const VitrinEkrani({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Canlı Vitrin ( ValueNotifier )'),),
      body: Center(
        child: ElevatedButton.icon(onPressed: (){
          SepetKontrolu.ornek.sepeteEkle();
        },
        icon:const Icon(Icons.add_shopping_cart), 
        label: const Text('Sepete Ürün Ekle (+1)'),),
      ),
    );
  }
}

class ProfilEkrani extends StatelessWidget{
  const ProfilEkrani({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kullanıcı Profili'),
      ),
      body: Center(
        child: TextButton(onPressed: () => SepetKontrolu.ornek.sepetiSifirla(),
        child: const Text('Sepeti Temizle (0 yap)')),
      ),
    );
  }
}