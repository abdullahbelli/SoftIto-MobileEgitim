import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dijital_gunlugum/core/theme/theme_controller.dart';

void main() {
  group('ThemeController Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Varsayılan tema modu light olmalı', () {
      final controller = ThemeController();
      expect(controller.themeMode.value, ThemeMode.light);
      controller.dispose();
    });

    test('toggleTheme temayı light ve dark arasında değiştirmeli ve kaydetmeli', () async {
      final prefs = await SharedPreferences.getInstance();
      final controller = ThemeController(prefs);

      await controller.init();
      expect(controller.themeMode.value, ThemeMode.light);

      await controller.toggleTheme();
      expect(controller.themeMode.value, ThemeMode.dark);
      expect(prefs.getString('user_theme_mode'), 'dark');

      await controller.toggleTheme();
      expect(controller.themeMode.value, ThemeMode.light);
      expect(prefs.getString('user_theme_mode'), 'light');

      controller.dispose();
    });

    test('Kayıtlı tema tercihi init ile doğru şekilde yüklenmeli', () async {
      SharedPreferences.setMockInitialValues({'user_theme_mode': 'dark'});
      final prefs = await SharedPreferences.getInstance();
      final controller = ThemeController(prefs);

      await controller.init();
      expect(controller.themeMode.value, ThemeMode.dark);
      controller.dispose();
    });
  });
}
