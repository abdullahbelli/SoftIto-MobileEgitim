# ROTIVA — Araç Kiralama ve Takip Uygulaması

> SoftIto Mobil Geliştirme Eğitimi kapsamında geliştirilmiş, backend gerektirmeyen, Material Design 3 standartlarında mobil ve web uyumlu araç kiralama simülasyonu.

---

## 1. Proje Özeti ve Kimliği

- **Uygulama Adı:** Rotiva
- **Alt Başlık:** Araç Kiralama ve Takip
- **Hedef Platformlar:** Android, iOS, macOS, Web (Chrome)
- **Arayüz Dili:** Türkçe (Para birimi: `₺`, Tarih formatı: `GG.AA.YYYY`)
- **Tasarım Dili:** Material Design 3 (`useMaterial3: true`)
  - **Açık Tema (Light):** Mavi tonları (`#1764C0`), ferah açık mavi/beyaz yüzeyler.
  - **Koyu Tema (Dark):** Antrasit arka plan (`#15191F`), canlı turuncu vurgular (`#FF922B`).
- **Özel Logo:** Kesintisiz otoyol eğrisi ve varış noktası pinine dönüşen özel vektörel stilize `R` harfi (`RotivaLogo` CustomPainter).

---

## 2. Mimari ve Klasör Yapısı (Feature-Based)

Uygulama, iş mantığı ve arayüz katmanlarını birbirinden ayıran **Feature-Based** modüler bir mimariyle geliştirilmiştir:

```text
rotiva/
├── assets/                          # Görseller ve ikonlar
├── lib/
│   ├── main.dart                    # Bootstrap (SharedPreferences, repository ve theme başlatma)
│   ├── app.dart                     # MaterialApp, RotivaScope ve tema bağlayıcı
│   ├── core/                        # Ortak altyapı
│   │   ├── constants/
│   │   │   ├── app_constants.dart   # Sabitler, enumlar (kategori, yakıt, vites vb.)
│   │   │   └── demo_texts.dart      # KVKK, Açık Rıza ve Kiralama Sözleşmesi demo metinleri
│   │   ├── theme/
│   │   │   ├── app_theme.dart       # Material 3 Açık ve Koyu tema tanımları
│   │   │   └── theme_controller.dart # Tema modu ve SharedPreferences kalıcılığı
│   │   ├── utils/
│   │   │   ├── date_utils.dart      # Takvim gün farkı, yaş, ehliyet süresi ve çakışma kontrolleri
│   │   │   ├── formatters.dart      # Para formatlama (1.200 ₺), telefon ve rezervasyon kodu
│   │   │   └── validators.dart      # Form doğrulayıcıları (e-posta, şifre, telefon, pozitif sayı)
│   │   └── widgets/
│   │       ├── rotiva_logo.dart     # Özgün CustomPainter marka logosu
│   │       ├── rotiva_scope.dart    # Repository ve controller sağlayan InheritedWidget
│   │       ├── vehicle_card.dart    # Araç kartı bileşeni (rozetler, puan, özellikler)
│   │       ├── status_badge.dart    # Kiralama ve ödeme durumu rozetleri
│   │       ├── empty_state_view.dart # Liste boş / sonuç yok durumu
│   │       ├── section_header.dart  # Bölüm başlığı bileşeni
│   │       └── dialogs.dart         # Sözleşme, teyit ve SnackBar yardımcıları
│   ├── data/
│   │   ├── mock/
│   │   │   └── mock_seed.dart       # 12 araç, 5 müşteri, 1 yönetici ve örnek kiralama seed verileri
│   │   └── repositories/
│   │       └── app_repository.dart  # Single Source of Truth bellek içi CRUD + SharedPreferences senkronizasyonu
│   └── features/
│       ├── auth/                    # Karşılama, müşteri girişi, kayıt ve yönetici girişi
│       │   ├── models/app_user.dart
│       │   └── view/                # WelcomeScreen, CustomerLoginScreen, RegisterScreen, AdminLoginScreen
│       ├── home/                    # Müşteri ana kabuğu, il/ilçe/tarih arama
│       │   └── view/                # CustomerShellScreen, HomeTabView
│       ├── vehicles/                # Araç listeleme, detaylı filtreleme, araç detay
│       │   ├── models/vehicle.dart
│       │   └── view/                # VehiclesTabView, VehicleDetailScreen
│       ├── rentals/                 # Kiralama formu, fiyatlandırma motoru, kiralamalarım ve yorumlar
│       │   ├── models/              # Rental, Review, RentalPricing (Pure Business Logic)
│       │   └── view/                # RentalFormScreen, MyRentalsTabView
│       ├── payments/                # Kredi kartı, EFT ve nakit ödeme simülasyonu
│       │   └── view/                # PaymentSimulationScreen
│       ├── profile/                 # Profil, sürücü belgesi düzenleme, tema ayarı
│       │   └── view/                # ProfileTabView
│       └── admin/                   # Yönetici Dashboard, Araç CRUD, Kiralama Takibi, Müşteriler
│           └── view/                # AdminShellScreen, AdminDashboardTab, AdminVehiclesTab,
│                                    # AdminVehicleFormScreen, AdminRentalsTab, AdminCustomersTab
├── test/
│   ├── unit/
│   │   ├── rental_pricing_test.dart # Fiyat formülleri, ek km ve %10 nakit indirimi testleri
│   │   ├── date_utils_test.dart     # Tarih çakışması, tam yaş ve ehliyet süresi testleri
│   │   ├── validators_test.dart     # Form alan doğrulamaları testleri
│   │   └── repository_test.dart     # CRUD, aktif kiralama silme engeli ve mükerrer kayıt testleri
│   └── widget_test.dart             # UI açılışı, KVKK onay zorunluluğu ve tema geçiş testleri
└── pubspec.yaml
```

