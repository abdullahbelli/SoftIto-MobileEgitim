// Flutter Material tasarım bileşenlerini içeri aktarıyoruz.
import 'package:flutter/material.dart';

// Sabitler, demo metinler, tarih araçları, formatlayıcılar, diyaloglar ve rozetleri içeri aktarıyoruz.
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/demo_texts.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/fuel_type_badge.dart';
import '../../../core/widgets/rotiva_app_bar.dart';
import '../../../core/widgets/rotiva_scope.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/vehicle_type_badge.dart';
import '../../payments/view/payment_simulation_screen.dart';
import '../../vehicles/models/vehicle.dart';
import '../models/rental_pricing.dart';

/// Kiralama formu, sürücü uygunluk denetimi ve sözleşme kabul ekranı.
/// Tarih seçimi, teslimat tipi, ek km paketi, doğum tarihi ve ehliyet süresi denetimlerini yürütür.
class RentalFormScreen extends StatefulWidget {
  final Vehicle vehicle; // Kiralanmak istenen araç nesnesi
  final DateTimeRange?
  initialDateRange; // Önceden seçilmiş başlangıç ve bitiş tarihleri

  const RentalFormScreen({
    super.key,
    required this.vehicle,
    this.initialDateRange,
  });

  @override
  State<RentalFormScreen> createState() => _RentalFormScreenState();
}

class _RentalFormScreenState extends State<RentalFormScreen> {
  // Adrese teslimat seçildiğinde açık adres metin denetleyicisi
  final _addressController = TextEditingController();
  // Seçili kiralama tarih aralığı
  late DateTimeRange _dateRange;
  // Teslimat tipi (Şubeden teslim veya Adrese teslim)
  DeliveryType _deliveryType = DeliveryType.branch;
  // Ekstra kilometre paketi istendi mi?
  bool _hasExtraKm = false;
  // Kiralama sözleşmesi kabul edildi mi?
  bool _agreementAccepted = false;

  // Kullanıcının profilinde kayıtlı doğum tarihi ve ehliyet tarihi (Eksikse bu ekranda seçtirilir)
  DateTime? _userBirthDate;
  DateTime? _userLicenseDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Başlangıç tarihi belirtilmemişse bugünden itibaren 2 günlük varsayılan aralık atıyoruz.
    _dateRange =
        widget.initialDateRange ??
        DateTimeRange(
          start: RotivaDateUtils.dateOnly(now),
          end: RotivaDateUtils.dateOnly(now.add(const Duration(days: 2))),
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Giriş yapmış kullanıcının kayıtlı sürücü bilgilerini alıyoruz.
    final user = RotivaScope.of(context).repository.currentUser;
    _userBirthDate ??= user?.driverBirthDate;
    _userLicenseDate ??= user?.licenseIssueDate;
  }

  @override
  void dispose() {
    // Bellek sızıntılarını önlemek için controller'ı dispose ediyoruz.
    _addressController.dispose();
    super.dispose();
  }

