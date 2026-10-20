import 'package:flutter/material.dart';

/// Filizora Modern Marka Gradyan Şeridi (Brand Palette Bar)
class BrandPaletteBar extends StatelessWidget {
  final double height;
  final BorderRadius? borderRadius;

  const BrandPaletteBar({
    super.key,
    this.height = 3,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4F46E5), // Royal Indigo
            Color(0xFF6366F1), // Violet
            Color(0xFF06B6D4), // Cyan
            Color(0xFF10B981), // Emerald
            Color(0xFFF59E0B), // Amber
            Color(0xFFF43F5E), // Rose
          ],
        ),
      ),
    );
  }
}