---

## 3. Ekranlar ve Fonksiyonel Özellikler

### 3.1 Kimlik Doğrulama ve Karşılama
- **WelcomeScreen:** Marka logosu, özellik tanıtım kartı, Müşteri Girişi, Kayıt Ol ve Yönetici Girişi butonları.
- **CustomerLoginScreen:** E-posta ve şifre doğrulaması. Hızlı demo müşteri çipleri (Ahmet, Ayşe, Can).
- **RegisterScreen:** Ad Soyad, E-posta, Telefon, Parola ve Parola Tekrarı.
  - **Zorunlu KVKK Aydınlatma Metni:** "Metni İncele" butonuyla kaydırılabilir diyalogda okunur.
  - **Zorunlu Açık Rıza Metni:** Ayrı diyalogla görüntülenir.
  - İki onay kutusu da işaretlenmeden kayıt tamamlanamaz.
  - Mükerrer e-posta kontrolü yapılır; kayıt tamamlanınca otomatik oturum açılır.
- **AdminLoginScreen:** Müşteriden tamamen ayrı yönetici giriş ekranı. Belirgin sarı demo uyarı bandı ve tek dokunuşla demo yönetici doldurma çipi.

### 3.2 Müşteri Ekranları
- **HomeTabView (Ana Sayfa):**
  - Üstte kullanıcı karşılama ve anlık tema değiştirme butonu.
  - **Hızlı Arama Paneli:** İl seçimi (İstanbul, Ankara, İzmir, Antalya, Bursa), ile bağlı dinamik ilçe seçimi (il değişince ilçe otomatik sıfırlanır) ve `showDateRangePicker` ile tarih aralığı seçimi.
  - Seçilen tarih aralığında çakışan kiralaması olan araçlar otomatik filtrelenir; yalnızca gerçekten müsait araçlar listelenir.
  - Arama kriterlerini sıfırlama seçeneği.
- **VehiclesTabView (Araçlar):**
  - Canlı metin araması (marka/model/şehir).
  - Kategori filtre çipleri (Sedan, SUV, Hatchback, Station Wagon, Ticari).
  - Vites türü, yakıt türü ve şehir seçim menüleri.
  - Fiyat aralığı alt sayfası (Slider ile maksimum günlük ücret belirleme).
- **VehicleDetailScreen (Araç Detayı):**
  - Araç görseli, marka, model, yıl, lokasyon, günlük ve bilgi amaçlı saatlik ücret.
  - Müşteri değerlendirme yıldızları ve ortalama puanı (hiç yorum yoksa "Henüz değerlendirme yok").
  - Yakıt, vites, standart günlük km sınırı ve ek km paketi detayları.
  - Minimum sürücü yaşı ve minimum ehliyet yılı şartları.
  - Belirgin "Hemen Kirala" butonu.
- **RentalFormScreen (Kiralama Formu):**
  - Tarih aralığı seçimi (takvim günü farkı en az 1 gün).
  - Teslimat tercihi: **Şubeden Teslim** veya **Adrese Teslim (+ücret)**.
  - Adrese teslim seçildiğinde teslimat adresi alanı zorunlu hale gelir.
  - Kilometre paketi: Standart limit veya Günlük Ek KM paketi.
  - Sürücü yaşı ve ehliyet süresi denetimi (profilde eksikse bu ekranda tarih seçtirilir; aracın şartlarını sağlamayan sürücüler net bir uyarıyla engellenir).
  - Gerçek zamanlı fiyat dökümü kartı.
  - **Kiralama Sözleşmesi Diyaloğu:** Tam metin diyalogda okunur; "Sözleşmeyi okudum ve şartları kabul ediyorum" onaylanmadan ödeme butonuna basılamaz.
