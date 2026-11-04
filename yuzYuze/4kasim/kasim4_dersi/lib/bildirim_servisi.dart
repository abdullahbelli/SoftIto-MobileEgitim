import 'package:firebase_messaging/firebase_messaging.dart';

@pragma('vm:entry-point') //her şeyden bağımsız bir şekilde arka planda çalışmasını sağlar
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async{
  print("Arka planda biliirm geldi: ${message.notification?.title}"); //en üsttee yazılması lazım  nedeni ?
}

class BildirimServisi {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> baslat()async{
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if(settings.authorizationStatus == AuthorizationStatus.authorized){
      print("Kullanıcı Bildirim izni verdi.");
    }
    final token = await _fcm.getToken();
    print("Cihazın FCM tokenı : $token");
  }
}
