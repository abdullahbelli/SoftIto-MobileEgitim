import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/storage_ve_fcm_ekrani.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //açıkla burayı
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  } catch (_) {}
  runApp(const SofitoFcmDemoApplication());
}

class SofitoFcmDemoApplication extends StatelessWidget {
  const SofitoFcmDemoApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Softito FCM Demo Application",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(0, 0, 0, 0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
    home: const StorageVeFcmEkrani(),
    );

  }

}