- **PaymentSimulationScreen (Ödeme Simülasyonu):**
  - Kredi Kartı, EFT/Havale ve Şubede Nakit seçenekleri.
  - **İş Kuralı 1:** Adrese teslimat seçiliyken "Şubede Nakit" seçeneği **devre dışı bırakılır** ve kırmızı uyarı metni gösterilir.
  - **İş Kuralı 2:** Şubeden teslim + Şubede nakit ödemede araç ve ek km tutarı üzerinden **%10 indirim** anında hesaplanır ve özet kartında yeşil renkle gösterilir.
  - Rezervasyon kodu üretilerek (`RTV-2026-XXXX`) başarılı işlem diyaloğu açılır ve kullanıcı "Kiralamalarım" sekmesine yönlendirilir.
- **MyRentalsTabView (Kiralamalarım):**
  - Kullanıcının aktif, onaylı ve tamamlanmış kiralamaları.
  - Rezervasyon kodu, tarih aralığı, teslim türü, ödeme yöntemi ve durum rozetleri.
  - Tamamlanmış kiralamalar için **"Aracı Değerlendir & Yorum Yaz"** butonu (1-5 yıldız ve yorum; aynı kiralamaya mükerrer yorum engeli).
- **ProfileTabView (Profil):**
  - Kullanıcı iletişim bilgileri, doğum tarihi ve ehliyet alış tarihi güncelleme diyaloğu.
  - Demo Müşteri Puanı rozeti.
  - Açık, Koyu veya Sistem tema seçicisi.
  - "Demo Verilerini Sıfırla" butonu ve Oturumu Kapat seçeneği.

### 3.3 Yönetici Ekranları (Admin Panel)
- **AdminDashboardTab (Özet Paneli):**
  - Toplam Müşteri, Toplam Araç, Aktif Rezervasyon Sayısı, Bekleyen Şube Nakit Tahsilatı ve Toplam Kiralama Cirosu KPI metrik kartları.
  - Son kiralama hareketlerinin özet listesi.
- **AdminVehiclesTab (Araç Yönetimi):**
  - Filodaki tüm araçlar, aktif/pasif durumu.
  - Tek dokunuşla aracı yeni kiralamalara kapatma (Pasife alma anahtarı).
  - Araç düzenleme butonu.
  - **Aktif Kiralama Korumalı Silme (Madde 101):** Onaylanmış veya aktif kiralaması olan bir araç silinmek istendiğinde işlem **engellenir** ve yöneticiye açıklayıcı bir bilgilendirme diyaloğu sunulur. Yalnızca kiralaması olmayan araçlar onay ile silinebilir.
  - Yeni Araç Ekle FAB butonu.
- **AdminVehicleFormScreen (Araç Ekleme/Düzenleme Formu):**
  - Marka, model, yıl, kategori, yakıt, vites, şehir, ilçe, günlük ücret, saatlik ücret, teslimat ücreti, ek km paketi, minimum yaş ve ehliyet yılı alanlarının tamamını içeren eksiksiz form.
- **AdminRentalsTab (Kiralama ve Eşleştirme Yönetimi):**
  - Hangi aracın hangi müşteride olduğu, kiralama tarih aralığı, teslim tipi, ödeme yöntemi ve tutarı.
  - Kiralama durumu filtreleme çipleri (Tümü, Onaylandı, Aktif, Tamamlandı, İptal).
  - **Durum Geçiş Yönetimi:** Yönetici açılır menü ile kiralamayı onaylayabilir, aracı aktif hale getirebilir veya tamamlandı durumuna alabilir.
- **AdminCustomersTab (Müşteri Listesi):**
  - Kayıtlı müşterilerin ad soyad, telefon, e-posta, kayıt tarihi, toplam kiralama sayısı ve demo müşteri puanı.

---

## 4. İş Kuralları ve Hesaplama Formülleri

1. **Takvim Günü:**
   `rentalDays = endDate.difference(startDate).inDays;` (Minimum 1 gün). Aralık `[startDate, endDate)` olarak hesaplanır.
2. **Çakışma Kontrolü:**
   `newStart.isBefore(oldEnd) && oldStart.isBefore(newEnd)` (İptal edilmemiş tüm rezervasyonlar için kontrol edilir).
