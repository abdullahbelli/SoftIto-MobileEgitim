/*Future<void> fetchDashboardData() async {
  try {
    final result=await Future.wait([
      fetchUserProfile(),
      fetchAccountBalance(),
      fetchNotification(),
    ],eagerError:   true);
    print("Tüm veriler geldi $result");
  } catch (e) {
    print("İsteklerden biri başarısız oldu $e");
  }
}*/

//Future TEK BİR kere veri çekileceği zaman kullanılır ya hata ya da değer dönüp bitirir.
//sTREAM: Bir boru hattı şeklinde çalışır (pipe) , zaman içinde 1 10 100 ya da sonsuz sayıda veri akışı sağlanabilir.
//(Borsa fiyatları , gps KONUM GÜNCELLERKEN, fİREBASE TARAFINDAN CANLI DİNLEME)

import 'dart:async';

void main(){
  //controller oluşturma
  final controller=StreamController<int>();
  //dinleyici (listener) bağlama
  final subscription =controller.stream.listen(
    (data)=>print("Yeni Veri: $data"),
    onError: (err)=>print("Hata oluştu: $err"),
    onDone: ()=>print("Yayın tamamlandı"),
  );

  controller.sink.add(10);
  controller.sink.add(20);
  controller.sink.add(30);
  // hem çoğul hem tekil aynı func içinde dinlemez
  //tekliler çoklunun içine gömülebilir
  //aynı anda çoğul dinleme 
  final broadcastStream = controller.stream.asBroadcastStream();
  broadcastStream.listen((d) => print("UI Ekranı :$d"));
  broadcastStream.listen((d) => print("ANALİTİK SERVİS EKRANI :$d"));



  controller.close();





}