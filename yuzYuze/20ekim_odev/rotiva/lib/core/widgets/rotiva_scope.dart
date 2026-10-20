import 'package:flutter/material.dart';

import '../../data/repositories/app_repository.dart';
import '../theme/theme_controller.dart';

/// Rotiva uygulama durumunu ve temasını widget ağacına aktaran InheritedWidget.
class RotivaScope extends InheritedWidget {
  final AppRepository repository;
  final ThemeController themeController;

  const RotivaScope({
    super.key,
    required this.repository,
    required this.themeController,
    required super.child,
  });

  static RotivaScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RotivaScope>();
    assert(scope != null, 'RotivaScope widget ağacında bulunamadı.');
    return scope!;
  }

  @override
  bool updateShouldNotify(RotivaScope oldWidget) {
    return repository != oldWidget.repository ||
        themeController != oldWidget.themeController;
  }
}
