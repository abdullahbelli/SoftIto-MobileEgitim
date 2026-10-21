import 'package:flutter/material.dart'; // Flutter'ın temel Material Design bileşenlerini ve arayüz araçlarını içe aktarır.
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod durum yönetimi (state management) paketini içe aktarır.
import 'package:shared_preferences/shared_preferences.dart'; // Cihaz hafızasında anahtar-değer (key-value) çiftiyle veri saklamayı sağlayan paketi içe aktarır.

import 'app/app.dart'; // Uygulamanın ana MaterialApp yapılandırmasını içeren widget'ı içe aktarır.
import 'app/theme/theme_provider.dart'; // Tema sağlayıcısını ve SharedPreferences Riverpod provider'ını içe aktarır.

/// BoardConnect Uygulaması Giriş Noktası
/// Dart programlama dilinde her uygulama 'main' fonksiyonu ile çalışmaya başlar.
/// 'async' anahtar kelimesi, fonksiyon içerisinde zaman alan (asenkron) işlemlerin 'await' ile beklenebileceğini belirtir.
Future<void> main() async {
  // Flutter motoru ile widget ağacı arasındaki iletişimin (binding) uygulamanın başında başlatıldığını garanti eder.
  // Asenkron işlemler (SharedPreferences vb.) runApp çağrısından önce çalıştırılacaksa bu satır zorunludur.
  WidgetsFlutterBinding.ensureInitialized();

  // SharedPreferences örneğini asenkron olarak cihazdan yükler ve 'prefs' değişkenine atar.
  final prefs = await SharedPreferences.getInstance();

  // Uygulamanın kök widget'ını başlatır ve ekrana çizer.
  runApp(
    // Riverpod durum yönetiminin tüm widget ağacında çalışabilmesi için uygulamayı sarmalayan sağlayıcı kapsamı.
    ProviderScope(
      // Uygulama başlarken hazır olan nesneleri (burada prefs) Riverpod ağacına başlangıç değeri olarak aktarır.
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      // Uygulamanın kök widget'ı olan BoardConnectApp'i alt eleman (child) olarak tanımlar.
      child: const BoardConnectApp(),
    ),
  );
}
