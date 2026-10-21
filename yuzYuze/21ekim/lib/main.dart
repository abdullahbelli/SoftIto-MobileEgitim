import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/theme/theme_provider.dart';

/// BoardConnect Uygulaması Giriş Noktası
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Yerel kalıcı veri saklama servisini başlat
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const BoardConnectApp(),
    ),
  );
}
