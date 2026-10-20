import 'package:flutter/material.dart'; // Material Design diyalogları ve SnackBar bileşenleri için Flutter kütüphanesi.

/// Rotiva standart diyalog (AlertDialog) ve kullanıcı bildirim (SnackBar) yardımcıları.
class RotivaDialogs {
  /// Uzun metinli kaydırılabilir bilgilendirme/sözleşme diyaloğu açar (KVKK, Açık Rıza, Kiralama Sözleşmesi).
  static Future<void> showScrollableContentDialog({
    required BuildContext context, // Widget ağacı içerik konumu
    required String title, // Diyalog başlığı
    required String content, // Gösterilecek uzun metin içeriği
    String buttonText = 'Kapat', // Kapatma butonu metni
  }) {
    // showDialog: Ekrana modal bir diyalog penceresi açar.
    return showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          // İçeriğin ekrandan taşmaması için SingleChildScrollView ile sarmalıyoruz.
          content: SizedBox(
            width: double.maxFinite, // Ekran genişliğine uygun maksimum alan
            child: SingleChildScrollView(
              child: Text(
                content,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ),
          actions: [
            // Diyaloğu kapatan onay butonu
            FilledButton(
              onPressed: () =>
                  Navigator.of(ctx).pop(), // Diyaloğu yığından (stack) çıkarır.
              child: Text(buttonText),
            ),
          ],
        );
      },
    );
  }

  /// Kullanıcıdan teyit alan İki Butonlu Onay Diyaloğu (Silme, çıkış, durum değişikliği için).
  /// Kullanıcı onaylarsa true, vazgeçerse false döndürür.
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Onayla',
    String cancelText = 'Vazgeç',
    bool isDestructive =
        false, // Silme gibi tehlikeli işlemlerde butonu kırmızı yapar.
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          actions: [
            // İptal Butonu
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false), // false döner
              child: Text(cancelText),
            ),
            // Onay Butonu
            FilledButton(
              style: isDestructive
                  ? FilledButton.styleFrom(
                      backgroundColor:
                          theme.colorScheme.error, // Kırmızı hata rengi
                      foregroundColor: theme.colorScheme.onError,
                    )
                  : null,
              onPressed: () => Navigator.of(ctx).pop(true), // true döner
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
    // Kullanıcı dışarıya tıklayarak kapattıysa varsayılan false döner.
    return result ?? false;
  }

  /// Ekranın altında kullanıcıya kısa süreli bildirim gösteren SnackBar yardımcı metodu.
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false, // Hata mesajı ise kırmızı zemin
    bool isSuccess = false, // Başarı mesajı ise yeşil zemin
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    // Varsa önceki açık bildirimi anında kapatıyoruz
    scaffoldMessenger.hideCurrentSnackBar();

    Color? bgColor;
    if (isError) bgColor = Colors.red.shade700;
    if (isSuccess) bgColor = Colors.green.shade700;

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior
            .floating, // Ekranın altından havada yüzen modern görünüm
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3), // 3 saniye sonra otomatik kapanır
      ),
    );
  }
}
