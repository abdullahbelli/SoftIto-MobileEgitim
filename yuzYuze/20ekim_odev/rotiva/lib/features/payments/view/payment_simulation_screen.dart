import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/rotiva_app_bar.dart';
import '../../../core/widgets/rotiva_scope.dart';
import '../../../core/widgets/section_header.dart';
import '../../home/view/customer_shell_screen.dart';
import '../../rentals/models/rental.dart';
import '../../rentals/models/rental_pricing.dart';
import '../../vehicles/models/vehicle.dart';

/// Ödeme simülasyon ekranı.
/// Kredi kartı, EFT/Havale ve Şubede Nakit ödeme yöntemlerini destekler.
/// Adrese teslimde nakit ödemeyi kilitler; şubeden teslim + şubede nakitte %10 indirim uygular.
class PaymentSimulationScreen extends StatefulWidget {
  final Vehicle vehicle;
  final DateTime startDate;
  final DateTime endDate;
  final int rentalDays;
  final DeliveryType deliveryType;
  final String? deliveryAddress;
  final bool hasExtraKm;
  final double basePrice;
  final double extraKmCost;
  final double deliveryFee;

  const PaymentSimulationScreen({
    super.key,
    required this.vehicle,
    required this.startDate,
    required this.endDate,
    required this.rentalDays,
    required this.deliveryType,
    this.deliveryAddress,
    required this.hasExtraKm,
    required this.basePrice,
    required this.extraKmCost,
    required this.deliveryFee,
  });

  @override
  State<PaymentSimulationScreen> createState() =>
      _PaymentSimulationScreenState();
}

