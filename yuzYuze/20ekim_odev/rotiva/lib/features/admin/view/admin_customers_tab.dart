// Flutter Material tasarım bileşenlerini içeri aktarıyoruz.
import 'package:flutter/material.dart';

// Tarih araçları ve uygulama veri kapsamını içeri aktarıyoruz.
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/rotiva_scope.dart';

/// Yönetici Müşteri Listesi Sekmesi.
/// Kayıtlı müşterilerin ad, soyad, iletişim bilgileri, toplam kiralama sayısı ve demo puanlarını gösterir.
class AdminCustomersTab extends StatelessWidget {
  // Statik ve sabit widget optimizasyonu için const constructor tanımlıyoruz.
  const AdminCustomersTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Mevcut tema ve veri deposu referanslarını alıyoruz.
    final theme = Theme.of(context);
    final repository = RotivaScope.of(context).repository;

    // Sistemde kayıtlı ve müşteri rolündeki tüm kullanıcıları filtreliyoruz.
    final customers = repository.users.where((u) => u.isCustomer).toList();

    // Dış kabuktaki Scaffold ile çakışmayı önlemek için doğrudan SafeArea kullanıyoruz.
    return SafeArea(
      top: false, // Üst AppBar dış kabuk tarafından yönetildiği için top: false
      child: customers.isEmpty
          ? const Center(child: Text('Kayıtlı müşteri bulunmuyor.'))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: customers.length,
              itemBuilder: (context, index) {
                final customer = customers[index];
                // Bu müşteriye ait kiralama kayıtlarını alarak toplam sayıyı hesaplıyoruz.
                final rentals = repository.getRentalsForCustomer(customer.id);
                final totalRentals = rentals.length;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Müşteri Baş Harfi Avatarı
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: theme.colorScheme.primary
                              .withOpacity(0.12),
                          child: Text(
                            customer.fullName.isNotEmpty
                                ? customer.fullName[0].toUpperCase()
                                : 'M',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Müşteri Detay Bilgileri
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ad Soyad ve Puan Rozeti Satırı
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      customer.fullName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Müşteri Puanı Rozeti (5 üzerinden değerlendirme)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          size: 14,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          customer.userScore != null
                                              ? customer.userScore!
                                                    .toStringAsFixed(1)
                                              : 'Puan yok',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.amber.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // E-posta Adresi
                              Text(
                                customer.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              // Telefon Numarası
                              Text(
                                customer.phone,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Toplam Kiralama Sayısı ve Kayıt Tarihi Rozetleri
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'Toplam $totalRentals Kiralama',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Kayıt: ${RotivaDateUtils.formatTurkishDate(customer.createdAt)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