  /// Kiralama tarih aralığı seçici diyaloğunu açar.
  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final firstDate = RotivaDateUtils.dateOnly(now);
    final lastDate = firstDate.add(const Duration(days: 365));

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: _dateRange,
      helpText: 'KİRALAMA TARİH ARALIĞINI SEÇİN',
      confirmText: 'SEÇ',
      cancelText: 'VAZGEÇ',
    );

    if (picked != null) {
      DateTime end = picked.end;
      // Aynı gün seçilmişse en az 1 tam gün olacak şekilde düzeltiyoruz.
      if (end.difference(picked.start).inDays < 1) {
        end = picked.start.add(const Duration(days: 1));
      }
      setState(() {
        _dateRange = DateTimeRange(start: picked.start, end: end);
      });
    }
  }

  /// Sürücünün doğum tarihini seçtiren tarih seçici
  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _userBirthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1950, 1, 1),
      lastDate: DateTime.now(),
      helpText: 'DOĞUM TARİHİNİZİ SEÇİN',
    );
    if (picked != null) {
      setState(() => _userBirthDate = picked);
    }
  }

  /// Sürücünün ehliyet alış tarihini seçtiren tarih seçici
  Future<void> _pickLicenseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _userLicenseDate ?? DateTime(2020, 1, 1),
      firstDate: DateTime(1970, 1, 1),
      lastDate: DateTime.now(),
      helpText: 'EHLİYET ALIŞ TARİHİNİZİ SEÇİN',
    );
    if (picked != null) {
      setState(() => _userLicenseDate = picked);
    }
  }

  /// Kiralama sözleşmesi metnini açılır kaydırılabilir diyalogda gösteren metot
  void _showRentalAgreementDialog() {
    RotivaDialogs.showScrollableContentDialog(
      context: context,
      title: DemoTexts.rentalAgreementTitle,
      content: DemoTexts.rentalAgreementContent,
    );
  }

  /// Sürücü şartlarını, çakışmayı ve sözleşmeyi denetleyip ödeme ekranına geçiren fonksiyon
  void _proceedToPayment() {
    final repository = RotivaScope.of(context).repository;

    // 1. Sürücü Bilgileri Tamlık Kontrolü
    if (_userBirthDate == null || _userLicenseDate == null) {
      RotivaDialogs.showSnackBar(
        context,
        'Lütfen kiralama öncesi doğum tarihinizi ve ehliyet alış tarihinizi belirtiniz.',
        isError: true,
      );
      return;
    }

    // 2. Yaş ve Ehliyet Şartı Uygunluk Kontrolü (Tam Yıl Hesabı)
    final age = RotivaDateUtils.calculateExactAge(_userBirthDate!);
    final licenseYears = RotivaDateUtils.calculateExactLicenseYears(
      _userLicenseDate!,
    );

    if (age < widget.vehicle.minimumAge) {
      RotivaDialogs.showSnackBar(
        context,
        'Bu aracı kiralamak için en az ${widget.vehicle.minimumAge} yaşında olmalısınız. (Mevcut yaşınız: $age)',
        isError: true,
      );
      return;
    }

    if (licenseYears < widget.vehicle.minimumLicenseYears) {
      RotivaDialogs.showSnackBar(
        context,
        'Bu aracı kiralamak için en az ${widget.vehicle.minimumLicenseYears} yıllık ehliyet gereklidir. (Mevcut ehliyet süreniz: $licenseYears yıl)',
        isError: true,
      );
      return;
    }

    // 3. Adrese Teslimatta Açık Adres Zorunluluğu
    if (_deliveryType == DeliveryType.address &&
        _addressController.text.trim().isEmpty) {
      RotivaDialogs.showSnackBar(
        context,
        'Lütfen aracın teslim edileceği açık adresi yazınız.',
        isError: true,
      );
      return;
    }

    // 4. Tarih Çakışması Kontrolü (Başka müşteri kiralamış mı?)
    final isAvailable = repository.isVehicleAvailable(
      widget.vehicle.id,
      _dateRange.start,
      _dateRange.end,
    );
    if (!isAvailable) {
      RotivaDialogs.showSnackBar(
        context,
        'Seçilen tarihlerde bu araç için başka bir rezervasyon bulunmaktadır. Lütfen farklı tarihler seçiniz.',
        isError: true,
      );
      return;
    }

    // 5. Sözleşme Onay Kontrolü
    if (!_agreementAccepted) {
      RotivaDialogs.showSnackBar(
        context,
        'Lütfen devam etmek için kiralama sözleşmesini onaylayınız.',
        isError: true,
      );
      return;
    }

    // Kullanıcının profilini güncelle (Girilen ehliyet ve doğum tarihi kaydedilir)
    final currentUser = repository.currentUser;
    if (currentUser != null &&
        (currentUser.driverBirthDate == null ||
            currentUser.licenseIssueDate == null)) {
      repository.updateProfile(
        currentUser.copyWith(
          driverBirthDate: _userBirthDate,
          licenseIssueDate: _userLicenseDate,
        ),
      );
    }

    // Fiyatlandırmayı hesapla
    final pricing = RentalPricing.calculate(
      vehicle: widget.vehicle,
      startDate: _dateRange.start,
      endDate: _dateRange.end,
      deliveryType: _deliveryType,
      hasExtraKm: _hasExtraKm,
    );

    // Ödeme ekranına yönlendir
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentSimulationScreen(
          vehicle: widget.vehicle,
          startDate: _dateRange.start,
          endDate: _dateRange.end,
          rentalDays: pricing.rentalDays,
          deliveryType: _deliveryType,
          deliveryAddress: _deliveryType == DeliveryType.address
              ? _addressController.text.trim()
              : null,
          hasExtraKm: _hasExtraKm,
          basePrice: pricing.basePrice,
          extraKmCost: pricing.extraKmCost,
          deliveryFee: pricing.deliveryFee,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = RotivaDateUtils.calculateRentalDays(
      _dateRange.start,
      _dateRange.end,
    );

    // Güncel tercihlere göre fiyatlandırmayı hesaplıyoruz.
    final pricing = RentalPricing.calculate(
      vehicle: widget.vehicle,
      startDate: _dateRange.start,
      endDate: _dateRange.end,
      deliveryType: _deliveryType,
      hasExtraKm: _hasExtraKm,
    );

    return Scaffold(
      appBar: const RotivaAppBar(titleText: 'Kiralama ve Rezervasyon'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seçili Araç Özeti Kartı
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 36,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.vehicle.displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${widget.vehicle.location} • ${widget.vehicle.transmission.displayName}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${RotivaFormatters.formatCurrency(widget.vehicle.dailyRate)}\n/ gün',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Kasa ve Yakıt Rozetleri
                    Row(
                      children: [
                        VehicleTypeBadge(
                          category: widget.vehicle.category,
                          isCompact: true,
                        ),
                        const SizedBox(width: 8),
                        FuelTypeBadge(
                          fuelType: widget.vehicle.fuelType,
                          isCompact: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 1. Kiralama Tarihleri Bölümü
            const SectionHeader(
              title: '1. Kiralama Tarihleri',
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDateRange,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            RotivaDateUtils.formatDateRangeText(
                              _dateRange.start,
                              _dateRange.end,
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Takvim günü farkı: $days Gün',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_calendar, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Teslimat Tercihi Bölümü (Şubeden veya Adrese)
            const SectionHeader(
              title: '2. Teslimat Tercihi',
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    avatar: const Icon(Icons.storefront_outlined, size: 16),
                    label: const Text('Şubeden Teslim'),
                    selected: _deliveryType == DeliveryType.branch,
                    onSelected: (val) {
                      if (val) {
                        setState(() => _deliveryType = DeliveryType.branch);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    avatar: const Icon(Icons.home_outlined, size: 16),
                    label: Text(
                      'Adrese (+${RotivaFormatters.formatCurrency(widget.vehicle.addressDeliveryFee)})',
                    ),
                    selected: _deliveryType == DeliveryType.address,
                    onSelected: (val) {
                      if (val) {
                        setState(() => _deliveryType = DeliveryType.address);
                      }
                    },
                  ),
                ),
              ],
            ),
            if (_deliveryType == DeliveryType.address) ...[
              const SizedBox(height: 12),
              // Adres Giriş Metin Kutusu
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Teslimat Adresi',
                  hintText: 'Mahalle, sokak, bina ve kapı no giriniz...',
                  prefixIcon: const Icon(Icons.location_city_outlined),
                  helperText: 'Araç belirttiğiniz adrese vale tarafından teslim edilecektir.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // 3. Kilometre Paketi Tercihi
            const SectionHeader(
              title: '3. Kilometre Paketi',
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            RadioListTile<bool>(
              value: false,
              groupValue: _hasExtraKm,
              title: Text(
                'Standart Paket (${widget.vehicle.dailyKmLimit} km / gün)',
              ),
              subtitle: Text(
                'Toplam $days gün için ${widget.vehicle.dailyKmLimit * days} km limit dahildir.',
              ),
              onChanged: (val) => setState(() => _hasExtraKm = val ?? false),
            ),
            RadioListTile<bool>(
              value: true,
              groupValue: _hasExtraKm,
              title: Text(
                'Ekstra KM Paketi (+${widget.vehicle.additionalDailyKm} km / gün)',
              ),
              subtitle: Text(
                'Günlük +${RotivaFormatters.formatCurrency(widget.vehicle.additionalKmDailyPrice)} fark ile toplam ${(widget.vehicle.dailyKmLimit + widget.vehicle.additionalDailyKm) * days} km limit.',
              ),
              onChanged: (val) => setState(() => _hasExtraKm = val ?? true),
            ),
            const SizedBox(height: 16),

            // 4. Sürücü Doğrulama Bilgileri ve Yaş/Ehliyet Kontrolü
            SectionHeader(
              title: '4. Sürücü Doğrulama Bilgileri',
              subtitle:
                  'Bu araç için min. ${widget.vehicle.minimumAge} yaş ve ${widget.vehicle.minimumLicenseYears} yıl ehliyet gereklidir.',
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.cake_outlined, size: 18),
                    label: Text(
                      _userBirthDate != null
                          ? RotivaDateUtils.formatTurkishDate(_userBirthDate!)
                          : 'Doğum Tarihi Seç',
                    ),
                    onPressed: _pickBirthDate,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.badge_outlined, size: 18),
                    label: Text(
                      _userLicenseDate != null
                          ? RotivaDateUtils.formatTurkishDate(_userLicenseDate!)
                          : 'Ehliyet Tarihi Seç',
                    ),
                    onPressed: _pickLicenseDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 5. Fiyat Hesaplama Özeti Kartı
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fiyat Hesaplama Özeti',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPriceRow(
                      'Araç Kiralama ($days Gün × ${RotivaFormatters.formatCurrency(widget.vehicle.dailyRate)})',
                      RotivaFormatters.formatCurrency(pricing.basePrice),
                    ),
                    if (_hasExtraKm) ...[
                      const SizedBox(height: 6),
                      _buildPriceRow(
                        'Ek Kilometre Paketi ($days Gün × ${RotivaFormatters.formatCurrency(widget.vehicle.additionalKmDailyPrice)})',
                        RotivaFormatters.formatCurrency(pricing.extraKmCost),
                      ),
                    ],
                    if (_deliveryType == DeliveryType.address) ...[
                      const SizedBox(height: 6),
                      _buildPriceRow(
                        'Adrese Teslimat Hizmet Bedeli',
                        RotivaFormatters.formatCurrency(pricing.deliveryFee),
                      ),
                    ],
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ara Toplam',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          RotivaFormatters.formatCurrency(pricing.finalPrice),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '*Şubeden teslim ve şubede nakit ödemelerde sonraki adımda %10 indirim uygulanacaktır.',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 6. Kiralama Sözleşmesi Onayı
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _agreementAccepted
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Checkbox(
                      value: _agreementAccepted,
                      onChanged: (val) {
                        setState(() => _agreementAccepted = val ?? false);
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(
                            () => _agreementAccepted = !_agreementAccepted,
                          );
                        },
                        child: const Text(
                          'Kiralama Sözleşmesini okudum ve şartları kabul ediyorum.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _showRentalAgreementDialog,
                      child: const Text('Metni Oku'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Ödeme Ekranına Geç Butonu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                icon: const Icon(Icons.payment),
                label: const Text('Ödeme Adımına İlerle'),
                onPressed: _proceedToPayment,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Fiyat dökümü satırını oluşturan yardımcı metot (Taşmaları önlemek için Expanded içerir)
  Widget _buildPriceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
