// Flutter Material tasarım bileşenlerini içeri aktarıyoruz.
import 'package:flutter/material.dart';

// Sabitler, formatlayıcılar, boş durum görünümü, AppBar, Scope ve Araç Kartını içeri aktarıyoruz.
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/rotiva_app_bar.dart';
import '../../../core/widgets/rotiva_scope.dart';
import '../../../core/widgets/vehicle_card.dart';
import '../models/vehicle.dart';
import 'vehicle_detail_screen.dart';

/// Araçlar Sekmesi.
/// Marka/model arama, kategori, yakıt, vites, şehir ve fiyat aralığı filtreleriyle tüm araçları listeler.
class VehiclesTabView extends StatefulWidget {
  // Statik const constructor tanımlıyoruz.
  const VehiclesTabView({super.key});

  @override
  State<VehiclesTabView> createState() => _VehiclesTabViewState();
}

class _VehiclesTabViewState extends State<VehiclesTabView> {
  // Arama metni denetleyicisi
  final _searchController = TextEditingController();
  String _searchQuery = ''; // Arama sorgu metni
  VehicleCategory? _selectedCategory; // Kategori filtresi
  FuelType? _selectedFuel; // Yakıt filtresi
  TransmissionType? _selectedTransmission; // Vites filtresi
  String? _selectedCity; // Şehir filtresi
  double _maxDailyPrice =
      4000.0; // Maksimum günlük fiyat filtresi (Slider ile ayarlanır)

  @override
  void dispose() {
    // Bellek sızıntılarını önlemek için controller'ı dispose ediyoruz.
    _searchController.dispose();
    super.dispose();
  }

  /// Tüm arama ve filtre seçimlerini varsayılan hallerine sıfırlayan metot
  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = null;
      _selectedFuel = null;
      _selectedTransmission = null;
      _selectedCity = null;
      _maxDailyPrice = 4000.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repository = RotivaScope.of(context).repository;

