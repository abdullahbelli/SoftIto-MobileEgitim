import 'package:flutter/material.dart'; // Material Design renk ve ikon bileşenleri.

import '../constants/app_constants.dart'; // RentalStatus ve PaymentStatus enum tipleri.

/// Kiralama ve ödeme durumlarını şık renkli rozet (Badge) olarak gösteren bileşen.
/// Named constructor yapısı kullanılarak hem kiralama durumu hem de ödeme durumu için tek bir widget üzerinden hizmet verir.
class StatusBadge extends StatelessWidget {
  final RentalStatus?
  rentalStatus; // Gösterilecek kiralama durumu (Opsiyonel / Nullable)
  final PaymentStatus?
  paymentStatus; // Gösterilecek ödeme durumu (Opsiyonel / Nullable)

  // Kiralama durumu rozeti için isimlendirilmiş kurucu (named constructor)
  const StatusBadge.rental(this.rentalStatus, {super.key})
    : paymentStatus = null;

  // Ödeme durumu rozeti için isimlendirilmiş kurucu (named constructor)
  const StatusBadge.payment(this.paymentStatus, {super.key})
    : rentalStatus = null;

  @override
  Widget build(BuildContext context) {
    String text = ''; // Rozet içinde yazılacak metin
    Color bgColor = Colors.grey.shade200; // Varsayılan açık gri zemin rengi
    Color textColor = Colors.grey.shade800; // Varsayılan koyu gri yazı rengi
    IconData icon = Icons.info_outline; // Varsayılan durum ikonu

    // 1. Kiralama Durumu Renk ve İkon Mantığı
    if (rentalStatus != null) {
      text = rentalStatus!.displayName;
      switch (rentalStatus!) {
        case RentalStatus.approved:
          bgColor = Colors.blue.withOpacity(0.15); // Açık mavi zemin
          textColor = Colors.blue.shade800;
          icon = Icons.check_circle_outline;
          break;
        case RentalStatus.active:
          bgColor = Colors.green.withOpacity(0.15); // Açık yeşil zemin
          textColor = Colors.green.shade800;
          icon = Icons.directions_car_outlined;
          break;
        case RentalStatus.completed:
          bgColor = Colors.purple.withOpacity(0.15); // Açık mor zemin
          textColor = Colors.purple.shade800;
          icon = Icons.task_alt;
          break;
        case RentalStatus.cancelled:
          bgColor = Colors.red.withOpacity(0.15); // Açık kırmızı zemin
          textColor = Colors.red.shade800;
          icon = Icons.cancel_outlined;
          break;
      }
    }
    // 2. Ödeme Durumu Renk ve İkon Mantığı
    else if (paymentStatus != null) {
      text = paymentStatus!.displayName;
      switch (paymentStatus!) {
        case PaymentStatus.simulatedPaid:
          bgColor = Colors.teal.withOpacity(0.15); // Açık turkuaz zemin
          textColor = Colors.teal.shade800;
          icon = Icons.payment;
          break;
        case PaymentStatus.payAtBranch:
          bgColor = Colors.amber.withOpacity(0.18); // Açık sarı/kehribar zemin
          textColor = Colors.amber.shade900;
          icon = Icons.storefront_outlined;
          break;
        case PaymentStatus.pending:
          bgColor = Colors.orange.withOpacity(0.15); // Açık turuncu zemin
          textColor = Colors.orange.shade800;
          icon = Icons.hourglass_top;
          break;
      }
    }

    // Taşmaları önlemek için kompakt iç boşluk (padding) ve yuvarlatılmış köşe tasarımı
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize
            .min, // Rozet sadece içindeki ikon ve metin kadar yer kaplar
        children: [
          Icon(icon, size: 13, color: textColor), // Küçük durum ikonu
          const SizedBox(width: 4), // İkon ve metin arası boşluk
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
