import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_constants.dart';
import '../../../../core/widgets/app_logo.dart';
import '../controllers/auth_controller.dart';

/// E-posta Doğrulama Kodu Ekranı (6 Haneli, 90 Saniyelik OTP)
class OtpVerificationScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> registrationData;

  const OtpVerificationScreen({super.key, required this.registrationData});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _codeController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = AppConstants.otpDurationSeconds; // 90 saniye
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
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

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _handleConfirm() async {
    final code = _codeController.text.trim();
    if (code.length != 6) return;

    setState(() => _isLoading = true);
    final email = widget.registrationData['email'] as String? ?? '';

    try {
      final isValid = await ref
          .read(authControllerProvider.notifier)
          .verifyOtp(email, code);

      if (isValid) {
        // Kayıt işlemini tamamla
        await ref
            .read(authControllerProvider.notifier)
            .register(
              email: email,
              password: widget.registrationData['password'] as String? ?? '',
              username: widget.registrationData['username'] as String? ?? '',
              firstName: widget.registrationData['firstName'] as String? ?? '',
              lastName: widget.registrationData['lastName'] as String? ?? '',
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'E-posta başarıyla doğrulandı ve hesabınız oluşturuldu!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/rooms');
        }
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

  Future<void> _handleResend() async {
    final email = widget.registrationData['email'] as String? ?? '';
    await ref.read(authControllerProvider.notifier).sendVerificationOtp(email);
    _startCountdown();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yeni doğrulama kodu gönderildi (Demo: 123456).'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final email =
        widget.registrationData['email'] as String? ?? 'eposta@alanadi.com';
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
                          Icons.mark_email_read_outlined,
                          size: 30,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'E-posta Doğrulama Kodu',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      Text(
                        '$email adresine gönderilen 6 haneli doğrulama kodunu girin.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Demo İpucu Bilgilendirmesi
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Demo modu: Kod "123456" veya herhangi 6 haneli sayıdır.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.amber.shade200
                                      : Colors.amber.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 6 Haneli Kod Girişi
                      TextField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 28,
                          letterSpacing: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '000000',
                          hintStyle: TextStyle(
                            color: Colors.grey.withValues(alpha: 0.4),
                            letterSpacing: 12,
                          ),
                        ),
                        onChanged: (val) {
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 16),

                      // Sayaç Alanı (dakika:saniye formatı)
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
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _remainingSeconds > 0
                                  ? theme.colorScheme.primary
                                  : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Süre bitince Tekrar Gönder butonu
                      if (_remainingSeconds == 0)
                        TextButton.icon(
                          onPressed: _handleResend,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('Tekrar Kod Gönder'),
                        ),
                      const SizedBox(height: 18),

                      // Onayla Butonu (Kod 6 haneli değilse pasif)
                      ElevatedButton(
                        onPressed: (isCodeComplete && !_isLoading)
                            ? _handleConfirm
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
                            : const Text('Onayla'),
                      ),
                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Bilgileri Değiştir'),
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