    // Aktif araçları filtre kriterlerine göre süzüyoruz.
    final vehicles = repository.activeVehicles.where((v) {
      // 1. Marka, model veya şehir metin araması
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matches =
            v.brand.toLowerCase().contains(query) ||
            v.model.toLowerCase().contains(query) ||
            v.city.toLowerCase().contains(query);
        if (!matches) return false;
      }
      // 2. Kasa kategorisi filtresi (Sedan, SUV vb.)
      if (_selectedCategory != null && v.category != _selectedCategory) {
        return false;
      }
      // 3. Yakıt türü filtresi (Benzin, Dizel, Elektrik vb.)
      if (_selectedFuel != null && v.fuelType != _selectedFuel) {
        return false;
      }
      // 4. Vites türü filtresi (Otomatik, Manuel)
      if (_selectedTransmission != null &&
          v.transmission != _selectedTransmission) {
        return false;
      }
      // 5. Şehir filtresi
      if (_selectedCity != null && v.city != _selectedCity) {
        return false;
      }
      // 6. Maksimum günlük kiralama ücreti filtresi
      if (v.dailyRate > _maxDailyPrice) {
        return false;
      }

      return true;
    }).toList();

    return Scaffold(
      appBar: RotivaAppBar(
        titleText: 'Tüm Araçlar',
        actions: [
          // Filtreleri tek dokunuşla sıfırlama butonu
          IconButton(
            tooltip: 'Filtreleri Sıfırla',
            icon: const Icon(Icons.filter_alt_off_outlined),
            onPressed: _resetFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama Çubuğu (Marka / Model arama)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Marka veya model arayın (Örn: Renault, BMW)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (val) {
                setState(() => _searchQuery = val.trim());
              },
            ),
          ),

          // Yatay Kategori Çipleri (Kasa Tipi: Tüm Tipler, Sedan, SUV vb.)
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Tüm Tipler'),
                    selected: _selectedCategory == null,
                    onSelected: (_) => setState(() => _selectedCategory = null),
                  ),
                ),
                ...VehicleCategory.values.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat.displayName),
                      selected: _selectedCategory == cat,
                      onSelected: (selected) {
                        setState(
                          () => _selectedCategory = selected ? cat : null,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // İkinci Filtre Satırı (Vites, Yakıt, Şehir ve Fiyat Çipi)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Vites Seçimi Açılır Butonu
                  DropdownButton<TransmissionType?>(
                    value: _selectedTransmission,
                    hint: const Text('Vites', style: TextStyle(fontSize: 13)),
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tüm Vitesler'),
                      ),
                      ...TransmissionType.values.map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.displayName),
                        ),
                      ),
                    ],
                    onChanged: (val) =>
                        setState(() => _selectedTransmission = val),
                  ),
                  const SizedBox(width: 12),

                  // Yakıt Seçimi Açılır Butonu
                  DropdownButton<FuelType?>(
                    value: _selectedFuel,
                    hint: const Text('Yakıt', style: TextStyle(fontSize: 13)),
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tüm Yakıtlar'),
                      ),
                      ...FuelType.values.map(
                        (f) => DropdownMenuItem(
                          value: f,
                          child: Text(f.displayName),
                        ),
                      ),
                    ],
                    onChanged: (val) => setState(() => _selectedFuel = val),
                  ),
                  const SizedBox(width: 12),

                  // Şehir Seçimi Açılır Butonu
                  DropdownButton<String?>(
                    value: _selectedCity,
                    hint: const Text('Şehir', style: TextStyle(fontSize: 13)),
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tüm Şehirler'),
                      ),
                      ...AppConstants.turkeyCities.keys.map(
                        (c) => DropdownMenuItem(value: c, child: Text(c)),
                      ),
                    ],
                    onChanged: (val) => setState(() => _selectedCity = val),
                  ),
                  const SizedBox(width: 12),

                  // Maksimum Fiyat Filtresi Buton Çipi
                  ActionChip(
                    avatar: const Icon(Icons.tune, size: 16),
                    label: Text(
                      'Maks: ${RotivaFormatters.formatCurrency(_maxDailyPrice)}',
                    ),
                    onPressed: () => _showPriceFilterBottomSheet(context),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 12),

          // Bulunan Araç Sayısı ve Temizleme Satırı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${vehicles.length} Araç Bulundu',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (_selectedCategory != null ||
                    _selectedFuel != null ||
                    _selectedTransmission != null ||
                    _selectedCity != null ||
                    _searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: _resetFilters,
                    child: Text(
                      'Filtreleri Temizle',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Filtrelenmiş Araçlar Listesi
          Expanded(
            child: vehicles.isEmpty
                ? EmptyStateView(
                    icon: Icons.search_off,
                    title: 'Arama Sonucu Bulunamadı',
                    message: 'Uyguladığınız filtre kriterlerine uygun araç bulunmamaktadır. Filtreleri temizleyerek tüm filoyu görebilirsiniz.',
                    buttonText: 'Filtreleri Temizle',
                    onButtonPressed: _resetFilters,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = vehicles[index];
                      // Aracın ortalama yıldız puanını ve yorum sayısını alıyoruz.
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
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Fiyat filtresi alt sayfasını (BottomSheet) açan metot
  void _showPriceFilterBottomSheet(BuildContext context) {
    double tempPrice = _maxDailyPrice;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Maksimum Günlük Kiralama Ücreti',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      RotivaFormatters.formatCurrency(tempPrice),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  // Fiyat seçimi için Slider bileşeni
                  Slider(
                    value: tempPrice,
                    min: 800.0,
                    max: 4500.0,
                    divisions: 37,
                    label: RotivaFormatters.formatCurrency(tempPrice),
                    onChanged: (val) {
                      setSheetState(() => tempPrice = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      setState(() => _maxDailyPrice = tempPrice);
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Filtreyi Uygula'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Araç detay sayfasına geçiş yapan metot
  void _openVehicleDetail(Vehicle vehicle) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VehicleDetailScreen(vehicle: vehicle)),
    );
  }
}
