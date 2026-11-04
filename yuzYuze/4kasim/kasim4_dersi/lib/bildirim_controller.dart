import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // cihaz üzerinde yerel bildirim göstermek için kullanılan paket
import 'package:firebase_messaging/firebase_messaging.dart'; // firebase üzerinden gelen bildirim mesajlarını yönetir

class YerelBildirimYoneticisi {
  // yerel bildirim işlemlerini yöneten sınıf
  static final FlutterLocalNotificationsPlugin
  _yerelBildirim = // sınıfa ait tek bir bildirim nesnesi oluşturur
      FlutterLocalNotificationsPlugin(); // yerel bildirim eklentisinin örneğini oluşturur

  static Future<void> kurulum() async {
    // bildirim ayarlarını asenkron olarak başlatan metot
    const androidAyarlar = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    ); // android bildirimlerinde kullanılacak uygulama simgesini belirler
    const iosAyarlar = DarwinInitializationSettings(); // ios cihazları için başlangıç ayarlarını oluşturur
    const ayarlar = InitializationSettings(
      // platformlara ait ayarları tek nesnede toplar
      android: androidAyarlar, // android ayarlarını tanımlar
      iOS: iosAyarlar, // ios ayarlarını tanımlar
      //macos iosla aynı çalışır
    );
    await _yerelBildirim.initialize(
      // bildirim sisteminin kurulmasını bekler
      settings: ayarlar, // oluşturulan başlangıç ayarlarını gönderir
    ); //ayarlar yerinde settings yazsaydık anlardı
  }

  static Future<void> bildirimGoster(RemoteMessage message) async {
    // firebase mesajını alıp yerel bildirim olarak gösteren metot
    const androidDetay = AndroidNotificationDetails(
      // android bildirim kanalının özelliklerini tanımlar
      'softito_kanal_id', // bildirim kanalının benzersiz kimliği
      'Softito Bildirimleri', // bildirim kanalının kullanıcıya görünen adı
      importance: Importance.max, // bildirime en yüksek önem seviyesini verir
      priority:
          Priority.high, // bildirimin yüksek öncelikle gösterilmesini sağlar
      playSound: true, // bildirim geldiğinde ses çalınmasını sağlar
    );
    const detaylar = NotificationDetails(
      android: androidDetay,
    ); // android bildirim özelliklerini genel bildirim ayarlarına ekler
    await _yerelBildirim.show(
      // bildirimi cihazda gösterir ve işlemin tamamlanmasını bekler
      id: message
          .hashCode, // mesajın hash değerini bildirim kimliği olarak kullanır
      title:
          message.notification?.title ??
          'Yeni Bildirim', // başlık yoksa varsayılan başlığı kullanır
      body:
          message.notification?.body ??
          '', // bildirim içeriği yoksa boş metin kullanır
      notificationDetails:
          detaylar, // bildirimin görünüm ve davranış ayarlarını gönderir
    );
  }
}
