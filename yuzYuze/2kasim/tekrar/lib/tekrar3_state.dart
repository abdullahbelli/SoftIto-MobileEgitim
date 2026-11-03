//setState() bulunduğu State nesnesinin build() metodunu baştan aşağı tekrar tetikler.
//Scaffold appbar tabbar ve eğer varsa 20 tane container baştan hesaplanır.

import 'package:flutter/material.dart'; // flutter arayüz bileşenlerini kullnaılmasını sağlar
import 'package:go_router/go_router.dart'; // Sayfalar arasında yönlendirme yapmayı sağlar

class SepetKontrolu {
  // Sepetteki ürün sayısını merkezi olarak yöneten sınıf
  static final SepetKontrolu ornek = SepetKontrolu._dahili(); // Singleton yapısıyla tek bir ortak nesne oluşturur
  SepetKontrolu._dahili(); // Dışarıdan yeni nesne oluşturulmasını engelleyen özel constructor

  final ValueNotifier<int> urunSayisi = ValueNotifier<int>(
    0,
  ); // Ürün sayısını tutar ve değiştiğinde dinleyicilere haber verir

  void sepeteEkle() {
    // Sepete ürün ekleme işlemini gerçekleştirir
    urunSayisi
        .value++; // Ürün sayısını bir artırır ve dinleyicileri bilgilendirir
  }

  void sepetiSifirla() {
    // Sepetteki ürün sayısını sıfırlayan metot
    urunSayisi.value =
        0; // Ürün sayısını sıfırlar ve değişikliği dinleyicilere bildirir
  }
}

//const gibi değiştirlmeyen başka ne veri türü var ???
//final: Değişkene yalnızca bir kez değer atanabilir ancak tuttuğu nesnenin içeriği değişebilir
//const: Derleme zamanında bilinen sabit değerleri tanımlar ve sabit nesneler değiştirilemez
//late final: Değerin daha sonra yalnızca bir kez atanmasını sağlar
//UnmodifiableListView: Listenin dışarıdan değiştirilmesini engelleyen salt okunur görünüm sağlar

final GoRouter uygulamaRotalari = GoRouter(
  // Uygulamanın sayfa yönlendirme kurallarını tanımlar
  initialLocation: '/anasayfa', // Uygulama açıldığında ana sayfayı gösterir
  routes: [
    // Uygulamada kullanılacak sayfa yollarını listeler
    ShellRoute(
      // Alt navigasyon gibi ortak arayüzü sayfalar arasında korur
      builder: (BuildContext context, GoRouterState state, Widget child) {
        // Ortak ekran yapısını oluşturur ve aktif sayfayı alır
        return AnaKasaEkrani(
          ekranGovdesi: child,
        ); // Aktif sayfayı ana ekranın gövdesine yerleştirir
      },
      routes: [
        // Ortak arayüz içerisinde gösterilecek alt sayfaları tanımlar
        GoRoute(
          // Belirli bir URL yolunu bir ekrana bağlar
          path: '/anasayfa', // Ana sayfanın URL yolunu belirler
          builder: (context, state) => const Center(
            child: Text("1234"),
          ), // Ana sayfada ortalanmış metin gösterir
        ),
        GoRoute(
          path: '/vitrin', // Vitrin sayfasının URL yolunu belirler
          builder: (context, state) =>
              const VitrinEkrani(), // Vitrin ekranını oluşturur
        ),
        GoRoute(
          path: '/profil', // Profil sayfasının URL yolunu belirler
          builder: (context, state) =>
              const ProfilEkrani(), // Profil ekranını oluşturur
        ),
      ],
    ),
  ],
);

//Stateless stateful farkı ??
// StatelessWidget: Kendi içinde değişebilir bir State nesnesi yönetmez ancak dışarıdan gelen veriler değiştiğinde yeniden oluşturulabilir
// StatefulWidget: Değişebilir verileri ayrı bir State nesnesinde yönetir ve setState() ile arayüzün güncellenmesini sağlar

class AnaKasaEkrani extends StatelessWidget {
  // Ortak alt menüyü ve aktif sayfayı gösteren durumsuz widget

  final Widget ekranGovdesi; // Aktif sayfanın arayüzünü saklar
  const AnaKasaEkrani({
    super.key,
    required this.ekranGovdesi,
  }); // Ekran oluşturulurken gösterilecek gövdenin verilmesi zorunlu

