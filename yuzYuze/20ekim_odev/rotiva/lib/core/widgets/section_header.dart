import 'package:flutter/material.dart'; // Material Design arayüz bileşenleri.

/// Sayfalarda bölüm başlığı, açıklama metni ve varsa sağ aksiyon butonu gösteren tekrar kullanılabilir bileşen.
class SectionHeader extends StatelessWidget {
  final String title; // Bölümün ana başlığı (Örn: 'Son Kiralama Hareketleri')
  final String? subtitle; // Başlığın altındaki açıklayıcı küçük metin
  final Widget? trailing; // Başlığın sağ tarafına konulabilecek ek buton veya etiket (Örn: 'Tümünü Gör')
  final EdgeInsetsGeometry padding; // Başlığın dış boşluğu

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Tema tipografi stillerini almak için

    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Başlık ve alt başlığı barındıran genişleyebilir alan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ana Bölüm Başlığı
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
                // Varsa alt başlık metni
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Sağ tarafa eklenmiş trailing widget (buton vb.) varsa ekliyoruz
          ?trailing,
        ],
      ),
    );
  }
}
