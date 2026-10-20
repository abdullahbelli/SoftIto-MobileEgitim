import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/widgets/rotiva_scope.dart';
import 'data/repositories/app_repository.dart';
import 'features/admin/view/admin_shell_screen.dart';
import 'features/auth/view/welcome_screen.dart';
import 'features/home/view/customer_shell_screen.dart';

/// Rotiva ana uygulama widget'ı.
/// Tema yönetimini, repository veri akışını ve ana rota yönlendirmesini sağlar.
class RotivaApp extends StatelessWidget {
  final AppRepository repository;
  final ThemeController themeController;

  const RotivaApp({
    super.key,
    required this.repository,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return RotivaScope(
      repository: repository,
      themeController: themeController,
      child: ListenableBuilder(
        listenable: Listenable.merge([repository, themeController]),
        builder: (context, _) {
          return MaterialApp(
            title: 'Rotiva - Araç Kiralama ve Takip',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            home: _determineInitialScreen(),
          );
        },
      ),
    );
  }

  Widget _determineInitialScreen() {
    if (!repository.isAuthenticated) {
      return const WelcomeScreen();
    }
    if (repository.isAdmin) {
      return const AdminShellScreen();
    }
    return const CustomerShellScreen();
  }
}
