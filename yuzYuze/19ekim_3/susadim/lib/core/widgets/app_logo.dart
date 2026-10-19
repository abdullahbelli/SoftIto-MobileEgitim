import 'package:flutter/material.dart';

/// Temaya uygun uygulama logo bileşeni
class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.25),
      child: Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
