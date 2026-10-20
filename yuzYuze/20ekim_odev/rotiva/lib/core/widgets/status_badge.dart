import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Kiralama ve ödeme durumlarını şık renkli rozet (badge) olarak gösteren bileşen.
class StatusBadge extends StatelessWidget {
  final RentalStatus? rentalStatus;
  final PaymentStatus? paymentStatus;

  const StatusBadge.rental(this.rentalStatus, {super.key})
    : paymentStatus = null;

  const StatusBadge.payment(this.paymentStatus, {super.key})
    : rentalStatus = null;

  @override
  Widget build(BuildContext context) {
    String text = '';
    Color bgColor = Colors.grey.shade200;
    Color textColor = Colors.grey.shade800;
    IconData icon = Icons.info_outline;

    if (rentalStatus != null) {
      text = rentalStatus!.displayName;
      switch (rentalStatus!) {
        case RentalStatus.approved:
          bgColor = Colors.blue.withOpacity(0.15);
          textColor = Colors.blue.shade800;
          icon = Icons.check_circle_outline;
          break;
        case RentalStatus.active:
          bgColor = Colors.green.withOpacity(0.15);
          textColor = Colors.green.shade800;
          icon = Icons.directions_car_outlined;
          break;
        case RentalStatus.completed:
          bgColor = Colors.purple.withOpacity(0.15);
          textColor = Colors.purple.shade800;
          icon = Icons.task_alt;
          break;
        case RentalStatus.cancelled:
          bgColor = Colors.red.withOpacity(0.15);
          textColor = Colors.red.shade800;
          icon = Icons.cancel_outlined;
          break;
      }
    } else if (paymentStatus != null) {
      text = paymentStatus!.displayName;
      switch (paymentStatus!) {
        case PaymentStatus.simulatedPaid:
          bgColor = Colors.teal.withOpacity(0.15);
          textColor = Colors.teal.shade800;
          icon = Icons.payment;
          break;
        case PaymentStatus.payAtBranch:
          bgColor = Colors.amber.withOpacity(0.18);
          textColor = Colors.amber.shade900;
          icon = Icons.storefront_outlined;
          break;
        case PaymentStatus.pending:
          bgColor = Colors.orange.withOpacity(0.15);
          textColor = Colors.orange.shade800;
          icon = Icons.hourglass_top;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
