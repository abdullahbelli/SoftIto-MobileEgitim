import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../features/auth/controllers/auth_controller.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

/// Ritmia ana uygulama widget'ı.
/// Tema, yönlendirme (GoRouter) ve yerelleştirme ayarlarını bağlar.
class RitmiaApp extends StatefulWidget {
  const RitmiaApp({super.key});

  @override
  State<RitmiaApp> createState() => _RitmiaAppState();
}

class _RitmiaAppState extends State<RitmiaApp> {
  GoRouter? _router;
  AuthController? _authController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authCtrl = context.read<AuthController>();
    if (_authController != authCtrl || _router == null) {
      _authController = authCtrl;
      _router = AppRouter.createRouter(authCtrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final accentColor = themeController.currentAccentColor;

    return MaterialApp.router(
      title: 'Ritmia',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(accentColor: accentColor),
      darkTheme: AppTheme.darkTheme(accentColor: accentColor),
      themeMode: themeController.themeMode,
      routerConfig: _router,
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
