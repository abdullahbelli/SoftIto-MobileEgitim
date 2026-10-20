import 'package:flutter/material.dart';

import 'app.dart';
import 'core/theme/theme_controller.dart';
import 'data/repositories/app_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tema yöneticisi ve yerel veri deposunu başlat
  final themeController = ThemeController();
  await themeController.loadTheme();

  final repository = AppRepository();
  await repository.initialize();

  runApp(RotivaApp(repository: repository, themeController: themeController));
}
