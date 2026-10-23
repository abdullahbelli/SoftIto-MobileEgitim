import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/ritmia_logo.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../habits/services/motivation_service.dart';

/// Ritmia Açılış Ekranı (Splash Screen)
/// Uygulama açılırken logoyu, sloganı ve logonun altında Hugging Face'ten alınan
/// "Günün Motivasyonu" sözünü gösterir.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutBack,
      ),
    );

    _animController.forward();

    // 2.2 saniye sonra ana ekrana geçiş yap
    _navigationTimer = Timer(const Duration(milliseconds: 2200), _proceedToNextScreen);
  }

  void _proceedToNextScreen() {
    if (!mounted) return;
    _navigationTimer?.cancel();
    final authController = context.read<AuthController>();
    if (authController.isAuthenticated) {
      context.go('/habits');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final motivationService = context.watch<MotivationService>();
    final quote = motivationService.currentQuote;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _proceedToNextScreen, // Ekrana dokunarak beklemeden geçiş
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // Ritmia Modern Logo
                    Center(
                      child: Hero(
                        tag: 'ritmia_app_logo',
                        child: RitmiaLogo(
                          size: 96,
                          showText: true,
                          showSlogan: true,
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // LOGO ALTINDA GÜNÜN MOTİVASYON SÖZÜ (Hugging Face)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Başlık ve Kaynak Rozeti
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text('✨', style: TextStyle(fontSize: 12)),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Günün Motivasyonu',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Text('🤗', style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Alıntı Metni (Türkçe / Çeviri)
                          Text(
                            quote != null ? '“${quote.text}”' : '“Neredeysen, elindekilerle, yapabileceğinin en iyisini yap.”',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.45,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),

                          if (quote?.originalText != null && quote?.originalText != quote?.text) ...[
                            const SizedBox(height: 6),
                            Text(
                              '“${quote!.originalText}”',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],

                          const SizedBox(height: 10),
                          Text(
                            quote != null ? '— ${quote.author}' : '— Theodore Roosevelt',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 3),

                    // Alt Kısım: Yükleniyor / Dokun geç
                    Column(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: theme.colorScheme.primary.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Geçmek için ekrana dokunun',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
