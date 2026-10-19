import 'package:flutter/material.dart';

import '../models/transaction_model.dart';

class TransferFormScreen extends StatefulWidget {
  const TransferFormScreen({super.key});

  @override
  State<TransferFormScreen> createState() => _TransferFormScreenState();
}

class _TransferFormScreenState extends State<TransferFormScreen> {
  // Kullanıcının mevcut bakiyesi
  double _balance = 148950.00;

  // İşlem geçmişi
  final List<TransactionItem> _history = [
    const TransactionItem(
      id: 'tx_init_1',
      title: 'Ahmet Yılmaz',
      category: 'Hızlı Transfer',
      date: 'Bugün 11.30',
      amount: 1500.00,
      icon: Icons.send_rounded,
      isExpanse: true,
    ),
    const TransactionItem(
      id: 'tx_init_2',
      title: 'Abdullah Belli',
      category: 'Hızlı Transfer',
      date: 'Dün 15.45',
      amount: 2400,
      icon: Icons.send_rounded,
      isExpanse: true,
    ),
  ];

  // ==================================================
  // 1. TRANSFER FORMUNU AÇ
  //
  // showModalBottomSheet:
  // Ekranın altından açılan pencere oluşturur.
  //
  // Form:
  // Kullanıcının girdiği bilgileri doğrular.
  //
  // GlobalKey<FormState>:
  // Formun validate() metoduna erişmemizi sağlar.
  // ==================================================
  void _openTransferModel() {
    final formKey = GlobalKey<FormState>();

    // Kullanıcı girişlerini yönetir.
    final nameController = TextEditingController();
    final ibanController = TextEditingController();
    final amountController = TextEditingController();

    bool isSubmitting = false;

    showModalBottomSheet<void>(
      context: context,

      // Ekranın daha büyük kısmında açılabilmesini sağlar.
      isScrollControlled: true,

      // Üst köşeleri yuvarlar.
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),

      builder: (sheetContext) {
        // StatefulBuilder:
        // BottomSheet içindeki değişimleri yönetir.
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              // Klavye açıldığında formun yukarı çıkmasını sağlar.
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),

              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),

                  child: Form(
                    key: formKey,

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Üst başlık
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Para Transferi",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            IconButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Alıcı bilgilerini ve transfer tutarını giriniz.",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),

                        const SizedBox(height: 24),

                        // ALICI ADI
                        TextFormField(
                          controller: nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: "Alıcı Adı Soyadı",
                            hintText: "Örn: Ahmet Yılmaz",
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          // validator:
                          // Hatalı girişte uyarı verir.
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Alıcı adı boş bırakılamaz";
                            }

