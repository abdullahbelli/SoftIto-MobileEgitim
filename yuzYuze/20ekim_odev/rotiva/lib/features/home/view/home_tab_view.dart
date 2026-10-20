import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/rotiva_app_bar.dart';
import '../../../core/widgets/rotiva_scope.dart';
import '../../../core/widgets/vehicle_card.dart';
import '../../vehicles/models/vehicle.dart';
import '../../vehicles/view/vehicle_detail_screen.dart';

/// Müşteri Ana Sayfası.
/// Hızlı lokasyon ve tarih arama paneli ile öne çıkan/filtrelenen araçları listeler.
class HomeTabView extends StatefulWidget {
  final VoidCallback onNavigateToVehicles;

  const HomeTabView({super.key, required this.onNavigateToVehicles});

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  String? _selectedCity;
  String? _selectedDistrict;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    // Varsayılan olarak bugünden itibaren 2 günlük tarih önerisi
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: RotivaDateUtils.dateOnly(now),
      end: RotivaDateUtils.dateOnly(now.add(const Duration(days: 2))),
    );
  }

  void _resetSearch() {
    setState(() {
      _selectedCity = null;
      _selectedDistrict = null;
      final now = DateTime.now();
      _selectedDateRange = DateTimeRange(
        start: RotivaDateUtils.dateOnly(now),
        end: RotivaDateUtils.dateOnly(now.add(const Duration(days: 2))),
      );
    });
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final firstDate = RotivaDateUtils.dateOnly(now);
    final lastDate = firstDate.add(const Duration(days: 365));

    final picked = await showDateDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: _selectedDateRange,
      helpText: 'KİRALAMA TARİH ARALIĞI',
      confirmText: 'UYGULA',
      cancelText: 'VAZGEÇ',
    );

    if (picked != null) {
      // Başlangıç ve bitiş aynı gün seçildiyse en az 1 gün ekle
      DateTime end = picked.end;
      if (end.difference(picked.start).inDays < 1) {
        end = picked.start.add(const Duration(days: 1));
      }
      setState(() {
        _selectedDateRange = DateTimeRange(start: picked.start, end: end);
      });
    }
  }

  // Wrapper for showDateRangePicker
  Future<DateTimeRange?> showDateDateRangePicker({
    required BuildContext context,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTimeRange? initialDateRange,
    String? helpText,
    String? confirmText,
    String? cancelText,
  }) {
    return showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: initialDateRange,
      helpText: helpText,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repository = RotivaScope.of(context).repository;
    final currentUser = repository.currentUser;

    // Aktif araçları filtreleme
    final allActiveVehicles = repository.activeVehicles;
    final filteredVehicles = allActiveVehicles.where((v) {
      // 1. Şehir filtresi
      if (_selectedCity != null && v.city != _selectedCity) {
        return false;
      }
      // 2. İlçe filtresi
      if (_selectedDistrict != null && v.district != _selectedDistrict) {
        return false;
      }
      // 3. Tarih uygunluk filtresi (çakışma kontrolü)
      if (_selectedDateRange != null) {
        final available = repository.isVehicleAvailable(
          v.id,
          _selectedDateRange!.start,
          _selectedDateRange!.end,
        );
        if (!available) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: RotivaAppBar(
        subtitleText:
            'Merhaba, ${currentUser?.fullName.split(' ').first ?? 'Misafir'}',
      ),
      body: CustomScrollView(
        slivers: [
          // Arama & Filtreleme Paneli
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Hızlı Araç Arama',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          if (_selectedCity != null ||
                              _selectedDistrict != null)
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              ),
                              icon: const Icon(Icons.refresh, size: 14),
                              label: const Text(
                                'Sıfırla',
                                style: TextStyle(fontSize: 12),
                              ),
                              onPressed: _resetSearch,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // İl ve İlçe Seçimi (İl değişince ilçe sıfırlanır)
                      Row(
                        children: [
                          // İl Seçimi
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCity,
                              decoration: const InputDecoration(
                                labelText: 'İl Seçiniz',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                prefixIcon: Icon(Icons.location_city, size: 18),
                              ),
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('Tümü (Şehir)'),
                                ),
                                ...AppConstants.turkeyCities.keys.map(
                                  (city) => DropdownMenuItem(
                                    value: city,
                                    child: Text(city),
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _selectedCity = val;
                                  _selectedDistrict = null; // İlçe sıfırlanır
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),

                          // İlçe Seçimi
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedDistrict,
                              decoration: const InputDecoration(
                                labelText: 'İlçe Seçiniz',
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                prefixIcon: Icon(
                                  Icons.place_outlined,
                                  size: 18,
                                ),
                              ),
                              isExpanded: true,
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text('Tümü (İlçe)'),
                                ),
                                if (_selectedCity != null &&
                                    AppConstants.turkeyCities[_selectedCity] !=
                                        null)
                                  ...AppConstants.turkeyCities[_selectedCity]!
                                      .map(
                                        (district) => DropdownMenuItem(
                                          value: district,
                                          child: Text(district),
                                        ),
                                      ),
                              ],
                              onChanged: _selectedCity == null
                                  ? null
                                  : (val) {
                                      setState(() => _selectedDistrict = val);
                                    },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Tarih Aralığı Seçici Butonu
                      InkWell(
                        onTap: _pickDateRange,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.date_range,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kiralama Tarihleri',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _selectedDateRange != null
                                          ? RotivaDateUtils.formatDateRangeText(
                                              _selectedDateRange!.start,
                                              _selectedDateRange!.end,
                                            )
                                          : 'Tarih seçilmedi',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Sonuç Başlığı ve Sayısı
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Uygun Araçlar (${filteredVehicles.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onNavigateToVehicles,
                    child: const Text('Filtreli Liste'),
                  ),
                ],
              ),
            ),
          ),

          // Araç Listesi veya Boş Durum
          if (filteredVehicles.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateView(
                icon: Icons.car_crash_outlined,
                title: 'Uygun Araç Bulunamadı',
                message: 'Seçtiğiniz lokasyon veya tarih aralığında müsait araç bulunamadı. Lütfen tarih veya şehir tercihinizi değiştiriniz.',
                buttonText: 'Aramayı Sıfırla',
                onButtonPressed: _resetSearch,
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final vehicle = filteredVehicles[index];
                final rating = repository.getAverageRatingForVehicle(
                  vehicle.id,
                );
                final reviewCount = repository
                    .getReviewsForVehicle(vehicle.id)
                    .length;

                return VehicleCard(
                  vehicle: vehicle,
                  rating: rating,
                  reviewCount: reviewCount,
                  onTap: () => _openVehicleDetail(vehicle),
                  onRentTap: () => _openVehicleDetail(vehicle),
                );
              }, childCount: filteredVehicles.length),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  void _openVehicleDetail(Vehicle vehicle) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VehicleDetailScreen(
          vehicle: vehicle,
          preselectedDateRange: _selectedDateRange,
        ),
      ),
    );
  }
}
