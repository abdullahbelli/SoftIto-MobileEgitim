import 'package:firebase_messaging/firebase_messaging.dart'; // firebase üzerinden push bildirim almak için kullanılan paket
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // cihaz üzerinde yerel bildirim göstermek için kullanılan paket

@pragma(
  'vm:entry-point',
) // arka plan fonksiyonunun release modunda kaldırılmasını önler
Future<void> fcmBackgroundHandler(RemoteMessage message) async {} // firebase arka plan mesajlarını karşılayan sınıf dışı fonksiyon

class FcmBildirimServisi {
  // firebase ve yerel bildirim işlemlerini yöneten servis sınıfı
  final FirebaseMessaging _fcm = FirebaseMessaging
      .instance; // firebase mesajlaşma servisinin mevcut örneğini alır
  final FlutterLocalNotificationsPlugin
  _localPlugin = // yerel bildirim eklentisini tutan değişken
      FlutterLocalNotificationsPlugin(); // yerel bildirim işlemleri için nesne oluşturur

  Future<void> baslat({
    // bildirim sistemini başlatan asenkron metot
    required Function(RemoteMessage message)
    onMesajGeldi, // mesaj geldiğinde çalıştırılacak zorunlu callback fonksiyonu
  }) async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    ); // kullanıcıdan bildirim gösterme, rozet ve ses izinlerini ister

    const androidSettings = AndroidInitializationSettings(
      // android başlangıç bildirim ayarlarını oluşturur
      '@mipmap/ic_launcher', // bildirim simgesi olarak uygulama ikonunu kullanır
    );
    const iosSettings = DarwinInitializationSettings(); // ios için başlangıç ayarlarını oluşturur
    const initSettings = InitializationSettings(
      // platform ayarlarını tek nesnede toplar
      android: androidSettings, // android bildirim ayarlarını tanımlar
      iOS: iosSettings, // ios bildirim ayarlarını tanımlar
    );

    await _localPlugin.initialize(
      initSettings,
    ); // yerel bildirim sistemini verilen ayarlarla başlatır

    FirebaseMessaging.onMessage.listen((message) {
      // uygulama ön plandayken gelen firebase mesajlarını dinler
      _yerelBildirimGoster(
        message,
      ); // gelen mesajı cihazda yerel bildirim olarak gösterir
      onMesajGeldi(
        message,
      ); // gelen mesajı dışarıdan verilen callback fonksiyonuna iletir
    });

    FirebaseMessaging.onBackgroundMessage(
      fcmBackgroundHandler,
    ); // arka plan mesajlarını işleyecek fonksiyonu kaydeder
  }

  Future<void> konuyaAboneOl(String konu) async {
    // belirtilen bildirim konusuna abone olan metot
    await _fcm.subscribeToTopic(
      konu,
    ); // cihazı firebase üzerindeki ilgili konuya abone eder
  }

  Future<void> konudanAyril(String konu) async {
    // belirtilen bildirim konusundan ayrılan metot
    await _fcm.unsubscribeFromTopic(
      konu,
    ); // cihazın ilgili konu aboneliğini kaldırır
  }

  Future<void> _yerelBildirimGoster(RemoteMessage message) async {
    // firebase mesajını yerel bildirime dönüştüren özel metot
    const androidDetails = AndroidNotificationDetails(
      // android bildirim kanalının özelliklerini belirler
      'softito_cm_channel_id', // bildirim kanalının benzersiz kimliği
      'Softito Bildirimleri', // bildirim kanalının kullanıcıya görünen adı
      channelDescription:
          'fcm Push Bildirimleri', // bildirim kanalının açıklaması
      importance: Importance.max, // bildirimin önem seviyesini en yüksek yapar
      priority: Priority.high, // bildirimin önceliğini yüksek olarak ayarlar
    );

    const details = NotificationDetails(
      // platformlara ait bildirim detaylarını birleştirir
      android: androidDetails, // android bildirim özelliklerini kullanır
      iOS: DarwinNotificationDetails(), // ios için bildirim detaylarını oluşturur
    );

    await _localPlugin.show(
      // bildirimi ekranda gösterir ve işlemin tamamlanmasını bekler
      message
          .hashCode, // mesajın hash değerini bildirim kimliği olarak kullanır
      message.notification?.title ??
          'Yeni Bildirim', // mesaj başlığı yoksa varsayılan başlığı kullanır
      message.notification?.body ??
          '', // mesaj içeriği yoksa boş metin kullanır
      details, // oluşturulan bildirim ayarlarını kullanır
    ); // derste yaptığımız show la arsındaki fark birnde isimlendirilmiş parametreler bunda konumsal parametreler kullanılıyor
  }
}
/*Konumsal parametre (Positional): Değerler sırasına göre gönderilir, parametre isimleri yazılmaz ve sıralama önemlidir.

İsimlendirilmiş parametre (Named): Değerler parametre isimleri belirtilerek gönderilir, sıralama önemli değildir ve required ile zorunlu yapılabilir. */