  @override // Üst sınıftaki build metodunu yeniden tanımlar
  Widget build(BuildContext context) {
    // Ana ekranın arayüz yapısını oluşturur
    return Scaffold(
      // Ekranın gövdesini ve alt navigasyon alanını oluşturur
      body: ekranGovdesi, // Router tarafından seçilen sayfayı gövdede gösterir
      bottomNavigationBar: NavigationBar(
        // Sayfalar arasında geçiş sağlayan alt menü
        selectedIndex: _aktifIndexiBul(
          context,
        ), // Bulunulan sayfaya göre aktif sekmeyi belirler
        onDestinationSelected: (yeniIndex) {
          // Kullanıcı alt menüden sekme seçtiğinde çalışır
          if (yeniIndex == 0) {
            //ilk sekme seçiliyse ana sayfaya yönlendirir

            context.go('/anasayfa');
          } else if (yeniIndex == 1) {
            //iikinci sekme seçiliyse vitrine yönlendirir

            context.go('/vitrin');
          } else if (yeniIndex == 2) {
            //üçüncü sekme seçiliyse profile yönlendirir

            context.go('/profil');
          }
        },
        destinations: [
          // Alt menüde gösterilecek sekmeleri tanımlar
          const NavigationDestination(
            // Ana sayfa sekmesini oluşturur
            icon: Icon(Icons.home), // Ana sayfa ikonu
            label: 'Ana Sayfa', // Sekmenin adı
          ),
          const NavigationDestination(
            icon: Icon(Icons.store),
            label: 'Vitrin',
          ), // Vitrin sekmesini oluşturur
          NavigationDestination(
            // Profil sekmesini oluşturur
            icon: ValueListenableBuilder<int>(
              // Ürün sayısı değiştiğinde yalnızca bu bölümün yeniden oluşturulmasını sağlar
              valueListenable: SepetKontrolu
                  .ornek
                  .urunSayisi, // Sepetteki ürün sayısını dinler
              builder: (context, sayi, child) {
                // Güncel ürün sayısına göre ikon üzerindeki rozeti oluşturur
                return Badge(
                  // İkonun üzerindeki sayısal bildirim rozeti
                  label: Text('$sayi'), // Rozette güncel ürün sayısını gösterir
                  isLabelVisible:
                      sayi > 0, // Sepette ürün varsa rozeti görünür yapar
                  child: const Icon(Icons.person), // Profil ikonu
                );
              },
            ),
            label: 'Profil', // Sekmenin adı
          ),
        ],
      ),
    );
  }

  int _aktifIndexiBul(BuildContext context) {
    // Mevcut URL yoluna göre aktif sekmenin indeksini bulur
    final String konum = GoRouterState.of(context).uri
        .toString(); // Bulunulan sayfanın URL bilgisini alır
    if (konum.startsWith('/profil'))
      return 2; // Profil sayfasındaysa üçüncü sekmeyi seçer
    if (konum.startsWith('/vitrin'))
      return 1; // Vitrin sayfasındaysa ikinci sekmeyi seçer
    return 0; // Diğer durumlarda ana sayfa sekmesini seçer
  }
}

class VitrinEkrani extends StatelessWidget {
  // Sepete ürün ekleme işleminin yapıldığı ekran
  const VitrinEkrani({
    super.key,
  }); // Widget'ın oluşturulmasını ve flutter tarafından takip edilmesini sağlar

  @override // Üst sınıftaki build metodunu yeniden tanımlar
  Widget build(BuildContext context) {
    // Vitrin ekranının arayüzü
    return Scaffold(
      // Vitrin ekranının temel yapısı
      appBar: AppBar(
        title: const Text('Canlı Vitrin ( ValueNotifier )'),
      ), // Ekranın üst başlığı
      body: Center(
        // Butonu ekranın ortasına yerleştirir
        child: ElevatedButton.icon(
          // İkon ve metin içeren tıklanabilir buton oluşturur
          onPressed: () {
            // Butona basıldığında çalışır
            SepetKontrolu.ornek
                .sepeteEkle(); // Ortak sepet nesnesindeki ürün sayısını artırır
          },
          icon: const Icon(Icons.add_shopping_cart), // Sepete ekleme ikonu
          label: const Text(
            'Sepete Ürün Ekle (+1)',
          ), // Butonun üzerindeki açıklama metni
        ),
      ),
    );
  }
}

class ProfilEkrani extends StatelessWidget {
  // Sepeti sıfırlama işleminin yapıldığı ekran
  const ProfilEkrani({
    super.key,
  }); // Widget'ın oluşturulmasını ve flutter tarafından takip edilmesini sağlar

  @override // Üst sınıftaki build metodunu yeniden tanımlar
  Widget build(BuildContext context) {
    // Profil ekranının arayüzü
    return Scaffold(
      // Profil ekranının temel yapısını oluşturur
      appBar: AppBar(
        title: const Text('Kullanıcı Profili'),
      ), // Profil ekranının üst başlığı
      body: Center(
        // Butonu ekranın ortasına yerleştirir
        child: TextButton(
          // Metin biçiminde tıklanabilir buton oluşturur
          onPressed: () => SepetKontrolu.ornek.sepetiSifirla(), // Butona basıldığında ortak sepet sayısını sıfırlar
          child: const Text('Sepeti Temizle (0 yap)'), // Butonun açıklama metni
        ),
      ),
    );
  }
}
