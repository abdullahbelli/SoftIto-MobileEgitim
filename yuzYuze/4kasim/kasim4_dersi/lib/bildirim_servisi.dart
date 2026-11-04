import 'package:firebase_messaging/firebase_messaging.dart'; // firebase cloud messaging işlemleri için kullanılan paket

@pragma(
  'vm:entry-point',
) //her şeyden bağımsız bir şekilde arka planda çalışmasını sağlar
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // uygulama arka plandayken gelen mesajları işleyen üst seviye fonksiyon
  print("Arka planda biliirm geldi: ${message.notification?.title}"); //en üsttee yazılması lazım  nedeni ? çünkü firebase arka planda ayrı bir isolate çalıştırır ve sınıf içindeki metotlara doğrudan erişemez bu yüzden fonksiyon sınıf dışında tanımlanmalıdır
}

class BildirimServisi {
  // firebase bildirim işlemlerini yöneten servis sınıfı
  final FirebaseMessaging _fcm = FirebaseMessaging
      .instance; // firebase mesajlaşma servisinin mevcut örneğini alır

  Future<void> baslat() async {
    // bildirim izinlerini ve cihaz tokenını alan asenkron metot
    NotificationSettings settings = await _fcm.requestPermission(
      // kullanıcıdan bildirim izni ister ve sonucu bekler
      alert: true, // ekranda bildirim gösterilmesine izin ister
      badge:
          true, // uygulama simgesinde bildirim rozeti gösterilmesine izin ister
      sound: true, // bildirim sesi çalınmasına izin ister
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // kullanıcının bildirim izni verip vermediğini kontrol eder
      print(
        "Kullanıcı Bildirim izni verdi.",
      ); // izin verildiğinde konsola bilgi yazar
    }
    final token = await _fcm
        .getToken(); // cihazın firebase mesajlaşma tokenını alır
    print("Cihazın FCM tokenı : $token"); // alınan tokenı konsola yazdırır
  }
}
