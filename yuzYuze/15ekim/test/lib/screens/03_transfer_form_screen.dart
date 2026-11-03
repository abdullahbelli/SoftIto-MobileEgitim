import 'package:flutter/material.dart';

import '../models/transaction_model.dart'; // kullanılanacak modelin olduğu dosyayı projeye dahil eder

class TransferFormScreen extends StatefulWidget {
  // Verileri değişebilen para transferi ekranı
  const TransferFormScreen({
    super.key,
  }); // Ekranın oluşturulmasını ve flutter tarafından takip edilmesini sağlar

  @override // Üst sınıftaki createState metodu
  State<TransferFormScreen> createState() => _TransferFormScreenState(); // Ekranın değişen durumunu yönetecek State nesnesini oluşturur
}

class _TransferFormScreenState extends State<TransferFormScreen> {
  // Bakiye, transfer işlemleri ve ekranın durumunu yönetir
  double _balance =
      148950.00; // Başlangıç bakiyesini tutar ve transferlerde güncellenir

  // İşlem geçmişi
  final List<TransactionItem> _history = [
    // Gerçekleştirilen transferleri saklayan listeyi oluşturur
    const TransactionItem(
      // Örnek bir transfer işlemi oluşturur
      id: 'tx_init_1',
      title: 'Ahmet Yılmaz',
      category: 'Hızlı Transfer',
      date: 'Bugün 11.30',
      amount: 1500.00,
      icon: Icons.send_rounded,
      isExpanse: true, // İşlemin gider olduğunu belirtir
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
    // Para transferi formunu açan metot
    final formKey =
        GlobalKey<
          FormState
        >(); // Formun doğrulama işlemlerini yönetmek için anahtar oluşturur

    // Kullanıcı girişlerini yönetir.
    final nameController =
        TextEditingController(); // Alıcı adı alanındaki metni yönetir
    final ibanController =
        TextEditingController(); // iban alanındaki metni yönetir
    final amountController =
        TextEditingController(); // Transfer tutarı alanındaki metni yönetir

    bool isSubmitting =
        false; // Transfer işleminin devam edip etmediğini takip eder

    showModalBottomSheet<void>(
      // Ekranın altından transfer formu açar
      context: context, // Formun hangi ekran üzerinde açılacağını belirler
      // Ekranın daha büyük kısmında açılabilmesini sağlar.
      isScrollControlled:
          true, // Formun klavye ve ekran yüksekliğine göre genişlemesini sağlar
      // Üst köşeleri yuvarlar.
      shape: const RoundedRectangleBorder(
        // Açılan pencerenin kenar şekli
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ), // Pencerenin üst köşelerini yuvarlar
      ),

      builder: (sheetContext) {
        // Açılan pencerenin arayüzünü oluşturur
        // StatefulBuilder:BottomSheet içindeki değişimleri yönetir.
        return StatefulBuilder(
          // Ana ekranı yenilemeden formun kendi durumunu günceller
          builder: (context, setModalState) {
            // Formun içeriğini ve durum güncelleme fonksiyonunu sağlar
            return Padding(
              // Formun etrafına boşluk ekler
              // Klavye açıldığında formun yukarı çıkmasını sağlar.
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom, // Klavyenin kapladığı alan kadar alt boşluk bırakır
              ),

              child: SafeArea(
                // Formun sistem arayüzüyle çakışmasını önler
                top: false, // Üst güvenli alan boşluğunu uygulamaz
                child: SingleChildScrollView(
                  // Form içeriğinin kaydırılmasını sağlar
                  padding: const EdgeInsets.all(24), // iç boşluk ekler

                  child: Form(
                    // Giriş alanlarını tek form altında toplar
                    key: formKey, // Formun doğrulama işlemlerine erişilmesini sağlar

                    child: Column(
                      // Form elemanlarını dikey sıralar
                      mainAxisSize:
                          MainAxisSize.min, // İçerik kadar yükseklik kullanır
                      crossAxisAlignment: CrossAxisAlignment
                          .start, // Form elemanlarını sola hizalar
                      children: [
                        // Üst başlık
                        Row(
                          // Başlık ve kapatma butonunu yatay yerleştirir
                          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Elemanları satırın iki ucuna yerleştirir
                          children: [
                            const Text(
                              "Para Transferi",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            IconButton(
                              // Formu kapatmak için ikon butonu
                              onPressed:
                                  isSubmitting // İşlem devam ederken kapatma butonunu devre dışı bırakır
                                  ? null
                                  : () => Navigator.pop(
                                      context,
                                    ), // Form penceresini kapatır
                              icon: const Icon(Icons.close), // Kapatma ikonu
                            ),
                          ],
                        ),

                        const SizedBox(height: 8), // boşluk ekler

                        const Text(
                          "Alıcı bilgilerini ve transfer tutarını giriniz.",
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),

                        const SizedBox(height: 24),

                        // ALICI ADI
                        TextFormField(
                          controller:
                              nameController, // Girilen alıcı adını saklar
                          textCapitalization: TextCapitalization.words, // Kelimelerin ilk harflerini büyük yazmayı önerir
                          decoration: InputDecoration(
                            labelText:
                                "Alıcı Adı Soyadı", // Giriş alanının başlığı
                            hintText: "Örn: Ahmet Yılmaz", // Kullanıcıya örnek giriş gösterir
                            prefixIcon: const Icon(
                              Icons.person,
                            ), // Alanın başına kişi ikonu ekler
                            border: OutlineInputBorder(
                              // Metin alanını çerçeve içine alır
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // Çerçevenin köşelerini yuvarlar
                            ),
                          ),

                          // validator: Hatalı girişte uyarı verir.
                          validator: (value) {
                            // Girilen alıcı adının geçerli olup olmadığını kontrol eder
                            if (value == null || value.trim().isEmpty) {
                              // Alanın boş olup olmadığını kontrol eder
                              return "Alıcı adı boş bırakılamaz"; // Boş girişte hata mesajı döndürür
                            }

                            if (value.trim().length < 3) {
                              // İsmin en az üç karakter olup olmadığını kontrol eder kısaysa hata mesajı
                              return "En az 3 karakter giriniz";
                            }

                            return null; // Hata yoksa alanın geçerli olduğunu belirtir
                          },
                        ),

                        const SizedBox(height: 16),

                        // IBAN
                        TextFormField(
                          controller: ibanController, // Kullanıcının girdiği IBAN bilgisi
                          textCapitalization: TextCapitalization
                              .characters, // Harflerin büyük yazılmasını önerir
                          decoration: InputDecoration(
                            labelText: "IBAN",
                            hintText: "TR00 0000 0000 0000 0000 0000 00",
                            prefixIcon: const Icon(
                              Icons.account_balance,
                            ), // IBAN alanına banka ikonu ekler
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          validator: (value) {
                            // IBAN formatını ve kontrol basamaklarını doğrular
                            final iban =
                                (value ?? "") // Boş değer gelirse boş metin kullanır
                                    .replaceAll(
                                      RegExp(r'\s+'),
                                      '',
                                    ) // IBAN içindeki boşlukları kaldırır
                                    .toUpperCase(); // Harfleri büyük harfe çevirir

                            if (iban.isEmpty) {
                              // IBAN bilgisinin boş olup olmadığını kontrol eder
                              return "IBAN boş bırakılamaz";
                            }

                            // Türkiye IBAN'ı 26 karakterdir.
                            if (!RegExp(r'^TR[0-9]{24}$').hasMatch(iban)) {
                              // IBAN'ın TR ile başlayıp 24 rakamla devam ettiğini kontrol eder
                              return "Geçerli formatta TR IBAN giriniz";
                            }
                            //IBANın ilk 4 karakteri sona taşşnır harfler sayıya çevrilir a=10  vb.  Oluşan büyük sayının 97 e bölümünden kalan 1 ise kontrol geçerli

                            // IBAN kontrol basamakları (mod 97)
                            final rearranged = // IBAN doğrulaması için yeniden düzenlenmiş metni tutar
                                iban.substring(4) +
                                iban.substring(
                                  0,
                                  4,
                                ); // İlk dört karakteri sona taşır

                            int remainder =
                                0; // Mod 97 hesabında kullanılacak kalanı tutar

                            for (final char in rearranged.codeUnits) {
                              // IBAN karakterlerini sayısal kodlarıyla sırayla işler
                              if (char >= 48 && char <= 57) {
                                // Karakterin rakam olup olmadığını kontrol eder
                                remainder = (remainder * 10 + char - 48) % 97; // Rakamı hesaplamaya ekleyerek kalanı günceller
                              } else {
                                final number = char - 55; // Harfi IBAN standardındaki sayısal karşılığına çevirir

                                remainder = (remainder * 100 + number) % 97; // Harfin iki basamaklı değerini hesaplamaya ekler
                              }
                            }

                            if (remainder != 1) {
                              // IBAN kontrol sonucunun geçerli olup olmadığını kontrol eder
                              return "IBAN kontrol basamakları hatalı";
                            }

                            return null; // IBAN geçerliyse hata döndürmez
                          },
                        ),

                        const SizedBox(height: 16),

                        // TRANSFER TUTARI
                        TextFormField(
                          controller: amountController, // Kullanıcının girdiği tutarı saklar
                          keyboardType: const TextInputType.numberWithOptions(
                            // Sayısal girişe uygun klavye açar
                            decimal: true, // Ondalıklı sayı girişini destekler
                          ),
                          decoration: InputDecoration(
                            labelText: "Transfer Tutarı",
                            hintText: "Örn: 1500",
                            prefixIcon: const Icon(
                              Icons.currency_lira,
                            ), // Giriş alanında Türk lirası ikonu
                            suffixText: "TL", // Tutar alanının sonunda para birimini gösterir
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          validator: (value) {
                            // Girilen tutarın geçerli ve bakiyeye uygun olduğunu kontrol eder
                            if (value == null || value.trim().isEmpty) {
                              // Tutar alanının boş olup olmadığını kontrol eder
                              return "Transfer tutarı giriniz";
                            }

                            final amount = double.tryParse(
                              // Girilen metni ondalıklı sayıya dönüştürmeyi dener
                              value.trim().replaceAll(
                                ',',
                                '.',
                              ), // Virgülü noktaya çevirir
                            );

                            if (amount == null || !amount.isFinite) {
                              // Tutarın geçerli ve sonlu bir sayı olduğunu kontrol eder
                              return "Geçerli bir tutar giriniz";
                            }

                            if (amount <= 0) {
                              // Transfer tutarının sıfırdan büyük olduğunu kontrol eder
                              return "Tutar sıfırdan büyük olmalı";
                            }

                            if (amount > _balance) {
                              // Transfer tutarını mevcut bakiyeyle karşılaştırır
                              return "Yetersiz bakiye";
                            }

                            // En fazla iki ondalık basamak
                            if ((amount * 100 - (amount * 100).round()).abs() > // Tutarın kuruş hassasiyetine uygunluğunu kontrol eder
                                0.000001) {
                              // Küçük hesaplama farklarına tolerans tanır
                              return "En fazla 2 ondalık basamak giriniz";
                            }

                            return null; // Tüm kontroller geçerliyse hata döndürmez
                          },
                        ),

                        const SizedBox(height: 16),

                        Text(
                          "Kullanılabilir Bakiye: ${_formatMoney(_balance)} TL", // Mevcut bakiyeyi biçimlendirerek gösterir
                          style: const TextStyle(
                            color: Color(0xFF6366F1),
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // TRANSFER BUTONU
                        SizedBox(
                          // Transfer butonunun boyutlarını belirler
                          width: double.infinity, // Butonu kullanılabilir genişliğe yayar
                          height: 52, // Butonun yüksekliğini belirler
                          child: ElevatedButton.icon(
                            // İkon ve metin içeren transfer butonu oluşturur
                            onPressed:
                                isSubmitting // İşlem devam ederken tekrar basılmasını engeller
                                ? null
                                : () {
                                    // Butona basıldığında transfer işlemlerini başlatır
                                    // Önce formu doğrula.
                                    if (!formKey.currentState!.validate()) {
                                      // Formdaki tüm giriş alanlarını doğrular
                                      return; // Hatalı giriş varsa işlemi durdurur
                                    }

                                    setModalState(() {
                                      // Formun kendi durumunu günceller
                                      isSubmitting = true; // Transfer butonunu devre dışı bırakır
                                    });

                                    final name = nameController.text.trim(); // Alıcının adını baştaki ve sondaki boşlukları kaldırarak alır
                                    final amount = double.parse(
                                      // Girilen transfer tutarını sayıya dönüştürür
                                      amountController.text.trim().replaceAll(
                                        ',',
                                        '.',
                                      ),
                                    );

                                    // Bu örnekte gerçek bankaya
                                    // para gönderilmez.
                                    // Sadece yerel state değişir.
                                    _completeTransfer(name, amount); // Bakiyeyi ve yerel işlem geçmişini günceller

                                    Navigator.pop(sheetContext); // Transfer tamamlandığında form penceresini kapatır
                                  },

                            icon: const Icon(
                              Icons.send,
                            ), // Butonda gönderme ikonunu gösterir
                            label: const Text(
                              "Transferi Tamamla",
                              style: TextStyle(fontSize: 16),
                            ),

                            style: ElevatedButton.styleFrom(
                              // Butonun renk ve kenar görünümünü ayarlar
                              backgroundColor: const Color(
                                0xFF6366F1,
                              ), // Butonun arka plan rengini belirler
                              foregroundColor: Colors.white, // Butondaki yazı ve ikonları beyaz yapar
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  12,
                                ), // Buton köşelerini yuvarlar
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
      // Form penceresi kapandığında temizlik işlemlerini çalıştırır
      // Modal kapandığında controller'ları temizle.
      nameController
          .dispose(); // Alıcı adı controller'ının kaynaklarını serbest bırakır
      ibanController
          .dispose(); // IBAN controller'ının kaynaklarını serbest bırakır
      amountController
          .dispose(); // Tutar controller'ının kaynaklarını serbest bırakır
    });
  }

  // ==================================================
  // 2. TRANSFER İŞLEMİNİ TAMAMLA
  //
  // setState:
  // Bakiyeyi ve işlem geçmişini günceller.
  // ==================================================
  void _completeTransfer(String name, double amount) {
    // Transfer bilgilerini kullanarak bakiyeyi ve geçmişi günceller
    final now =
        DateTime.now(); // İşlemin gerçekleştiği güncel tarih ve saati alır

    setState(() {
      // Değişen bakiye ve işlem listesinin ekrana yansımasını sağlar
      // Transfer tutarını bakiyeden düş.
      _balance = ((_balance * 100).round() - (amount * 100).round()) / 100; // Kuruş üzerinden hesaplayarak transfer tutarını bakiyeden çıkarır

      // Yeni işlemi listenin başına ekle.
      _history.insert(
        // Yeni transferi işlem geçmişinin en başına ekler
        0, // Yeni işlemin ilk sıraya yerleşmesini sağlar
        TransactionItem(
          // Transfer bilgileriyle yeni bir işlem nesnesi oluşturur
          id: 'tx_${now.microsecondsSinceEpoch}', // Zaman bilgisini kullanarak işlem kimliği oluşturur
          title: name, // İşlem başlığında alıcının adını kullanır
          category:
              "Hızlı Transfer", // İşlem türünü hızlı transfer olarak belirler
          date:
              "Bugün ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}", // Güncel saati iki basamaklı biçimde gösterir
          amount: amount, // İşlem tutarını kaydeder
          icon: Icons.send_rounded, // İşlem için gönderme ikonunu belirler
          isExpanse: true, // Transferi gider işlemi olarak kaydeder
        ),
      );
    });

    // Kullanıcıya başarılı işlem mesajı göster.
    ScaffoldMessenger.of(context).showSnackBar(
      // İşlem sonrası ekranda bilgilendirme mesajı gösterir
      SnackBar(
        content: Text(
          "$name kişisine ${_formatMoney(amount)} TL transfer kaydedildi.", // Alıcı ve tutar bilgilerini içeren mesajı oluşturur
        ),
        backgroundColor:
            Colors.green, // Başarı mesajının arka planını yeşil yapar
        behavior: SnackBarBehavior
            .floating, // Mesajı ekranda yüzen kutu şeklinde gösterir
      ),
    );
  }

  // Para değerlerini Türkçe biçimde göstermek için
  String _formatMoney(double amount) {
    // Para tutarını binlik ayraç ve virgülle biçimlendirir
    final parts = amount.toStringAsFixed(2).split('.'); // Tutarı iki ondalık basamağa çevirip tam ve ondalık kısımlara ayırır
    final digits = parts[0]; // Tutarın tam sayı kısmını alır

    final buffer = StringBuffer(); // Biçimlendirilmiş para metnini oluşturmak için kullanılır

    for (int i = 0; i < digits.length; i++) {
      // Tam sayı kısmındaki rakamları sırayla işler
      if (i > 0 && (digits.length - i) % 3 == 0) {
        // Her üç basamakta bir ayraç eklenmesi gerekip gerekmediğini kontrol eder
        buffer.write('.'); // Binlik ayraç olarak nokta ekler
      }
      buffer.write(digits[i]); // Sıradaki rakamı biçimlendirilen metne ekler
    }

    return '${buffer.toString()},${parts[1]}'; // Tam ve ondalık kısımları virgülle birleştirir
  }

  // ==================================================
  // 3. ANA EKRAN
  // ==================================================
  @override // Üst sınıftaki build metodunu yeniden tanımlar
  Widget build(BuildContext context) {
    // Transfer ekranının arayüzünü oluşturur
    return SingleChildScrollView(
      // Ekrandaki içeriğin kaydırılabilmesini sağlar
      physics: const BouncingScrollPhysics(), // Kaydırma sınırında esneme efekti uygular
      padding: const EdgeInsets.all(
        20,
      ), // Ekran içeriğine her yönden boşluk ekler

      child: Column(
        // Ekrandaki bileşenleri dikey sıralar
        crossAxisAlignment: CrossAxisAlignment.start, // İçerikleri sola hizalar
        children: [
          const Text(
            "Para Transferi",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ), // Ana başlığın görünümünü belirler
          ),

          const SizedBox(height: 6), // Başlık ile açıklama arasına boşluk ekler

          const Text(
            "Bakiyeni yönet ve hızlı transfer yap.",
            style: TextStyle(
              color: Color(0xFF64748B),
            ), // Açıklama yazısının rengini belirler
          ),

          const SizedBox(height: 24),

          // Bakiye kartı
          _buildBalanceCard(), // Kullanıcının mevcut bakiyesini gösteren kartı oluşturur

          const SizedBox(height: 24),

          // Para gönder butonu
          SizedBox(
            // Para gönder butonunun boyutlarını ayarlar
            width: double
                .infinity, // Butonu ekranın kullanılabilir genişliğine yayar
            height: 55, // Buton yüksekliğini belirler
            child: ElevatedButton.icon(
              // İkonlu para transferi butonu oluşturur
              onPressed: _openTransferModel, // Butona basıldığında transfer formunu açar
              icon: const Icon(
                Icons.send_rounded,
              ), // Butonda gönderme ikonunu gösterir
              label: const Text(
                "Yeni Transfer Yap",
                style: TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                // Butonun renk ve kenar görünümünü belirler
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    14,
                  ), // Buton köşelerini yuvarlar
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // İşlem geçmişi
          _buildTransactionHistory(), // Önceki transfer işlemlerini ekranda listeler
        ],
      ),
    );
  }

  // ==================================================
  // 4. BAKİYE KARTI
  // ==================================================
  Widget _buildBalanceCard() {
    // Kullanıcının mevcut bakiyesini gösteren kartı oluşturur
    return Container(
      // Bakiye kartının dış kutusunu oluşturur
      width: double.infinity, // Kartı kullanılabilir genişliğe yayar
      padding: const EdgeInsets.all(24), // Kartın içeriğine boşluk ekler
      decoration: BoxDecoration(
        // Kartın renk geçişini ve köşelerini ayarlar
        gradient: const LinearGradient(
          // Kartın arka planında doğrusal renk geçişi oluşturur
          colors: [
            Color(0xFF6366F1),
            Color(0xFF4338CA),
          ], // Renk geçişinde kullanılacak iki rengi belirler
        ),
        borderRadius: BorderRadius.circular(20), // Kartın köşelerini yuvarlar
      ),

      child: Column(
        // Kart içeriğini dikey sıralar
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            // Bakiye ikonunu ve başlığını yatay yerleştirir
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
              ), // Cüzdan ikonunu gösterir
              SizedBox(width: 10), // İkon ile başlık arasına boşluk bırakır
              Text(
                "Kullanılabilir Bakiye",
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Text(
            "${_formatMoney(_balance)} TL", // Mevcut bakiyeyi Türkçe para biçiminde gösterir
            style: const TextStyle(
              fontSize: 30, // Bakiye tutarını büyük yazıyla gösterir
              fontWeight: FontWeight.bold, // Bakiye tutarını kalın yapar
              color: Colors.white, // Bakiye yazısını beyaz gösterir
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
    // Transfer geçmişi başlığını ve işlem listesini oluşturur
    return Column(
      // Başlık ve işlem listesini dikey yerleştirir
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          // Transfer geçmişi başlığını ve işlem sayısını yatay yerleştirir
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Başlık ile işlem sayısını satırın iki ucuna yerleştirir
          children: [
            const Text(
              "Transfer Geçmişi",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            Text(
              "${_history.length} işlem", // İşlem geçmişindeki toplam kayıt sayısını gösterir
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),

        const SizedBox(height: 16),

        ListView.separated(
          // Transfer işlemlerini aralarında boşluk bırakarak listeler
          shrinkWrap:
              true, // Listenin yalnızca içeriği kadar yer kaplamasını sağlar
          physics: const NeverScrollableScrollPhysics(), // Listeyi ayrıca kaydırmayı engelleyerek ana ekranın kaydırılmasını kullanır

          itemCount:
              _history.length, // Oluşturulacak işlem satırı sayısını belirler

          separatorBuilder: (context, index) {
            // İşlem satırları arasında kullanılacak boşluğu oluşturur
            return const SizedBox(
              height: 12,
            ); // İşlemler arasında 12 birim dikey boşluk bırakır
          },

          itemBuilder: (context, index) {
            // Her işlem için ayrı bir liste elemanı oluşturur
            final transaction =
                _history[index]; // Listedeki sıradaki transfer işlemini alır

            return _buildTransactionItem(
              transaction,
            ); // İşlem bilgilerini kart oluşturma metoduna gönderir
          },
        ),
      ],
    );
  }

  // ==================================================
  // 6. TEK BİR TRANSFER İŞLEMİ
  // ==================================================
  Widget _buildTransactionItem(TransactionItem transaction) {
    // Tek bir transfer işleminin kart görünümünü oluşturur
    final bool isExpense =
        transaction.isExpanse; // İşlemin gider olup olmadığını kontrol eder

    return Container(
      // İşlem için kart kutusu oluşturur
      padding: const EdgeInsets.all(16), // Kartın iç boşluğunu belirler
      decoration: BoxDecoration(
        // Kartın arka planını ve kenar görünümünü ayarlar
        color: Colors.white, // Kartın arka planını beyaz yapar
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ), // Kartın çevresine ince kenarlık ekler
        borderRadius: BorderRadius.circular(14), // Kartın köşelerini yuvarlar
      ),

      child: Row(
        // İkon, işlem bilgileri ve tutarı yatay sıralar
        children: [
          // İşlem ikonu
          Container(
            // İşlem ikonunun arka plan kutusunu oluşturur
            width: 48, // İkon kutusunun genişliğini belirler
            height: 48, // İkon kutusunun yüksekliğini belirler
            decoration: BoxDecoration(
              color:
                  isExpense // Gider ve gelir için farklı arka plan renkleri seçer
                  ? const Color(
                      0xFFFEF2F2,
                    ) // Gider işlemlerinde açık kırmızı arka plan kullanır
                  : const Color(
                      0xFFF0FDF4,
                    ), // Gelir işlemlerinde açık yeşil arka plan kullanır
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transaction.icon, // İşlemin modelde tanımlanan ikonunu gösterir
              color: isExpense ? Colors.red : Colors.green, // Gider ikonunu kırmızı gelir ikonunu yeşil gösterir
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            // İşlem bilgilerinin kalan yatay alanı kullanmasını sağlar
            child: Column(
              // İşlem adı, kategorisi ve tarihi alt alta sıralar
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title, // Transfer alıcısının adı
                  maxLines: 1, // İşlem başlığını tek satırla sınırlar
                  overflow: TextOverflow
                      .ellipsis, // Uzun başlıkları üç noktayla kısaltır
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  transaction.category, // İşlemin kategorisi
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  transaction.date, // İşlemin gerçekleştiği tarih ve saat
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // İşlem tutarı
          Text(
            "${isExpense ? '-' : '+'}${_formatMoney(transaction.amount)} TL", // Gideri eksi gelirleri artı işaretiyle gösterir
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isExpense
                  ? Colors.red
                  : Colors.green, // İşlem türüne göre tutarın rengi
            ),
          ),
        ],
      ),
    );
  }
}
