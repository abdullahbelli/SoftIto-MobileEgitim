import 'package:flutter/material.dart'; // Flutter Material Design arayüz bileşenleri.

/// Liste boş olduğunda veya arama sonucu bulunamadığında gösterilen şık boş durum (Empty State) widget'ı.
class EmptyStateView extends StatelessWidget {
  final IconData icon; // Ortada gösterilecek büyük simge
  final String title; // Boş durum başlığı (Örn: "Uygun Araç Bulunamadı")
  final String message; // Açıklayıcı ve yönlendirici alt metin
  final String?
  buttonText; // Opsiyonel aksiyon butonu yazısı (Örn: "Filtreleri Sıfırla")
  final VoidCallback?
  onButtonPressed; // Butona basıldığında tetiklenecek fonksiyon

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Aktif temayı alıyoruz.

    return Center(
      // Küçük ekranlarda taşma olmaması için içeriği kaydırılabilir yapıyoruz.
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Yuvarlak arka planlı büyük ikon kutusu
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 54, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 20),
            // Kalın ana başlık
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            // Açıklama metni
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            // Eğer aksiyon butonu ve fonksiyonu tanımlanmışsa butonu gösteriyoruz
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonal(
                onPressed: onButtonPressed,
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
