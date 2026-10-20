import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/rotiva_app_bar.dart';
import '../../../core/widgets/rotiva_scope.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/rental.dart';
import '../models/review.dart';

/// Müşteri Kiralamalarım sekmesi.
/// Aktif, onaylı ve geçmiş kiralamaları listeler; tamamlanan kiralamalar için yıldız ve yorum bırakma imkanı sunar.
class MyRentalsTabView extends StatelessWidget {
  const MyRentalsTabView({super.key});

  void _showAddReviewDialog(BuildContext context, Rental rental) {
    int selectedStars = 5;
    final commentController = TextEditingController();
    final repository = RotivaScope.of(context).repository;
    final existingReview = repository.getReviewForRental(rental.id);

    if (existingReview != null) {
      selectedStars = existingReview.stars;
      commentController.text = existingReview.comment;
    }

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                existingReview != null ? 'Yorumu Düzenle' : 'Aracı Değerlendir',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rental.vehicleName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Puanınız (1 - 5 Yıldız):',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        return IconButton(
                          icon: Icon(
                            star <= selectedStars
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setDialogState(() => selectedStars = star);
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Deneyiminiz ve Yorumunuz',
                        hintText: 'Araç durumu, temizlik ve sürüş nasıldı?',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Vazgeç'),
                ),
                FilledButton(
                  onPressed: () async {
                    if (commentController.text.trim().isEmpty) {
                      RotivaDialogs.showSnackBar(
                        context,
                        'Lütfen kısa bir yorum yazınız.',
                        isError: true,
                      );
                      return;
                    }

                    final newReview = Review(
                      id:
                          existingReview?.id ??
                          'rev_${DateTime.now().millisecondsSinceEpoch}',
                      rentalId: rental.id,
                      vehicleId: rental.vehicleId,
                      customerId: rental.customerId,
                      customerName: rental.customerName,
                      stars: selectedStars,
                      comment: commentController.text.trim(),
                      createdAt: DateTime.now(),
                    );

                    await repository.addReview(newReview);
                    if (context.mounted) {
                      Navigator.of(ctx).pop();
                      RotivaDialogs.showSnackBar(
                        context,
                        'Değerlendirmeniz kaydedildi. Teşekkür ederiz!',
                        isSuccess: true,
                      );
                    }
                  },
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repository = RotivaScope.of(context).repository;
    final currentUser = repository.currentUser;

    final customerRentals = currentUser != null
        ? repository.getRentalsForCustomer(currentUser.id)
        : <Rental>[];

    return Scaffold(
      appBar: const RotivaAppBar(titleText: 'Kiralamalarım'),
      body: customerRentals.isEmpty
          ? const EmptyStateView(
              icon: Icons.receipt_long_outlined,
              title: 'Henüz Kiralama Kaydınız Yok',
              message: 'Ana sayfa veya Araçlar sekmesinden dilediğiniz aracı inceleyip hemen kiralayabilirsiniz.',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: customerRentals.length,
              itemBuilder: (context, index) {
                final rental = customerRentals[index];
                final review = repository.getReviewForRental(rental.id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Üst Başlık Satırı: Kod & Durum Rozeti
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              rental.reservationCode,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                StatusBadge.payment(rental.paymentStatus),
                                const SizedBox(width: 6),
                                StatusBadge.rental(rental.rentalStatus),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Araç Adı
                        Text(
                          rental.vehicleName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Tarih ve Gün Bilgisi
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              RotivaDateUtils.formatDateRangeText(
                                rental.startDate,
                                rental.endDate,
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Teslim Şekli ve Adres
                        Row(
                          children: [
                            Icon(
                              rental.deliveryType == DeliveryType.branch
                                  ? Icons.storefront_outlined
                                  : Icons.delivery_dining_outlined,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              rental.deliveryType.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (rental.deliveryAddress != null) ...[
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '(${rental.deliveryAddress})',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 10),

                        // Ödeme ve Fiyat Özeti
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rental.paymentMethod.displayName,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                if (rental.discount > 0)
                                  Text(
                                    '%10 Nakit İndirimi: -${RotivaFormatters.formatCurrency(rental.discount)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                              ],
                            ),
                            Text(
                              RotivaFormatters.formatCurrency(
                                rental.finalPrice,
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),

                        // Tamamlanan Kiralamada Yorum Bırakma Butonu / Gösterimi
                        if (rental.isCompleted) ...[
                          const SizedBox(height: 12),
                          if (review != null) ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest
                                    .withOpacity(0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${review.stars} Yıldız: ',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      review.comment,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        _showAddReviewDialog(context, rental),
                                    child: const Text(
                                      'Düzenle',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.star_outline, size: 16),
                                label: const Text(
                                  'Aracı Değerlendir & Yorum Yaz',
                                ),
                                onPressed: () =>
                                    _showAddReviewDialog(context, rental),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
