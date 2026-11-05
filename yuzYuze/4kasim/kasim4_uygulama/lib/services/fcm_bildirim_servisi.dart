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
    // platform macos veya ios değilse metodu sonlandırır
    if (!Platform.isMacOS && !Platform.isIOS) return;

    // apns token almak için en fazla 10 kez deneme yapar
    for (int i = 0; i < 10; i++) {
      // apple push notification servisinden token bilgisini ister
      final token = await _fcm.getAPNSToken();

      // token başarıyla alınmışsa koşula girer
      if (token != null) {
        // token alındığını konsola yazdırır
        debugPrint('FCM: APNs token başarıyla alındı.');

        // token alındığı için bekleme işlemini sonlandırır
        return;
      }

      // kaçıncı denemenin yapıldığını konsola yazdırır
      debugPrint('FCM: APNs token bekleniyor... ${i + 1}/10');

      // sonraki denemeden önce 1 saniye bekler
      await Future.delayed(const Duration(seconds: 1));
    }

    // tüm denemeler başarısız olursa hata oluşturur
    throw StateError(
      // hata mesajının ilk bölümünü tanımlar
      'APNs token alınamadı. Apple Push Notifications '
      // hata mesajının devamını tanımlar
      've Firebase yapılandırmasını kontrol edin.',
    );
  }

  Future<void> baslat({
    // bildirim sistemini başlatan asenkron metot
    required Function(RemoteMessage message)
    onMesajGeldi, // mesaj geldiğinde çalıştırılacak zorunlu callback fonksiyonu
  }) async {
    // bildirim sisteminin başlatıldığını konsola yazdırır
    debugPrint('FCM: Bildirim sistemi başlatılıyor...');

    // kullanıcıdan bildirim izinlerini ister ve sonucu izin değişkenine kaydeder
    final izin = await _fcm.requestPermission(
      // bildirimlerin ekranda uyarı olarak gösterilmesine izin ister
      alert: true,
      // uygulama simgesi üzerinde bildirim rozeti gösterilmesine izin ister
      badge: true,
      // bildirim geldiğinde ses çalınmasına izin ister
      sound: true,
    ); // kullanıcıdan bildirim gösterme, rozet ve ses izinlerini ister

    // kullanıcının bildirim izni durumunu konsola yazdırır
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

    // yerel bildirim eklentisinin başlangıç ayarlarını uygular
    await _localPlugin.initialize(
      // android, ios ve macos için hazırlanan ayarları gönderir
      initSettings,
    ); // yerel bildirim sistemini verilen ayarlarla başlatır

    // yerel bildirim sisteminin hazır olduğunu konsola yazdırır
    debugPrint('FCM: Yerel bildirim sistemi hazır.');

    FirebaseMessaging.onMessage.listen((message) {
      // uygulama ön plandayken gelen firebase mesajlarını dinler
      // gelen mesajın kimliğini konsola yazdırır
      debugPrint('FCM: Yeni mesaj geldi: ${message.messageId}');

      _yerelBildirimGoster(
        // gelen firebase mesajını yerel bildirim metoduna gönderir
        message,
      ); // gelen mesajı cihazda yerel bildirim olarak gösterir
      onMesajGeldi(
        // gelen mesajı ekranın bildirim listesine aktarılması için callback fonksiyonuna gönderir
        message,
      ); // gelen mesajı dışarıdan verilen callback fonksiyonuna iletir
    });

    FirebaseMessaging.onBackgroundMessage(
      // uygulama arka plandayken çalıştırılacak fonksiyonu belirtir
      fcmBackgroundHandler,
    ); // arka plan mesajlarını işleyecek fonksiyonu kaydeder

    // firebase mesaj dinleyicilerinin hazır olduğunu konsola yazdırır
    debugPrint('FCM: Mesaj dinleyicileri hazır.');
  }

  // cihazın firebase cloud messaging token bilgisini alan asenkron metot
  Future<String?> tokenAl() async {
    // token alınırken oluşabilecek hataları yakalamak için try bloğu
    try {
      // ios ve macos platformlarında apns token hazır olana kadar bekler
      await _apnsTokenBekle();

      // cihazın firebase token bilgisini alır
      final token = await _fcm.getToken();

      // token durumuna göre konsola yazdırılacak mesajı belirler
      debugPrint(
        // token null ise hata mesajını, değilse başarı mesajını seçer
        token == null
            ? 'FCM: Firebase token alınamadı.'
            : 'FCM: Firebase token başarıyla alındı.',
      );

      // alınan token bilgisini metodu çağıran yere döndürür
      return token;

      // token alma işleminde oluşan hatayı yakalar
    } catch (e) {
      // oluşan hatayı konsola yazdırır
      debugPrint('FCM TOKEN HATASI: $e');

      // hata oluştuğunda token yerine null döndürür
      return null;
    }
  }

  Future<void> konuyaAboneOl(String konu) async {
    // belirtilen bildirim konusuna abone olan metot
    // abone olunacak konu adını konsola yazdırır
    debugPrint('FCM: $konu konusuna abone olunuyor...');

    // abonelik sırasında oluşabilecek hataları yakalamak için try bloğu
    try {
      // ios ve macos platformlarında apns token hazır olana kadar bekler
      await _apnsTokenBekle();

      // firebase üzerinden belirtilen konuya abonelik başlatır
      await _fcm.subscribeToTopic(
        // abonelik yapılacak konu adını gönderir
        konu,
      ); // cihazı firebase üzerindeki ilgili konuya abone eder

      // aboneliğin başarılı olduğunu konsola yazdırır
      debugPrint('FCM: $konu aboneliği başarılı.');

      // abonelik sırasında oluşan hatayı yakalar
    } catch (e) {
      // abonelik hatasını konsola yazdırır
      debugPrint('FCM ABONELİK HATASI: $e');

      // hatayı metodu çağıran yere yeniden iletir
      rethrow;
    }
  }

  Future<void> konudanAyril(String konu) async {
    // belirtilen bildirim konusundan ayrılan metot
    // abonelikten çıkılacak konuyu konsola yazdırır
    debugPrint('FCM: $konu aboneliğinden ayrılıyor...');

    // abonelikten ayrılma sırasında oluşabilecek hataları yakalar
    try {
      // ios ve macos platformlarında apns token hazır olana kadar bekler
      await _apnsTokenBekle();

      // firebase üzerinden belirtilen konu aboneliğini kaldırır
      await _fcm.unsubscribeFromTopic(
        // abonelikten çıkılacak konu adını gönderir
        konu,
      ); // cihazın ilgili konu aboneliğini kaldırır

      // abonelikten başarıyla çıkıldığını konsola yazdırır
      debugPrint('FCM: $konu aboneliği iptal edildi.');

      // abonelikten ayrılma sırasında oluşan hatayı yakalar
    } catch (e) {
      // oluşan hatayı konsola yazdırır
      debugPrint('FCM ABONELİKTEN AYRILMA HATASI: $e');

      // yakalanan hatayı metodu çağıran yere yeniden iletir
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
