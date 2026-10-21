import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../core/widgets/app_logo.dart';
import '../controllers/auth_controller.dart';

/// Şifremi Unuttum Ekranı
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _codeSent = false;
  Timer? _timer;
  int _remainingSeconds = AppConstants.otpDurationSeconds;
  bool _isLoading = false;

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = AppConstants.otpDurationSeconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _handleSendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli bir e-posta adresi girin.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .sendPasswordResetOtp(email);
      setState(() {
        _codeSent = true;
      });
      _startCountdown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '6 haneli şifre sıfırlama kodu gönderildi (Demo: 123456).',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleVerifyCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6) return;

    final email = _emailController.text.trim();
    setState(() => _isLoading = true);
    try {
      final isValid = await ref
          .read(authControllerProvider.notifier)
          .verifyOtp(email, code);

      if (isValid && mounted) {
        context.push('/reset-password', extra: {'email': email, 'code': code});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCodeComplete = _codeController.text.trim().length == 6;

    return Scaffold(
      appBar: AppBar(title: const AppLogo(size: 30), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Card(
                elevation: isDark ? 2 : 0,
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.grey.withValues(alpha: 0.2),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 40,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.15,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_reset_rounded,
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'Şifremi Unuttum',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Hesabınıza bağlı e-posta adresinizi girerek 6 haneli sıfırlama kodu talep edin.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      // E-posta alanı
                      TextField(
                        controller: _emailController,
                        enabled: !_codeSent,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-posta Adresi',
                          prefixIcon: Icon(Icons.mail_outline_rounded),
                        ),
                      ),
                      const SizedBox(height: 18),

                      if (!_codeSent) ...[
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleSendCode,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text('Doğrulama Kodu Gönder'),
                        ),
                      ] else ...[
                        // 6 Haneli Kod Alanı
                        TextField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 6,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: const TextStyle(
                            fontSize: 26,
                            letterSpacing: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            labelText: '6 Haneli Kod',
                            counterText: '',
                            hintText: '000000',
                            hintStyle: TextStyle(
                              color: Colors.grey.withValues(alpha: 0.4),
                              letterSpacing: 10,
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),

                        // Sayaç
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: 18,
                              color: _remainingSeconds > 0
                                  ? theme.colorScheme.primary
                                  : Colors.redAccent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Kalan Süre: $_formattedTime',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _remainingSeconds > 0
                                    ? theme.colorScheme.primary
                                    : Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (_remainingSeconds == 0)
                          TextButton.icon(
                            onPressed: _handleSendCode,
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Tekrar Kod Gönder'),
                          ),
                        const SizedBox(height: 16),

                        ElevatedButton(
                          onPressed: (isCodeComplete && !_isLoading)
                              ? _handleVerifyCode
                              : null,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.black,
                                  ),
                                )
                              : const Text('Kodu Doğrula ve Devam Et'),
                        ),
                      ],
                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Giriş Ekranına Dön'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