3. **Fiyat Formülü:**
   - `basePrice = rentalDays * dailyRate`
   - `extraKmCost = hasExtraKm ? (rentalDays * additionalKmDailyPrice) : 0`
   - `deliveryFee = (deliveryType == DeliveryType.address) ? addressDeliveryFee : 0`
   - `discount = (deliveryType == DeliveryType.branch && paymentMethod == PaymentMethod.cashAtBranch) ? (basePrice + extraKmCost) * 0.10 : 0`
   - `finalPrice = basePrice + extraKmCost + deliveryFee - discount`
4. **Adrese Teslim Kuralı:**
   Adrese teslimde nakit ödeme yapılamaz. Nakit seçeneği kilitlenir.
5. **Yaş ve Ehliyet Kuralı:**
   Takvim yılı farkı değil, doğum günü ve ehliyet alış gününe göre tam geçen yıl hesabı yapılır.

---

## 5. Demo Giriş Bilgileri

| Rol | E-posta | Şifre | Açıklama |
|---|---|---|---|
| **Yönetici** | `admin@rotiva.com` | `admin` | Tam yetkili filo ve kiralama yönetimi paneli |
| **Müşteri 1** | `ahmet@rotiva.com` | `123456` | 31 yaşında, 11 yıllık ehliyet, tamamlanmış kiralaması var |
| **Müşteri 2** | `ayse@rotiva.com` | `123456` | 28 yaşında, 8 yıllık ehliyet, aktif kiralaması var |
| **Müşteri 3** | `can@rotiva.com` | `123456` | 22 yaşında, 2 yıllık ehliyet (genç sürücü kısıtı testi) |

*Not: Giriş ekranlarındaki hızlı çiplere tıklanarak formlar otomatik doldurulabilir.*

---

## 6. Kurulum ve Çalıştırma

### Bağımlılıkları yükleyin:
```bash
flutter pub get
```

### Kod formatını denetleyin:
```bash
dart format .
```

### Statik analizi çalıştırın (0 Hata / 0 Uyarı):
```bash
dart analyze
```

### Otomatik testleri çalıştırın (22/22 Başarılı):
```bash
flutter test
```

### Uygulamayı Chrome üzerinde başlatın:
```bash
flutter run -d chrome
```

### Android emülatöründe başlatın:
```bash
flutter run
```

---

## 7. Test Sonuçları Özeti

Uygulama kapsamında yazılan tüm birim ve widget testleri başarıyla geçmiştir:

- `test/unit/rental_pricing_test.dart` (5 Test):
  - 3 gün x 1000 ₺ = 3000 ₺ standart kiralama hesabı
  - 3 gün x 200 ₺ ek km = 600 ₺ hesaplama
  - Şubeden teslim + şubede nakitte (3000+600) üzerinden %10 (360 ₺) indirim ile 3240 ₺
  - Adrese teslimatta (450 ₺) 4050 ₺ ve nakit engeli kontrolü
  - Parametre değişikliklerinde anında dinamik fiyat güncellemesi
- `test/unit/date_utils_test.dart` (4 Test):
  - `[10, 13)` ile `[13, 15)` çakışmazlık, `[12, 15)` ve `[8, 11)` çakışma kuralları
  - Minimum 1 gün hesaplama
  - Tam geçen yaş ve ehliyet yılı hesaplamaları
- `test/unit/validators_test.dart` (5 Test):
  - E-posta formatı, şifre uzunluğu ve eşleşmesi, telefon ve pozitif sayı testleri
- `test/unit/repository_test.dart` (5 Test):
  - Seed başlatma, aktif kiralamalı aracın silinmesinin engellenmesi, araç CRUD, mükerrer yorum engeli ve mükerrer e-posta kayıt engeli
- `test/widget_test.dart` (3 Test):
  - WelcomeScreen bileşenlerinin render edilmesi
  - RegisterScreen üzerinde KVKK ve Açık Rıza onaylanmadan kayıt butonunun disabled kalması
  - Açık ve Koyu tema geçişi

**Sonuç: 22/22 Test Başarılı!**

---

## 8. Bilinen Sınırlar ve Eğitim Kapsamı

1. **Backend Yoktur:** Gerçek sunucu, veritabanı veya bulut servisi bulunmamaktadır. Tüm veriler bellek içi `AppRepository` üzerinde tutulur ve `SharedPreferences` aracılığıyla cihazda yerel JSON olarak saklanır.
2. **Ödeme Simülasyonudur:** Gerçek kart bilgisi, CVV veya IBAN alınmaz ve saklanmaz. Kredi kartı ve banka EFT işlemleri eğitim amaçlı simüle edilir.
3. **Demo Hukuki Metinler:** KVKK Aydınlatma, Açık Rıza ve Kiralama Sözleşmesi metinleri SoftIto eğitim simülasyonu amaçlıdır; gerçek hayatta hukuki geçerliliği yoktur.
