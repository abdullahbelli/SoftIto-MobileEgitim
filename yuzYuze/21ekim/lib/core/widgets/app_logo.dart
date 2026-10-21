import 'package:flutter/material.dart';

/// BoardConnect logo ve başlık bileşeni
class AppLogo extends StatelessWidget {
  final double size;
  final bool showTagline;
  final bool compact;

  const AppLogo({
    super.key,
    this.size = 36,
    this.showTagline = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final logoIcon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.35),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.dashboard_customize_rounded,
          size: size * 0.58,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );

    if (compact) {
      return logoIcon;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logoIcon,
        SizedBox(width: size * 0.25),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  text: 'Board',
                  style: TextStyle(
                    fontSize: size * 0.52,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                  children: [
                    TextSpan(
                      text: 'Connect',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (showTagline)
                Text(
                  'Sonsuz Ortak Tuval',
                  style: TextStyle(
                    fontSize: size * 0.26,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
