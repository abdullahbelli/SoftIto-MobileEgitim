// Flutter Material tasarım bileşenlerini içeri aktarıyoruz.
import 'package:flutter/material.dart';

// Sabitler, tarih araçları, formatlayıcılar ve durum rozetlerini içeri aktarıyoruz.
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/rotiva_scope.dart';
import '../../../core/widgets/status_badge.dart';
import '../../rentals/models/rental.dart';

/// Yönetici Kiralama ve Araç-Müşteri Eşleştirme Yönetimi Sekmesi.
/// Tüm kiralamaları listeler, durum geçişlerini (Onayla, Aktif, Tamamla, İptal) yönetir.
class AdminRentalsTab extends StatefulWidget {
  // Statik const constructor tanımlıyoruz.
  const AdminRentalsTab({super.key});

  @override
  State<AdminRentalsTab> createState() => _AdminRentalsTabState();
}

class _AdminRentalsTabState extends State<AdminRentalsTab> {
  // Seçili durum filtresi (null ise tüm kiralamalar listelenir).
  RentalStatus? _filterStatus;

  /// Kiralama durumunu güncelleyen asenkron metot.
  Future<void> _changeRentalStatus(
    Rental rental,
    RentalStatus newStatus,
  ) async {
    // Veri deposuna erişiyoruz.
    final repository = RotivaScope.of(context).repository;

    // Yöneticiden onay iletişim kutusu istiyoruz.
    final confirmed = await RotivaDialogs.showConfirmationDialog(
      context: context,
      title: 'Kiralama Durumunu Değiştir',
      message:
          '${rental.reservationCode} kodlu kiralama durumu "${newStatus.displayName}" olarak güncellenecektir. Onaylıyor musunuz?',
      confirmText: 'Durumu Güncelle',
    );

    // Onay verildiyse ve widget ağaçtaysa veriyi güncelliyoruz.
    if (confirmed && mounted) {
      await repository.updateRentalStatus(rental.id, newStatus);
      if (mounted) {
        RotivaDialogs.showSnackBar(
          context,
          'Rezervasyon durumu "${newStatus.displayName}" yapıldı.',
          isSuccess: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tema ve veri deposu referansları
    final theme = Theme.of(context);
    final repository = RotivaScope.of(context).repository;

    // Filtreye göre kiralamaları süzüyoruz.
    final rentals = repository.rentals.where((r) {
      if (_filterStatus != null && r.rentalStatus != _filterStatus) {
        return false;
      }
      return true;
    }).toList();

    // Dış kabuktaki Scaffold ile çakışmaması için SafeArea + Column kullanıyoruz.
    return SafeArea(
      top: false, // Üst AppBar dış kabuk tarafından yönetiliyor.
      child: Column(
        children: [
          // Durum Filtresi Çipleri (Yatay kaydırılabilir)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                // "Tümü" filtresi çipi
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Tümü'),
                    selected: _filterStatus == null,
                    onSelected: (_) => setState(() => _filterStatus = null),
                  ),
                ),
                // Tüm kiralama durumları için dinamik çipler
                ...RentalStatus.values.map(
                  (status) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(status.displayName),
                      selected: _filterStatus == status,
                      onSelected: (selected) {
                        setState(
                          () => _filterStatus = selected ? status : null,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1), // Ayrım çizgisi
          // Kiralama Listesi (Esnek ListView)
          Expanded(
            child: rentals.isEmpty
                ? const Center(
                    child: Text('Kriterlere uygun kiralama kaydı bulunamadı.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: rentals.length,
                    itemBuilder: (context, index) {
                      final rental = rentals[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Üst Satır: Rezervasyon Kodu ve Durum Rozetleri
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                              const SizedBox(height: 10),

                              // Araç ve Müşteri Eşleştirmesi (PROJECT.md Madde 102)
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Müşteri: ${rental.customerName}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.directions_car, size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Araç: ${rental.vehicleName}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Tarih ve Gün Bilgisi
                              Text(
                                'Süre: ${RotivaDateUtils.formatDateRangeText(rental.startDate, rental.endDate)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),

                              // Teslimat ve Adres Bilgisi
                              Text(
                                'Teslimat: ${rental.deliveryType.displayName} ${rental.deliveryAddress != null ? "(${rental.deliveryAddress})" : ""}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),

                              // Ödeme Yöntemi ve Kiralama Tutarı
                              Text(
                                'Ödeme: ${rental.paymentMethod.displayName} • Tutar: ${RotivaFormatters.formatCurrency(rental.finalPrice)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 8),

                              // Yönetici Durum Değiştirme Menüsü
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Durumu Güncelle:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  PopupMenuButton<RentalStatus>(
                                    tooltip: 'Durum Seç',
                                    child: Chip(
                                      avatar: const Icon(Icons.edit, size: 14),
                                      label: Text(
                                        rental.rentalStatus.displayName,
                                      ),
                                    ),
                                    onSelected: (newStatus) {
                                      _changeRentalStatus(rental, newStatus);
                                    },
                                    itemBuilder: (ctx) => RentalStatus.values
                                        .map(
                                          (status) => PopupMenuItem(
                                            value: status,
                                            child: Text(status.displayName),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
