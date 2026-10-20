import 'package:flutter/material.dart'; // Material Design bileşenleri ve PreferredSizeWidget arayüzü.

import 'rotiva_logo.dart'; // Özel vektörel Rotiva logosu.
import 'rotiva_scope.dart'; // Tema denetleyicisine erişmek için InheritedWidget kapsamı.

/// Rotiva uygulamasının tüm ekranlarında ortak kullanılan Material 3 AppBar bileşeni.
/// - Sol Alan: Rotiva özel logosu + "Rotiva" marka adı (veya sayfa başlığı) + geri butonu (alt sayfalarda)
/// - Sağ Alan: Anlık Açık / Koyu tema değiştirme butonu (Ay / Güneş simgesi) + ek aksiyonlar
/// PreferredSizeWidget arayüzü sayesinde Scaffold'ın 'appBar' parametresine doğrudan verilebilir.
class RotivaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String?
  titleText; // Ekranın başlık metni (Örn: 'Araçlar', 'Kiralamalarım')
  final String? subtitleText; // Opsiyonel alt başlık (Örn: 'Merhaba, Ahmet')
  final Widget? customTitle; // Standart başlık yerine özel widget verilmek istenirse kullanılır
  final bool showLogo; // Rotiva logosunun gösterilip gösterilmeyeceği bayrağı
  final bool showThemeToggle; // Açık/Koyu tema değiştirme butonunun gösterilip gösterilmeyeceği
  final List<Widget>?
  actions; // Sağ tarafa eklenecek ek aksiyon butonları (Örn: Çıkış yap, filtre)
  final Widget? leading; // Sol başa özel bir widget verilmek istenirse (Varsayılan: Geri oku veya logo)
  final bool automaticallyImplyLeading; // Sayfa geri dönebiliyorsa otomatik geri butonu koyma bayrağı
  final PreferredSizeWidget?
  bottom; // AppBar'ın altına eklenebilecek sekme çubuğu veya çizgi

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

  // Scaffold'ın AppBar yüksekliğini hesaplayabilmesi için gereken boyut (Standart 56dp + alt bileşen)
  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Aktif tema renk şeması
    final themeController = RotivaScope.of(context)
        .themeController; // Tema durumu yöneticisi
    final isDark =
        theme.brightness == Brightness.dark; // Koyu mod aktif mi kontrolü
    final canPop = Navigator.canPop(
      context,
    ); // Geçmişte geri dönülecek bir ekran var mı?

    // Başlık Alanı Yapılandırması: Logo ve 'Rotiva • Sayfa Adı' kombinasyonu
    Widget titleWidget;
    if (customTitle != null) {
      titleWidget = customTitle!;
    } else {
      titleWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sol taraftaki özel vektörel logo
          if (showLogo) ...[
            const RotivaLogo(size: 28),
            const SizedBox(width: 8),
          ],
          // Başlık ve alt başlık metinlerini tutan esnek sütun
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
                    // Eğer sayfa özel bir başlık belirtmişse ' • Başlık' şeklinde ekliyoruz
                    if (titleText != null && titleText != 'Rotiva') ...[
                      Text(
                        ' • ',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Uzun başlıkların ekran dışına taşmaması için Flexible ve ellipsis kullanıyoruz
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
                // Varsa alt başlık metni (Örn: karşılama mesajı)
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
      scrolledUnderElevation: 2.0, // Sayfa kaydığında içeriğin AppBar altına girmesini temiz bir gölgeyle ayırır
      elevation: 0,
      // Geri butonu: Alt sayfalarda sol tarafa geri butonu eklenir
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
      centerTitle:
          false, // Başlığı sol tarafa hizalayarak logo ile bütünleştiriyoruz
      actions: [
        ...?actions, // Varsa ek butonlar (çıkış, filtreleme vb.)
        // Anlık tema değiştirme butonu
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
