
import 'dart:io'; // macOS ve iOS platformlarını kontrol etmek için kullanılır
import 'package:flutter/foundation.dart'; // debugPrint ile konsola bilgi yazdırmak için kullanılır
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

  // macOS ve iOS için APNs token hazır olana kadar bekler.
  Future<void> _apnsTokenBekle() async {
    if (!Platform.isMacOS && !Platform.isIOS) return;

    for (int i = 0; i < 10; i++) {
      final token = await _fcm.getAPNSToken();

      if (token != null) {
        debugPrint('FCM: APNs token başarıyla alındı.');
        return;
      }

      debugPrint('FCM: APNs token bekleniyor... ${i + 1}/10');

      await Future.delayed(const Duration(seconds: 1));
    }

    throw StateError(
      'APNs token alınamadı. Apple Push Notifications '
      've Firebase yapılandırmasını kontrol edin.',
    );
  }

  Future<void> baslat({
    // bildirim sistemini başlatan asenkron metot
    required Function(RemoteMessage message)
    onMesajGeldi, // mesaj geldiğinde çalıştırılacak zorunlu callback fonksiyonu
  }) async {
    debugPrint('FCM: Bildirim sistemi başlatılıyor...');

    final izin = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    ); // kullanıcıdan bildirim gösterme, rozet ve ses izinlerini ister

    debugPrint('FCM: Bildirim izin durumu: ${izin.authorizationStatus}');

    const androidSettings = AndroidInitializationSettings(
      // android başlangıç bildirim ayarlarını oluşturur
      '@mipmap/ic_launcher', // bildirim simgesi olarak uygulama ikonunu kullanır
    );
    const iosSettings = DarwinInitializationSettings(); // ios için başlangıç ayarlarını oluşturur
    const initSettings = InitializationSettings(
      // platform ayarlarını tek nesnede toplar
      android: androidSettings, // android bildirim ayarlarını tanımlar
      iOS: iosSettings, // ios bildirim ayarlarını tanımlar
      macOS: iosSettings, // macOS için yerel bildirim ayarlarını tanımlar
    );

    await _localPlugin.initialize(
      initSettings,
    ); // yerel bildirim sistemini verilen ayarlarla başlatır

    debugPrint('FCM: Yerel bildirim sistemi hazır.');

    FirebaseMessaging.onMessage.listen((message) {
      // uygulama ön plandayken gelen firebase mesajlarını dinler
      debugPrint('FCM: Yeni mesaj geldi: ${message.messageId}');

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

    debugPrint('FCM: Mesaj dinleyicileri hazır.');
  }

  Future<String?> tokenAl() async {
    try {
      await _apnsTokenBekle();

      final token = await _fcm.getToken();

      debugPrint(
        token == null
            ? 'FCM: Firebase token alınamadı.'
            : 'FCM: Firebase token başarıyla alındı.',
      );

      return token;
    } catch (e) {
      debugPrint('FCM TOKEN HATASI: $e');
      return null;
    }
  }

  Future<void> konuyaAboneOl(String konu) async {
    // belirtilen bildirim konusuna abone olan metot
    debugPrint('FCM: $konu konusuna abone olunuyor...');

    try {
      await _apnsTokenBekle();

      await _fcm.subscribeToTopic(
        konu,
      ); // cihazı firebase üzerindeki ilgili konuya abone eder

      debugPrint('FCM: $konu aboneliği başarılı.');
    } catch (e) {
      debugPrint('FCM ABONELİK HATASI: $e');
      rethrow;
    }
  }

  Future<void> konudanAyril(String konu) async {
    // belirtilen bildirim konusundan ayrılan metot
    debugPrint('FCM: $konu aboneliğinden ayrılıyor...');

    try {
      await _apnsTokenBekle();

      await _fcm.unsubscribeFromTopic(
        konu,
      ); // cihazın ilgili konu aboneliğini kaldırır

      debugPrint('FCM: $konu aboneliği iptal edildi.');
    } catch (e) {
      debugPrint('FCM ABONELİKTEN AYRILMA HATASI: $e');
      rethrow;
    }
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
      macOS: DarwinNotificationDetails(), // macOS için bildirim detaylarını oluşturur
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