                            if (value.trim().length < 3) {
                              return "En az 3 karakter giriniz";
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // IBAN
                        TextFormField(
                          controller: ibanController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: "IBAN",
                            hintText: "TR00 0000 0000 0000 0000 0000 00",
                            prefixIcon: const Icon(Icons.account_balance),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          validator: (value) {
                            final iban = (value ?? "")
                                .replaceAll(RegExp(r'\s+'), '')
                                .toUpperCase();

                            if (iban.isEmpty) {
                              return "IBAN boş bırakılamaz";
                            }

                            // Türkiye IBAN'ı 26 karakterdir.
                            if (!RegExp(r'^TR[0-9]{24}$').hasMatch(iban)) {
                              return "Geçerli formatta TR IBAN giriniz";
                            }

                            // IBAN kontrol basamakları (mod 97)
                            final rearranged =
                                iban.substring(4) + iban.substring(0, 4);

                            int remainder = 0;

                            for (final char in rearranged.codeUnits) {
                              if (char >= 48 && char <= 57) {
                                remainder = (remainder * 10 + char - 48) % 97;
                              } else {
                                final number = char - 55;

                                remainder = (remainder * 100 + number) % 97;
                              }
                            }

                            if (remainder != 1) {
                              return "IBAN kontrol basamakları hatalı";
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // TRANSFER TUTARI
                        TextFormField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: "Transfer Tutarı",
                            hintText: "Örn: 1500",
                            prefixIcon: const Icon(Icons.currency_lira),
                            suffixText: "TL",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Transfer tutarı giriniz";
                            }

                            final amount = double.tryParse(
                              value.trim().replaceAll(',', '.'),
                            );

                            if (amount == null || !amount.isFinite) {
                              return "Geçerli bir tutar giriniz";
                            }

                            if (amount <= 0) {
                              return "Tutar sıfırdan büyük olmalı";
                            }

                            if (amount > _balance) {
                              return "Yetersiz bakiye";
                            }

                            // En fazla iki ondalık basamak
                            if ((amount * 100 - (amount * 100).round()).abs() >
                                0.000001) {
                              return "En fazla 2 ondalık basamak giriniz";
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        Text(
                          "Kullanılabilir Bakiye: ${_formatMoney(_balance)} TL",
                          style: const TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // TRANSFER BUTONU
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: isSubmitting
                                ? null
                                : () {
                                    // Önce formu doğrula.
                                    if (!formKey.currentState!.validate()) {
                                      return;
                                    }

                                    setModalState(() {
                                      isSubmitting = true;
                                    });

                                    final name = nameController.text.trim();
                                    final amount = double.parse(
                                      amountController.text.trim().replaceAll(
                                        ',',
                                        '.',
                                      ),
                                    );

                                    // Bu örnekte gerçek bankaya
                                    // para gönderilmez.
                                    // Sadece yerel state değişir.
                                    _completeTransfer(name, amount);

                                    Navigator.pop(sheetContext);
                                  },

                            icon: const Icon(Icons.send),
                            label: const Text(
                              "Transferi Tamamla",
                              style: TextStyle(fontSize: 16),
                            ),

                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      // Modal kapandığında controller'ları temizle.
      nameController.dispose();
      ibanController.dispose();
      amountController.dispose();
    });
  }

  // ==================================================
  // 2. TRANSFER İŞLEMİNİ TAMAMLA
  //
  // setState:
  // Bakiyeyi ve işlem geçmişini günceller.
  // ==================================================
  void _completeTransfer(String name, double amount) {
    final now = DateTime.now();

    setState(() {
      // Transfer tutarını bakiyeden düş.
      _balance = ((_balance * 100).round() - (amount * 100).round()) / 100;

      // Yeni işlemi listenin başına ekle.
      _history.insert(
        0,
        TransactionItem(
          id: 'tx_${now.microsecondsSinceEpoch}',
          title: name,
          category: "Hızlı Transfer",
          date:
              "Bugün ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",
          amount: amount,
          icon: Icons.send_rounded,
          isExpanse: true,
        ),
      );
    });

    // Kullanıcıya başarılı işlem mesajı göster.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "$name kişisine ${_formatMoney(amount)} TL transfer kaydedildi.",
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Para değerlerini Türkçe biçimde göstermek için
  String _formatMoney(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final digits = parts[0];

    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }

    return '${buffer.toString()},${parts[1]}';
  }

  // ==================================================
  // 3. ANA EKRAN
  // ==================================================
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Para Transferi",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          const Text(
            "Bakiyeni yönet ve hızlı transfer yap.",
            style: TextStyle(color: Color(0xFF64748B)),
          ),

          const SizedBox(height: 24),

          // Bakiye kartı
          _buildBalanceCard(),

          const SizedBox(height: 24),

          // Para gönder butonu
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: _openTransferModel,
              icon: const Icon(Icons.send_rounded),
              label: const Text(
                "Yeni Transfer Yap",
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // İşlem geçmişi
          _buildTransactionHistory(),
        ],
      ),
    );
  }

  // ==================================================
  // 4. BAKİYE KARTI
  // ==================================================
  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.white),
              SizedBox(width: 10),
              Text(
                "Kullanılabilir Bakiye",
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            "${_formatMoney(_balance)} TL",
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Transfer işlemlerine hazır",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ==================================================
  // 5. İŞLEM GEÇMİŞİ
  //
  // ListView.separated:
  // Liste elemanlarının arasına boşluk ekler.
  //
  // shrinkWrap:
  // Listenin içerik kadar yer kaplamasını sağlar.
  // ==================================================
  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Transfer Geçmişi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Text(
              "${_history.length} işlem",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),

        const SizedBox(height: 16),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          itemCount: _history.length,

          separatorBuilder: (context, index) {
            return const SizedBox(height: 12);
          },

          itemBuilder: (context, index) {
            final transaction = _history[index];

            return _buildTransactionItem(transaction);
          },
        ),
      ],
    );
  }

  // ==================================================
  // 6. TEK BİR TRANSFER İŞLEMİ
  // ==================================================
  Widget _buildTransactionItem(TransactionItem transaction) {
    final bool isExpense = transaction.isExpanse;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          // İşlem ikonu
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isExpense
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transaction.icon,
              color: isExpense ? Colors.red : Colors.green,
            ),
          ),

          const SizedBox(width: 12),

          // İşlem bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  transaction.category,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  transaction.date,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // İşlem tutarı
          Text(
            "${isExpense ? '-' : '+'}${_formatMoney(transaction.amount)} TL",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isExpense ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
