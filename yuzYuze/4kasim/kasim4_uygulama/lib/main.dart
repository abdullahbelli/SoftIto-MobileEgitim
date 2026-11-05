import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'screens/storage_ve_fcm_ekrani.dart';

// uygulamanın başlangıç noktası
void main() async {
  // flutter motoru ile widget sistemi arasındaki bağlantıyı hazırlar
  // runApp çalışmadan önce firebase gibi asenkron işlemlerin yapılabilmesini sağlar
  WidgetsFlutterBinding.ensureInitialized(); //açıkla burayı

  // firebase başlatılırken oluşabilecek hataları yakalar
  try {
    // firebase uygulamasını mevcut platformun yapılandırmasıyla başlatır
    await Firebase.initializeApp(
      // android, ios, macos veya diğer platforma uygun firebase ayarlarını seçer
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // firebase başlatılırken oluşan hataları yakalar
  } catch (_) {}

  // flutter uygulamasının ana widgetını çalıştırır
  runApp(const SofitoFcmDemoApplication());
}

// uygulamanın ana widget sınıfı
// statelesswidget olduğu için kendi içerisinde değişebilen state tutmaz
class SofitoFcmDemoApplication extends StatelessWidget {
  // widgetın kurucu metodu ve isteğe bağlı key parametresi
  const SofitoFcmDemoApplication({super.key});

  // uygulamanın kullanıcı arayüzünü oluşturan metot
  @override
  Widget build(BuildContext context) {
    // uygulamanın tema, başlık ve başlangıç ekranını belirler
    return MaterialApp(
      // sağ üst köşedeki debug yazısını gizler
      debugShowCheckedModeBanner: false,

      // uygulamanın başlığını belirler
      title: "Softito FCM Demo Application",

      // uygulamanın genel tema ayarlarını oluşturur
      theme: ThemeData(
        // uygulamanın renk paletini belirler
        colorScheme: ColorScheme.fromSeed(
          // tema renklerinin oluşturulmasında kullanılacak ana rengi belirler
          seedColor: const Color.fromARGB(0, 0, 0, 0),

          // uygulamanın açık tema kullanmasını sağlar
          brightness: Brightness.light,
        ),

        // material design 3 tasarım sistemini etkinleştirir
        useMaterial3: true,
      ),

      // uygulama açıldığında gösterilecek ilk ekranı belirler
      home: const StorageVeFcmEkrani(),
    );
  }
}

// soru: WidgetsFlutterBinding.ensureInitialized() ne işe yarar
// flutter framework ile flutter motoru arasındaki bağlantıyı hazırlar
// main içerisinde runApp öncesinde platform servisleri kullanılacaksa gereklidir
// firebase initializeApp gibi işlemlerden önce çağrılarak sistemin hazır olması sağlanır

// soru: main metodu neden async olarak tanımlandı
// firebase başlatma işlemi asenkron olarak gerçekleştirilir
// async sayesinde await kullanılarak firebase başlatılana kadar beklenebilir
// böylece normal akışta firebase başlatıldıktan sonra runApp çalıştırılır

// soru: try catch içerisindeki _ ne anlama gelir
// alt çizgi yakalanan hata değerinin kullanılmayacağını belirtir
// catch bloğu boş olduğu için hata oluşsa bile herhangi bir işlem yapılmaz
// firebase başlatılamasa bile uygulama runApp ile çalıştırılmaya devam eder

// soru: DefaultFirebaseOptions.currentPlatform ne işe yarar
// uygulamanın çalıştığı platformu tespit ederek uygun firebase ayarlarını döndürür
// android ios macos web ve yapılandırılmış diğer platformların ayarlarını seçer
// bu ayarlar flutterfire cli tarafından oluşturulan firebase_options.dart dosyasında bulunur
