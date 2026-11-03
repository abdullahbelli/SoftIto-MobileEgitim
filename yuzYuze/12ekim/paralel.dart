/*Future<void> fetchDashboardData() async { //geriye değer döndürmeyen asenkron func.
  try { //hataları yakalamka için kullanılır
    final result=await Future.wait([ //brden fazla asenkorn işlemi birlikte bekler.
      fetchUserProfile(), //kullanıcı bilgilerini getiri.
      fetchAccountBalance(), //hesap bakiyesini getiri.
      fetchNotification(), // bildirimleri getiri.
    ],eagerError:   true);  // İlk hatada beklemeyi bırakır, diğer işlemleri iptal etmez.
    print("Tüm veriler geldi $result"); //tüm işlemler başarılıysa sonuçları yazdırı.
  } catch (e) { //oluşan hatalar yakalar.
    print("İsteklerden biri başarısız oldu $e");
  }
}*/

//Future TEK BİR kere veri çekileceği zaman kullanılır ya hata ya da değer dönüp bitirir.
//sTREAM: Bir boru hattı şeklinde çalışır (pipe) , zaman içinde 1 10 100 ya da sonsuz sayıda veri akışı sağlanabilir.
//(Borsa fiyatları , gps KONUM GÜNCELLERKEN, fİREBASE TARAFINDAN CANLI DİNLEME)

import 'dart:async'; // Dart'ın asenkron programlama kütüphanesini import eder. (StreamController, Stream ve StreamSubscription kullanabiliriz.)

void main() {
  // dart programının çalışmaya başladığı ana fonksiyon

  // Varsayılan olarak tek abonelikli (single-subscription) bir stream oluşturulur.
  final controller = StreamController<int>(); //controller oluşturu. int türünde verilerin gönderildiği StreamController nesnesi oluştruur.
  // Controller, veri akışına veri eklenmesini ve bu akışın yönetilmesini sağlar.

  //dinleyici (listener) bağlama

  // controller.stream üzerinden gelen verileri dinlemek için listen() kullanılır.
  // listen() geriye bir StreamSubscription nesnesi döndürür.
  // subscription değişkeni bu aboneliği tutar.
  final subscription = controller.stream.listen(
    // Stream'e yeni bir veri geldiğinde çalışır.
    // data parametresi gönderilen int değerini temsil eder.
    (data) => print("Yeni Veri: $data"),

    // Stream üzerinden bir hata olayı gönderildiğinde çalışır.
    // err parametresi oluşan hatayı temsil eder.
    // Hata bilgisini konsola yazdırır.
    onError: (err) => print("Hata oluştu: $err"),

    // Stream tamamlandığında ve kapanış olayı dinleyiciye ulaştığında çalışır.
    // Yayının sona erdiğini konsola yazdırır.
    onDone: () => print("Yayın tamamlandı"),
  );

  // sink, StreamController'a veri göndermek için kullanılır..

  controller.sink.add(10);
  controller.sink.add(20); //veri akışına 10 20 30 değerleini eklerler.
  controller.sink.add(30);

  // hem çoğul hem tekil aynı func içinde dinlemez
  //tekliler çoklunun içine gömülebilir
  //aynı anda çoğul dinleme

  final broadcastStream = controller.stream.asBroadcastStream(); //asBroadcastStream(); tek abonelikli bir streami birden fazla dinleyiciye yayın yapabilen broadcastStreame dönüştürür.

  broadcastStream.listen((d) => print("UI Ekranı :$d")); //broadacaststreame bir dinleyici bağlar. d parametresi akıştan gelen veriyii temsil eder. Bu dinleyici geriye dönük olarak önceki veriler almaz.

  broadcastStream.listen((d) => print("ANALİTİK SERVİS EKRANI :$d")); //aynı broadcaststreame ikinci dinleyici bağlar. broadcast stream birden fazla dinleyiciyi destekler.

  controller.close(); //StreamControler kapanır. controler üzerinden yeni veri gönderilemez. önceden eklenen olayların dinleyicilere iletilmesi tamamlanabilir.
}
