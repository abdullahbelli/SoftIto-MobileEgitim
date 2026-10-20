import 'package:flutter/material.dart';

import 'rotiva_logo.dart';
import 'rotiva_scope.dart';

/// Rotiva uygulamasının tüm ekranlarında ortak kullanılan Material 3 AppBar bileşeni.
/// - Sol Alan: Rotiva özel logosu + "Rotiva" marka adı (veya sayfa başlığı) + geri butonu (alt sayfalarda)
/// - Sağ Alan: Anlık Açık / Koyu tema değiştirme butonu (Ay / Güneş simgesi) + ek aksiyonlar
class RotivaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? titleText;
  final String? subtitleText;
  final Widget? customTitle;
  final bool showLogo;
  final bool showThemeToggle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;

  const RotivaAppBar({
    super.key,
    this.titleText,
    this.subtitleText,
    this.customTitle,
    this.showLogo = true,
    this.showThemeToggle = true,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeController = RotivaScope.of(context).themeController;
    final isDark = theme.brightness == Brightness.dark;
    final canPop = Navigator.canPop(context);

    // Başlık Alanı Yapılandırması
    Widget titleWidget;
    if (customTitle != null) {
      titleWidget = customTitle!;
    } else {
      titleWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLogo) ...[
            const RotivaLogo(size: 28),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Rotiva',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.5,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (titleText != null && titleText != 'Rotiva') ...[
                      Text(
                        ' • ',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          titleText!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (subtitleText != null)
                  Text(
                    subtitleText!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading:
          leading ??
          (canPop && automaticallyImplyLeading
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  tooltip: 'Geri',
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null),
      title: titleWidget,
      centerTitle: false,
      actions: [
        ...?actions,
        if (showThemeToggle)
          IconButton(
            tooltip: isDark ? 'Açık Temaya Geç' : 'Koyu Temaya Geç',
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: isDark ? const Color(0xFFFF922B) : const Color(0xFF1565C0),
            ),
            onPressed: () => themeController.toggleTheme(),
          ),
        const SizedBox(width: 4),
      ],
      bottom: bottom,
    );
  }
}