class _PaymentSimulationScreenState extends State<PaymentSimulationScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.creditCard;
  final _cardHolderController = TextEditingController(text: 'Ahmet Yılmaz');
  final _cardNumberController = TextEditingController(
    text: '4543 •••• •••• 9821',
  );
  final _expiryController = TextEditingController(text: '12/28');
  final _cvvController = TextEditingController(text: '342');
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Adrese teslimse varsayılan kredi kartı olmalı
    if (widget.deliveryType == DeliveryType.address &&
        _selectedMethod == PaymentMethod.cashAtBranch) {
      _selectedMethod = PaymentMethod.creditCard;
    }
  }

  @override
  void dispose() {
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _completePayment() async {
    setState(() => _isProcessing = true);

    // Kısa gerçekçi simülasyon gecikmesi
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    final repository = RotivaScope.of(context).repository;
    final currentUser = repository.currentUser;

    // Fiyatlandırma hesaplaması
    final pricing = RentalPricing.calculate(
      vehicle: widget.vehicle,
      startDate: widget.startDate,
      endDate: widget.endDate,
      deliveryType: widget.deliveryType,
      hasExtraKm: widget.hasExtraKm,
      paymentMethod: _selectedMethod,
    );

    final reservationCode = RotivaFormatters.generateReservationCode();
    final paymentStatus = _selectedMethod == PaymentMethod.cashAtBranch
        ? PaymentStatus.payAtBranch
        : PaymentStatus.simulatedPaid;

    final newRental = Rental(
      id: 'rent_${DateTime.now().millisecondsSinceEpoch}',
      reservationCode: reservationCode,
      customerId: currentUser?.id ?? 'usr_demo',
      customerName: currentUser?.fullName ?? 'Müşteri',
      vehicleId: widget.vehicle.id,
      vehicleName: widget.vehicle.displayName,
      startDate: widget.startDate,
      endDate: widget.endDate,
      rentalDays: widget.rentalDays,
      dailyKmLimitChosen: widget.hasExtraKm
          ? widget.vehicle.dailyKmLimit + widget.vehicle.additionalDailyKm
          : widget.vehicle.dailyKmLimit,
      hasExtraKm: widget.hasExtraKm,
      additionalKmCost: widget.extraKmCost,
      deliveryType: widget.deliveryType,
      deliveryAddress: widget.deliveryAddress,
      paymentMethod: _selectedMethod,
      basePrice: pricing.basePrice,
      deliveryFee: pricing.deliveryFee,
      discount: pricing.discountAmount,
      finalPrice: pricing.finalPrice,
      paymentStatus: paymentStatus,
      rentalStatus: RentalStatus.approved,
      agreementAcceptedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    await repository.createRental(newRental);

    setState(() => _isProcessing = false);

    // Başarı Diyaloğu
    if (mounted) {
      _showSuccessDialog(newRental);
    }
  }

  void _showSuccessDialog(Rental rental) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 54),
          title: const Text(
            'Rezervasyon Onaylandı!',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tebrikler, ${rental.vehicleName} kiralama işleminiz başarıyla oluşturuldu.',
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Column(
                  children: [
                    const Text(
                      'REZERVASYON KODU',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rental.reservationCode,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Toplam Tutar:', style: TextStyle(fontSize: 13)),
                  Text(
                    RotivaFormatters.formatCurrency(rental.finalPrice),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ödeme Yöntemi:', style: TextStyle(fontSize: 13)),
                  Text(
                    rental.paymentMethod.displayName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                // Kiralamalarım sekmesine yönlendir
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) =>
                        const CustomerShellScreen(initialTabIndex: 2),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Kiralamalarıma Git'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final pricing = RentalPricing.calculate(
      vehicle: widget.vehicle,
      startDate: widget.startDate,
      endDate: widget.endDate,
      deliveryType: widget.deliveryType,
      hasExtraKm: widget.hasExtraKm,
      paymentMethod: _selectedMethod,
    );

    final isAddressDelivery = widget.deliveryType == DeliveryType.address;

    return Scaffold(
      appBar: const RotivaAppBar(titleText: 'Ödeme Simülasyonu'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simülasyon Bilgi Bandı
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'GÜVENLİK VE EĞİTİM BİLGİSİ: Gerçek para çekimi yapılmaz. Kredi kartı, IBAN ve nakit ödemeler eğitim amacıyla simüle edilmektedir.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Ödeme Yöntemi Seçimi
            const SectionHeader(
              title: 'Ödeme Yöntemi Seçiniz',
              padding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),

            // 1. Kredi Kartı
            RadioListTile<PaymentMethod>(
              value: PaymentMethod.creditCard,
              groupValue: _selectedMethod,
              title: const Text('Kredi / Banka Kartı (Simüle)'),
              subtitle: const Text('Anında güvenli provizyon simülasyonu'),
              secondary: const Icon(Icons.credit_card),
              onChanged: (val) => setState(() => _selectedMethod = val!),
            ),

            // 2. Havale / EFT
            RadioListTile<PaymentMethod>(
              value: PaymentMethod.bankTransfer,
              groupValue: _selectedMethod,
              title: const Text('Havale / EFT (Simüle)'),
              subtitle: const Text('Şirket IBAN hesabına transfer bildirimi'),
              secondary: const Icon(Icons.account_balance),
              onChanged: (val) => setState(() => _selectedMethod = val!),
            ),

            // 3. Şubede Nakit (Adrese teslimatta kapalı)
            RadioListTile<PaymentMethod>(
              value: PaymentMethod.cashAtBranch,
              groupValue: _selectedMethod,
              title: Row(
                children: [
                  const Text('Şubede Nakit (Simüle)'),
                  const SizedBox(width: 8),
                  if (!isAddressDelivery)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '%10 İNDİRİM',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: isAddressDelivery
                  ? const Text(
                      'Adrese teslimatlarda şubede nakit ödeme seçilemez.',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : const Text('Aracı teslim alırken şubede nakit ödeme'),
              secondary: const Icon(Icons.payments_outlined),
              onChanged: isAddressDelivery
                  ? null // Adrese teslimde devre dışı
                  : (val) => setState(() => _selectedMethod = val!),
            ),
            const SizedBox(height: 16),

            // Seçilen Yönteme Göre Mock Form Alanları
            if (_selectedMethod == PaymentMethod.creditCard) ...[
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                  0.4,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kart Bilgileri (Simülasyon)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cardHolderController,
                        decoration: const InputDecoration(
                          labelText: 'Kart Üzerindeki İsim',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _cardNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Kart Numarası',
                          prefixIcon: Icon(Icons.credit_card_outlined),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _expiryController,
                              decoration: const InputDecoration(
                                labelText: 'Son Kullanma (AA/YY)',
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _cvvController,
                              decoration: const InputDecoration(
                                labelText: 'CVV',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_selectedMethod == PaymentMethod.bankTransfer) ...[
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                  0.4,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rotiva Banka Hesap Bilgileri',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Banka: Rotiva Demo Bank A.Ş.'),
                      Text('Alıcı: Rotiva Araç Kiralama A.Ş.'),
                      SizedBox(height: 6),
                      SelectableText(
                        'IBAN: TR33 0006 1000 0000 1234 5678 90',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 6),
                      Text(
                        '*Ödeme açıklamasına rezervasyon sonrasında verilecek kod girilmelidir.',
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_selectedMethod == PaymentMethod.cashAtBranch) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade400),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.discount_outlined,
                          color: Colors.green,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '%10 Şubede Nakit İndirimi Uygulandı!',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Aracınızı şubeden teslim alırken kiralama bedelini nakit ödeyerek ${RotivaFormatters.formatCurrency(pricing.discountAmount)} tasarruf ettiniz.',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Nihai Fiyat Dökümü
            Card(
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ödeme Özeti',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      'Araç Kiralama Bedeli (${widget.rentalDays} Gün)',
                      RotivaFormatters.formatCurrency(pricing.basePrice),
                    ),
                    if (widget.hasExtraKm) ...[
                      const SizedBox(height: 6),
                      _buildSummaryRow(
                        'Ek Kilometre Paketi',
                        RotivaFormatters.formatCurrency(pricing.extraKmCost),
                      ),
                    ],
                    if (widget.deliveryType == DeliveryType.address) ...[
                      const SizedBox(height: 6),
                      _buildSummaryRow(
                        'Adrese Teslimat Ücreti',
                        RotivaFormatters.formatCurrency(pricing.deliveryFee),
                      ),
                    ],
                    if (pricing.isCashDiscountApplied) ...[
                      const SizedBox(height: 6),
                      _buildSummaryRow(
                        'Şubede Nakit İndirimi (%10)',
                        '-${RotivaFormatters.formatCurrency(pricing.discountAmount)}',
                        isDiscount: true,
                      ),
                    ],
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'GENEL TOPLAM',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          RotivaFormatters.formatCurrency(pricing.finalPrice),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Ödemeyi Tamamla Butonu
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                icon: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  _isProcessing
                      ? 'İşlem Yapılıyor...'
                      : 'Rezervasyonu ve Ödemeyi Tamamla',
                ),
                onPressed: _isProcessing ? null : _completePayment,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDiscount ? Colors.green.shade800 : null,
            fontWeight: isDiscount ? FontWeight.w600 : null,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDiscount ? Colors.green.shade800 : null,
          ),
        ),
      ],
    );
  }
}
