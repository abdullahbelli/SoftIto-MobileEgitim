# ROTIVA — Proje Tanımı ve Ürün Gereksinimleri

> SoftIto Flutter yüz yüze dersi için **backend olmadan** yapılacak başlangıç düzeyi araç kiralama ve araç takip uygulaması.
> Bu dosya **NE yapılacağını** anlatır. `.agents/skills/` altındaki belgeler **NASIL yapılacağını** belirler.

## 1. Proje kimliği
- **Uygulama adı:** Rotiva
- **Alt başlık:** Araç Kiralama ve Takip
- **Dil ve hedef:** Türkçe, mobil öncelikli Flutter uygulaması; Chrome üzerinde de çalışabilmeli.
- **Görsel stil:** Material Design 3, sade ve modern. Light temada mavi, dark temada turuncu aksan.
- **Logo konsepti:** Yuvarlatılmış kare içinde kesintisiz bir yol izine dönüşen stilize `R` harfi. Küçük boyutlarda okunabilir olmalı. İkon uygulama içinde çizilebilir (CustomPainter/SVG asset) ve telifli marka logosu kopyalanmamalı.
- **Kapsam:** Eğitim demosu; gerçek kiralama, tahsilat, kimlik doğrulama veya hukuki onay altyapısı değildir.

## 2. Kesinlikle gösterilmesi gereken ders kazanımları
1. Temel UI: `Scaffold`, `AppBar`, `NavigationBar`/`NavigationRail` gerektikçe, `Card`, `ListTile`, `ListView`, `GridView`, `Chip`, `Icon`, `Image`, `Text`.
2. Etkileşim: `FilledButton`, `OutlinedButton`, `IconButton`, `TextButton`, seçim kontrolleri, sayaçlar ve kullanıcı geri bildirimi.
3. `Form`, `TextFormField`, `GlobalKey<FormState>` ve alan bazlı doğrulamalar.
4. Kullanıcı kayıt/giriş/çıkış ve **müşteri / yönetici rolüne göre yönlendirme** (tamamen yerel DEMO).
5. `ThemeData(useMaterial3: true)`, `ColorScheme.fromSeed`, light/dark tema; uygulama içinden anında değiştirilebilmeli.
6. `AlertDialog`, `showDialog`, `showDateRangePicker`, seçim ve teyit diyalogları.
7. Durum yönetimi, ekranlar arası veri aktarımı, temel CRUD ve basit hesaplama işlevleri.

## 3. Bilinçli kapsam dışı
- Backend, REST API, Firebase, Supabase, SQL sunucusu, gerçek e-posta/SMS gönderimi.
- Gerçek banka/kart işlemi, EFT doğrulaması, banka hesabı veya kart verisi toplama.
- Gerçek kimlik doğrulama güvenliği, gerçek hukuki uyumluluk iddiası.
- Canlı harita, GPS, gerçek zamanlı filo takibi, push bildirimi ve gelişmiş takvim altyapısı.
- Karmaşık DI, code generation, aşırı paket kullanımı ve üretim ortamı ölçeğinde altyapı.

## 4. Kullanıcı rollerinin kapsamı
### 4.1 Ziyaretçi
- Açılış ekranından müşteri girişi, kayıt ol ve ayrı yönetici girişi seçeneklerini görür.
- Demo araçlarını görebilir veya müşteri girişi sonrası ana sayfaya geçebilir; ilk sürümde ana sayfa yalnız müşteri girişiyle açılabilir.
### 4.2 Müşteri
- Kayıt/giriş/çıkış, araç arama, filtreleme, araç detayları, rezervasyon, ödeme tercihi, kiralama geçmişi, kendi değerlendirmeleri ve profil/tema ayarı.
### 4.3 Yönetici
- Ayrı giriş ekranı, özet paneli, müşteri listesi, araç listesi, araç ekleme/düzenleme/silme, aktif kiralamalar, araç-müşteri eşleştirmesi, teslimat/ödeme bilgileri ve müşteri puanları.
- Yöneticiler müşteri ekranında kiralama yapmaz; müşteri ve yönetici navigasyonu ayrıdır.

## 5. Uygulama ekranları ve kabul kriterleri
### 5.1 Karşılama ve kimlik doğrulama
- `WelcomeScreen`: uygulama logosu, kısa açıklama, Giriş Yap / Kayıt Ol / Yönetici Girişi.
- `CustomerLoginScreen`: e-posta, parola; boş/geçersiz girişte hata; yanlış bilgide `SnackBar`.
- `RegisterScreen`: ad, soyad (veya tek ad soyad alanı), e-posta, telefon, parola, parola tekrar.
  - Zorunlu kabul kutuları: **KVKK aydınlatma metnini okudum** ve eğitim demosu gereği **açık rıza metnini kabul ediyorum**. İkisi işaretli değilse buton devre dışı / gönderimde doğrulama hatası.
  - Metinler bağlantı/etikete dokunulunca ayrı `AlertDialog` veya kaydırılabilir dialog açılır; tam metin okunabilir.
  - Hukuki not: Gerçek uygulamada aydınlatma ve açık rıza farklı hukuki kavramlardır; açık rızanın hizmetin zorunlu koşulu yapılması uygun olmayabilir. Metinler **DEMO metnidir**, hukukçu kontrolü olmadan kullanılmaz.
- `AdminLoginScreen`: müşteriden ayrı giriş; arayüzde **DEMO yönetici** uyarısı.
- Form validator: boş, e-posta biçimi, telefon biçimi, şifre uzunluğu, eşleşme, aynı e-posta kaydı.
- Kimlik doğrulama yalnız simülasyondur: uygulama içinde başlangıç demo yöneticisi ve yerel müşteri listesi. Parola kalıcı düz metin olarak saklanmamalı; bu temel demo gerçek hesap güvenliği sağlamaz. Basit başlangıçta oturum/senaryo mantığı örnek verilerle yapılır.

### 5.2 Müşteri ana sayfası
- Üst bölümde karşılama, tema değiştirme ve çıkış/profil.
- Arama paneli: **il**, seçilen ile bağlı **ilçe**, **başlangıç-bitiş tarihi** (başlangıç bugün veya sonrası, bitiş başlangıçtan sonra).
- Alt bölümde tüm aktif araçlar; tarih/lokasyon seçildiyse uygun sonuçlar, sonuç sayısı ve boş liste mesajı.
- Her araç kartında fotoğraf, marka/model, şehir/ilçe, günlük fiyat, yakıt/vites, puan (varsa) ve detay butonu.
- Filtreleri sıfırla seçeneği bulunur.

### 5.3 Araç listeleme ve filtreleme
- Metinle marka/model araması, araç tipi (sedan/SUV/hatchback vb.), marka, yakıt (benzin/dizel/hibrit/elektrik), vites (manuel/otomatik), il/ilçe, uygun tarih aralığı.
- Filtreler birleştirilir; seçili filtreler `FilterChip`/`ChoiceChip` ile anlaşılır gösterilir.
- Sonuç yoksa açıklayıcı boş durum ve filtreyi temizleme aksiyonu.

### 5.4 Araç detay sayfası
- Araç fotoğrafı, marka/model/yıl, tipi, yakıt, vites, bulunduğu il/ilçe, saatlik ve günlük ücret.
- Ortalama değerlendirme puanı ve yorumlar; hiç yorum yoksa "Henüz değerlendirme yok".
- Minimum sürücü yaşı, minimum ehliyet yılı, standart günlük km limiti, fazla km paketi seçenekleri (örn. günlük +100 km için ek fiyat).
- Kurallar, araç özellikleri ve belirgin **Kirala** butonu.
- Kiralama öncesi profil yaşı ve ehliyet yaşı yeterli değilse açıklayıcı engel/uyarı gösterilir. Kayıtta doğum tarihi ve ehliyet yılı istenmediğinden, bu alanlar kiralama sırasında kısa formda tamamlanabilir.

### 5.5 Kiralama formu ve sözleşme
- Başlangıç-bitiş tarihi; kiralanan gün sayısı **takvim farkına göre minimum 1 gün**.
- İl/ilçe seçimi; araç şubesinin konumu belli; farklı şube teslimi desteklenmiyor.
- Teslim tipi: **Şubeden teslim** veya **Adrese teslim**.
- Adrese teslimde adres alanı zorunlu ve ek teslimat ücreti eklenir.
- Günlük km sınırı: standart veya ücretli ek km paketi; fiyat hesaplaması anında güncellenir.
- Sürücü yaşı ve ehliyet süresi kriterlerine uygunluk kontrolü, tarih çakışması/araç uygunluğu kontrolü.
- Özet: gün, günlük ücret, km yükseltme bedeli, adrese teslim ücreti, ara toplam, seçilmiş ödeme indirimi varsa indirim, genel toplam.
- Kiralama sözleşmesi `AlertDialog` ile açılır. **Sözleşmeyi okudum ve kabul ediyorum** işaretlenmeden ödeme ekranına geçilemez.
- Kiralama sözleşmesi DEMO içeriktir, hukuki sözleşme yerine geçmez.

### 5.6 Ödeme ekranı
- 3 seçenek: **Kredi kartı (simüle)**, **EFT/Havale (simüle)**, **Şubede nakit (simüle)**.
- **Adrese teslim** seçiliyken **Şubede nakit** seçeneği kullanılamaz ve sebebi gösterilir.
- **Şubeden teslim + şubede nakit** seçildiğinde kiralama ve ek km ara toplamına **%10 indirim** uygulanır; adrese teslim bedeli indirim kapsamına girmez (nakitte zaten adrese teslim seçilemez).
- İndirim tutarı ve yeni toplam ekranda net gösterilir.
- **Gerçek kart numarası, CVV veya IBAN istenmez ve saklanmaz.** Ödeme butonu sadece örnek başarılı kiralama kaydı oluşturur, mock ödeme durumu `paid_simulated`/`pay_at_branch` gibi tutulur.
- Başarılı işlemde onay diyaloğu, rezervasyon kodu ve "Kiralamalarım" ekranına yönlendirme.

### 5.7 Müşteri kiralamaları ve profil
- Aktif/geçmiş kiralamaların listesi; araç, gün, tarihler, teslim tipi, ödeme türü/tutarı, rezervasyon durumu.
- Tamamlanan kiralamalarda 1–5 yıldız + yorum bırakma. Bir kiralama için bir değerlendirme; değiştirilebilir.
- Profil: ad soyad, e-posta, telefon, doğum tarihi, ehliyet alınma tarihi/yılı, tema ayarı ve çıkış.
- Puanlar demo yorumlarından hesaplanır; yeni müşteri için puan gösterimi "Henüz puan yok".

### 5.8 Yönetici paneli
- `AdminDashboardScreen`: toplam müşteri, toplam araç, müsait araç sayısı, aktif kiralama sayısı, bekleyen nakit ödeme, tahmini/örnek ciro.
- `CustomersScreen`: müşteri adı, e-posta, telefon, toplam kiralama, ortalama müşteri puanı. Puan örnek değerlendirmelerden/işlem geçmişinden hesaplanmalı veya "Demo puanı" diye işaretlenmeli.
- `AdminVehiclesScreen`: araç listeleme, araç ekleme ve düzenleme formu, araç silme teyit diyaloğu.
  - Araç alanları: marka, model, yıl, tip, yakıt, vites, il, ilçe, fotoğraf asset yolu, saatlik/günlük ücret, yaş sınırı, ehliyet yılı sınırı, günlük km, ek km paket bedeli, adrese teslim ücreti, aktif/pasif.
  - **Aktif kiralaması olan araç silinemez**; önce pasife alınabilir. Diğer araçlar için silme teyidi zorunlu.
- `AdminRentalsScreen`: hangi araç hangi müşteride, tarih aralığı/kaç gün, teslim şekli, ödeme yöntemi, tutar, ödeme durumu ve rezervasyon durumu.
- Yönetici örnek kiralamayı `approved/active/completed/cancelled` benzeri durumlar arasında geçerli geçişlerle güncelleyebilir. Biten kiralamada müşteri yorum bırakabilir.

## 6. Veri modelleri (önerilen alanlar)
- `AppUser`: id, fullName, email, phone, role, driverBirthDate?, licenseIssueDate?, createdAt.
- `Vehicle`: id, brand, model, year, category, fuelType, transmission, city, district, imagePath, hourlyRate, dailyRate, minimumAge, minimumLicenseYears, dailyKmLimit, additionalDailyKm, additionalKmDailyPrice, addressDeliveryFee, isActive.
- `Rental`: id, customerId, vehicleId, startDate, endDate, rentalDays, dailyKmLimitChosen, additionalKmCost, deliveryType, deliveryAddress?, paymentMethod, basePrice, deliveryFee, discount, finalPrice, paymentStatus, rentalStatus, agreementAcceptedAt.
- `Review`: id, rentalId, vehicleId, customerId, stars, comment, createdAt.
- Enum: `UserRole`, `VehicleCategory`, `FuelType`, `TransmissionType`, `DeliveryType`, `PaymentMethod`, `RentalStatus`, `PaymentStatus`.
- Modeller `copyWith` ve gerektiğinde `toJson/fromJson` ile tutulur; fiyat hesabı UI widget'ında değil ayrı saf fonksiyonda yapılır.

## 7. Hesaplama ve kurallar (test edilmelidir)
- Tarihler saatten bağımsız yerel takvim günü üzerinden karşılaştırılır: `rentalDays = endDate.difference(startDate).inDays`; bitiş başlangıçtan sonra olmalı. Aralık `[startDate, endDate)` (bitiş teslim günüdür).
- Çakışma: `newStart < oldEnd && oldStart < newEnd`, yalnız iptal edilmeyen/ilgili bloklayıcı durumlar için.
- `base = rentalDays × dailyRate`.
- `extraKm = rentalDays × selectedAdditionalKmDailyPrice` (standart pakette 0).
- `delivery = addressDelivery ? vehicle.addressDeliveryFee : 0`.
- `eligibleCashDiscount = branchPickup && cashAtBranch`.
- `discount = eligibleCashDiscount ? (base + extraKm) × 0.10 : 0`.
- `total = base + extraKm + delivery - discount`, parasal tutarlar 2 ondalığa yuvarlanır; eğitim demosunda `double`, tercihen kuruş bazlı `int` hesaplama önerilir.
- Saatlik fiyat bilgi amaçlıdır; **bu sürüm yalnız günlük kiralama** yapar. Saatlik kiralama akışını başlatma.
- Yaş/ehliyet sınırlarında takvim yılı değil tam geçen yıl hesaplanır.
- Yorum ancak tamamlanmış kiralamadan sonra bırakılır; aynı kiralamaya ikinci yorum oluşturulmaz.

## 8. Yerel veri, uygulama ömrü ve DEMO davranışı
- İlk açılışta ~10–15 örnek araç, 4–6 müşteri, birkaç örnek kiralama/yorum ve 1 yönetici oluştur.
- Veriler yalnız `data/mock` içindeki seed verilerinden gelir. İsteğe göre `shared_preferences` ile tema, oturum, kayıtlar, araç/rental/review değişiklikleri JSON olarak yerel saklanabilir.
- Kalıcılık için `shared_preferences` kullanımı eğitim amaçlıdır: gerçek gizli bilgiler, parolalar, ödeme bilgileri ve hassas kimlik verileri bunun içinde tutulmamalı.
- Tek uygulama/tek cihaz demosudur; birden çok cihaz arasında senkronizasyon **yoktur**.
- Demo giriş bilgileri README'de açıkça belirtilir. Ayrı admin girişinin güvenlik sağlamadığı vurgulanır.
- Sürümün temel işlevleri internet erişimi olmadan çalışmalıdır; araç fotoğrafları yerel asset veya açıklamalı fallback görseldir.

## 9. Ekran akışı
`Welcome → Customer Login/Register → Customer Shell (Home, Vehicles, My Rentals, Profile)`
`Welcome → Admin Login → Admin Shell (Dashboard, Customers, Vehicles CRUD, Rentals)`
`Home/Vehicles → Vehicle Detail → Rental Form + Agreement Dialog → Payment → Confirmation → My Rentals`

## 10. Klasörleme (19 Ekim yaklaşımı ile uyumlu)
```text
20ekim_odev/
├── PROJECT.md
├── .agents/skills/
│   ├── SKILL.md
│   ├── flutter-architecture/SKILL.md
│   ├── flutter-design-system/SKILL.md
│   ├── flutter-forms-auth/SKILL.md
│   ├── rental-business-rules/SKILL.md
│   └── flutter-quality/SKILL.md
└── rotiva/
    ├── assets/{images,icons,vehicles}/
    ├── lib/
    │   ├── main.dart
    │   ├── app.dart
    │   ├── core/{constants,theme,utils,widgets}/
    │   ├── data/{mock,repositories}/
    │   └── features/
    │       ├── auth/{controllers,models,view,widgets}/
    │       ├── home/{controllers,view,widgets}/
    │       ├── vehicles/{controllers,models,view,widgets}/
    │       ├── rentals/{controllers,models,view,widgets}/
    │       ├── payments/{controllers,view,widgets}/
    │       ├── profile/{controllers,view,widgets}/
    │       └── admin/{controllers,view,widgets}/
    ├── test/
    ├── pubspec.yaml
    └── README.md
```
- Klasörleri yalnız ihtiyaç olduğunda dosyalarla doldur; sırf mimari görünsün diye boş katman üretme.
- Proje klasör adı `20ekim_odev`, Flutter proje klasörü `rotiva` olarak örneklendi; kullanıcı başka ad belirtirse tek noktadan uyarlanabilir.

## 11. Öncelik / aşama planı
1. Flutter iskeleti, tema, logo, mock veriler, routing, navigasyon.
2. Giriş/kayıt/sözleşme diyalogları, demo oturum/roller.
3. Müşteri ana sayfa, arama, filtre, araç detay.
4. Kiralama formu, fiyat, kurallar, sözleşme, simüle ödeme.
5. Kiralamalarım, profil, yorum/puan.
6. Admin dashboard, müşteri, araç CRUD, kiralama/ödeme yönetimi.
7. Testler, form/tema/responsive/erişilebilirlik, README ve son kontrol.

## 12. Bitmiş sayılması için kontrol listesi
- [x] Flutter analiz hatasız, testler başarılı, Chrome ve Android emülatörde açılıyor.
- [x] Light mavi / dark turuncu tema tüm ana ekranlarda tutarlı.
- [x] Giriş, kayıt, KVKK ve açık rıza dialogları çalışıyor; eksik onay kayıt engelliyor.
- [x] Yönetici girişi müşteriden ayrı, rol ekranları ayrılmış.
- [x] İl/ilçe/tarih araması ve araç filtreleri gerçekten sonucu değiştiriyor.
- [x] Detayda tüm zorunlu araç bilgileri ve yorum/puan var.
- [x] Yaş/ehliyet, gün/km, teslim, sözleşme ve tarih çakışması kontrolleri çalışıyor.
- [x] Adrese teslimde nakit kapalı; şubeden+naktinde %10 indirimi doğru.
- [x] Simüle ödeme sonrası rezervasyon iki tarafta doğru görünüyor.
- [x] Admin araç ekleme/düzenleme/silme, müşteri ve kiralama listeleme çalışıyor.
- [x] Örnek veri, uyarı, boş liste, form hatası ve silme teyit senaryoları çalışıyor.
- [x] README: kurulum, demo hesaplar, mimari, sınırlamalar, ekranlar, test komutları.
- [x] Profil sekmesi eksiksiz geliştirildi (avatar, düzenleme, kiralamalarım, puan, ayarlar, çıkış).
- [x] Hem müşteri hem yönetici için güvenli oturum sonlandırma ve AlertDialog ile çıkış yapma.
- [x] Tüm ekranlarda standart Material 3 `RotivaAppBar` (logo, marka adı, anlık tema değiştirici).
- [x] Araç tipi ve yakıt türü için renkli Material 3 rozet (Badge/Chip) sistemi uygulandı.

## 13. Antigravity çalışma sınırları
- Değişiklikleri **yalnız** `20ekim_odev/` içinde gerçekleştir; diğer ödev klasörlerine dokunma.
- Her işe başlamadan `PROJECT.md` ve `.agents/skills/SKILL.md` dosyalarını; ilgili konuda alt beceri dosyasını oku.
- Yarım ekran veya sahte `onPressed` bırakma. Her tanımlı ana işlem gerçek **yerel demo davranışına** bağlansın.
- Düzeltme sırasında çalışan ekranı bozma; gereksiz kapsam genişletme.
- Aşama sonunda değişen dosyaları, senaryoları ve `flutter analyze`, `flutter test` sonuçlarını Türkçe özetle.

## 14. Tamamlanan Geliştirmeler ve Mimari Güncellemeler (20 Ekim)

### 14.1 Profil Ekranı (`ProfileTabView`)
- **Kullanıcı Bilgileri:** Ad ve soyadın baş harflerinden otomatik türetilen modern CircleAvatar, ad-soyad, e-posta, telefon ve "Müşteri / Yönetici" rol etiketi.
- **Profil Düzenleme:** `_showEditProfileDialog` ile ad, soyad, e-posta ve telefon alanlarını doğrulayan (boşluk kontrolü, e-posta regex'i, telefon formatı, mükerrer e-posta denetimi) modal form. Değişiklikler anında `AppRepository` üzerinden `shared_preferences`'a yazılır ve tüm ekranlara yansır.
- **Sürücü Şartları & Bilgileri:** Doğum tarihi ve ehliyet veriliş yılı düzenlenebilir ve saklanır.
- **Kiralama Bilgilerim Özeti:** Aktif kiralama sayısı, geçmiş kiralama sayısı ve toplam kiralama istatistik kartları; son kiralamaların önizleme kartları; "Tüm Kiralamalarımı Gör" butonu ile Kiralamalarım sekmesine geçiş; kiralama yoksa açıklayıcı boş durum (`EmptyStateView`) tasarımı.
- **Müşteri Puanı:** Kullanıcının geçmiş kiralamalarına ve sistem skoruna bağlı 5 üzerinden yıldız ve sayısal puan gösterimi (`x.x / 5.0`).
- **Ayarlar:** Görünüm & Tema tercihi (Açık Mavi / Koyu Turuncu), "Uygulama Hakkında" bilgi modalı (sürüm 1.0.0, Material 3 standartları, özellik listesi) ve Demo Verilerini Sıfırlama imkanı.
- **Çıkış Yap:** Profil ekranının altında belirgin ve kırmızı tonlu çıkış butonu.

### 14.2 Kimlik Doğrulama ve Oturum Yönetimi
- **Çıkış Onay Diyaloğu:** Hem müşteri profilinde hem de yönetici panelinde çıkış butonuna basıldığında `AlertDialog` açılır ("Hesabınızdan çıkış yapmak istediğinize emin misiniz?"). İptal ve Çıkış Yap seçenekleri sunulur.
- **Oturum Sonlandırma & Yönlendirme:** Çıkış onaylandığında `repository.logout()` çağrılarak aktif oturum sonlandırılır ve `Navigator.pushAndRemoveUntil` ile `WelcomeScreen`'e dönülür.
- **Geri Navigasyonun Engellenmesi:** Stack tamamen temizlendiği için kullanıcının geri tuşuna basarak önceki korumalı ekranlara dönmesi kesin olarak engellenir.
- **Veri Bütünlüğünün Korunması:** Oturum kapatıldığında kullanıcı hesabı, araçlar ve kiralama geçmişi silinmez; `shared_preferences` içinde korunur. Tekrar giriş yapıldığında aynı veriler eksiksiz yüklenir.
- **Rol Ayrımı:** Müşteri ve yönetici oturumları birbirinden bağımsızdır ve her iki rol için de çıkış akışı birebir aynı güvenlik standartlarında çalışır.

### 14.3 Tasarım Sistemi ve Ortak Bileşenler
- **Ortak `RotivaAppBar` (`lib/core/widgets/rotiva_app_bar.dart`):**
  - Tüm müşteri ve yönetici ekranlarında tutarlı Material Design 3 üst barı.
  - Sol alan: Özel Rotiva vektörel logosu + "Rotiva" marka adı + sayfa başlığı (`Rotiva • Sayfa`).
  - Sağ alan: Anlık Açık / Koyu tema geçiş butonu (Açık temada ay simgesi / Koyu temada güneş simgesi). Temaya göre mavi (`#1565C0`) ve turuncu (`#FF922B`) vurgular korunur.
  - Alt sayfalarda sol tarafa geri butonu entegre edilir; geri butonu logo ve tema butonunun yerleşimini bozmaz.
  - Seçilen tema tercihi `SharedPreferences` ile yerel olarak saklanır ve uygulama yeniden açıldığında korunur.
- **Renkli Badge (Rozet) Sistemi (`lib/core/constants/vehicle_badge_colors.dart`):**
  - **Yakıt Türü Renkleri:**
    - Benzin: Turuncu (`#F57C00`) + `Icons.local_gas_station`
    - Dizel: Mavi (`#1976D2`) + `Icons.local_gas_station`
    - Hibrit: Mor (`#7B1FA2`) + `Icons.eco`
    - Elektrik: Yeşil (`#2E7D32`) + `Icons.bolt`
  - **Araç Tipi Renkleri:**
    - Sedan: Mavi (`#1E88E5`) + `Icons.directions_car`
    - SUV: Mor (`#8E24AA`) + `Icons.directions_car_filled`
    - Hatchback: Turkuaz (`#00ACC1`) + `Icons.directions_car_outlined`
    - Coupe / Spor: Kırmızı (`#E53935`) + `Icons.speed`
    - Ticari / Van: Kahverengi (`#6D4C41`) + `Icons.airport_shuttle`
    - Lüks: Amber / Altın (`#FFA000`) + `Icons.workspace_premium`
    - Station Wagon: Bronz / Sıcak Kahve (`#5D4037`) + `Icons.airport_shuttle`
  - **Tekrar Kullanılabilir Widget'lar:**
    - `FuelTypeBadge` (`lib/core/widgets/fuel_type_badge.dart`): Kompakt veya standart mod, tema uyumlu kontrast ve arka plan.
    - `VehicleTypeBadge` (`lib/core/widgets/vehicle_type_badge.dart`): Kompakt veya standart mod, temaya duyarlı okunaklı tip rozeti.
  - **Badge Entegrasyon Alanları:**
    - Müşteri ana sayfası araç kartları.
    - Araç arama ve filtreleme sonuç kartları.
    - Araç detay sayfası Hero banner alanı.
    - Kiralama formu ve rezervasyon özet kartı.
    - Yönetici paneli araç listesi kartları.

### 14.4 Mimari ve Kod Yapısı
- **Eklenen / Güncellenen Dosyalar:**
  - `lib/core/constants/app_constants.dart` (Coupe ve luxury kategorileri eklendi)
  - `lib/core/constants/vehicle_badge_colors.dart` (Merkezi rozet renk ve ikon haritası)
  - `lib/core/widgets/fuel_type_badge.dart` (Tekrar kullanılabilir yakıt türü rozeti)
  - `lib/core/widgets/vehicle_type_badge.dart` (Tekrar kullanılabilir araç tipi rozeti)
  - `lib/core/widgets/rotiva_app_bar.dart` (Ortak Material 3 AppBar)
  - `lib/core/widgets/vehicle_card.dart` (Rozet sistemi entegrasyonu)
  - `lib/features/profile/view/profile_tab_view.dart` (Kapsamlı profil yönetimi ekranı)
  - `lib/features/vehicles/view/vehicle_detail_screen.dart` (Ortak AppBar ve rozetler)
  - `lib/features/rentals/view/rental_form_screen.dart` (Ortak AppBar ve özet rozetleri)
  - `lib/features/payments/view/payment_simulation_screen.dart` (Ortak AppBar)
  - `lib/features/home/view/home_tab_view.dart` (Ortak AppBar)
  - `lib/features/vehicles/view/vehicles_tab_view.dart` (Ortak AppBar)
  - `lib/features/rentals/view/my_rentals_tab_view.dart` (Ortak AppBar)
  - `lib/features/admin/view/admin_shell_screen.dart` (Ortak AppBar ve çıkış akışı)
  - `lib/features/admin/view/admin_vehicles_tab.dart` (Yönetici araç listesinde renkli rozetler)
  - `lib/features/admin/view/admin_vehicle_form_screen.dart` (Ortak AppBar)
  - `lib/features/auth/view/customer_login_screen.dart`, `admin_login_screen.dart`, `register_screen.dart` (Ortak AppBar)
  - `test/unit/badges_and_profile_test.dart` (Geliştirmelere özel birim ve widget testleri)

### 14.5 Test ve Doğrulama Durumu
- `dart format .`: 51 dosyanın tamamı resmi Dart stil kurallarına göre biçimlendirildi.
- `dart analyze`: **0 hata, 0 uyarı (No issues found!)**.
- `flutter test`: **29/29 test başarıyla geçti (All tests passed!)**.
- Çıkış yapma, profil düzenleme, tema koruma ve rozet renklerinin doğru gösterimi doğrulandı.

---

## 15. Yönetici Dashboard Overflow Çözümü, Responsive İyileştirmeler ve Kalıcı Türkçe Kod Standardı (20 Ekim)

### 15.1 Yönetici Dashboard Overflow Düzeltmesi (`BOTTOM OVERFLOWED BY 2.0 PIXELS`)
- **Sorunun Kök Nedeni:** `AdminDashboardTab` içerisindeki "Son Kiralama Hareketleri" listesinde `ListTile` kullanılıyordu. `ListTile` bileşeni `trailing` alanı için sabit dikey yükseklik sınırlaması (kısıtı) koyar (~48-56px). Trailing içinde yer alan Fiyat metni (`RotivaFormatters.formatCurrency`), `SizedBox(height: 4)` ve kiralama durumu rozeti (`StatusBadge.rental`) toplamda bu ayrılan dikey kutuyu tam olarak **2.0 piksel** aşıyordu.
- **Uygulanan Çözüm:** 
  - `ListTile` kaldırıldı ve yerine dinamik yükseklik alabilen esnek bir `Card` + `Padding(horizontal: 14, vertical: 12)` + `Row` mimarisi uygulandı.
  - Sol tarafta `CircleAvatar` ile araç simgesi konumlandırıldı.
  - Orta bilgi alanında müşteri adı, araç adı, rezervasyon kodu ve kiralama günü `Expanded` içinde `maxLines: 1` ve `TextOverflow.ellipsis` ile sarıldı; böylece uzun isimler dar ekranlarda sağdaki fiyat alanını sıkıştırmaz.
  - Sağ tarafta `Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end)` ile fiyat ve durum rozeti esnek olarak hizalandı. Kartın yüksekliği içeriğe göre esner, sabit kısıtlama olmadığı için sıfır piksel taşma sağlandı.
  - **KPI Metrik Kartları:** `_buildMetricCard` içindeki metrik değerleri dar mobil cihazlarda (360px) taşma yapmaması için `FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft)` ile sarıldı.

### 15.2 AppBar ve İçerik Hizalama Düzeltmeleri
- **Sorunun Kök Nedeni:** `AdminShellScreen` zaten dışarıdan `RotivaAppBar` içeren bir ana `Scaffold`'a sahipti. Bununla birlikte `AdminDashboardTab`, `AdminRentalsTab` ve `AdminCustomersTab` kendi içlerinde ikinci bir `Scaffold` döndürüyordu (Nested Scaffold). Bu iç içe `Scaffold` yapısı, özellikle kaydırma sırasında üst AppBar altında gölgelenme, padding çakışması ve içerik gizlenme sorununa yol açıyordu.
- **Uygulanan Çözüm:**
  - Sekme bileşenlerindeki gereksiz iç `Scaffold` yapıları tamamen kaldırıldı; doğrudan `SafeArea(top: false, bottom: true)` ve `SingleChildScrollView` / `Column` mimarisi kullanıldı.
  - `AdminShellScreen` AppBar başlığı sabit `'Yönetici Paneli'` metninden dinamik `_getTabTitle(_currentIndex)` fonksiyonuna bağlandı (`Özet Paneli`, `Araç Yönetimi`, `Kiralama Takibi`, `Müşteri Listesi`).
  - `RotivaAppBar` ve `AppTheme` içerisindeki AppBar temasına `scrolledUnderElevation: 2.0` eklenerek scroll anında sayfa içeriği ile AppBar'ın görsel olarak çakışması engellendi.

### 15.3 Diğer Ekranlardaki Responsive İyileştirmeler
- **`VehicleCard`:** Araç kartındaki teknik özellik rozetlerinde (`minimumAge`, `minimumLicenseYears`, `dailyKmLimit`, `additionalDailyKm`) katı `Row` yerine `Wrap(spacing: 8, runSpacing: 6)` uygulandı; 320-360px mobil ekranlarda rozetlerin kart dışına taşması engellendi.
- **`StatusBadge`:** Dikey iç boşluk `3.5` piksele, font boyutu `11.5` piksele optimize edildi; dar trailing ve kart alanlarında dikey baskı sıfırlandı.
- **`VehicleDetailScreen`:** Araç detay özellikleri kartları `LayoutBuilder` ile sarıldı. Genişlik >340px ise 2 eşit sütun, <=340px ise tek sütun olarak esnetildi.
- **`PaymentSimulationScreen`:** Ödeme özeti satırlarında (`_buildSummaryRow`) sol etiket metni `Expanded` ile sarılarak dar ekranlarda değer metniyle çakışma ihtimali ortadan kaldırıldı.

### 15.4 Tüm Dart Kodlarına Kalıcı Türkçe Açıklama Standardı
- SoftIto mobil eğitim hedefleri doğrultusunda `lib/` klasöründeki **45 Dart dosyasının tamamı** incelendi.
- Başlangıç seviyesindeki bir öğrencinin VS Code üzerinde kodları satır satır okuyarak Flutter mimarisini öğrenebilmesi için:
  - `import`, `class`, `enum`, `final`, `const`, `late`, `required`, `?` (nullable),
  - `initState`, `dispose`, `setState`, `build`,
  - `Scaffold`, `AppBar`, `Column`, `Row`, `Expanded`, `Wrap`, `CustomPainter`,
  - `RotivaScope` (InheritedWidget), `AppRepository` (ChangeNotifier),
  - Model sınıfları, JSON serileştirme (`toJson`/`fromJson`), `SharedPreferences` kalıcılığı,
  - Fiyatlandırma motoru (`RentalPricing`), tarih çakışma formülleri ve form validatörleri
  doğal, kısa ve eğitici Türkçe `//` açıklamaları ile belgelendi.

### 15.5 Zorunlu Dokümantasyon Standardı
- Projede herhangi bir kod veya layout değişikliği yapıldığında `yuzYuze/20ekim_odev/PROJECT.md` dosyasının da güncellenmesi zorunlu kılındı.
- Bu kural kalıcı olarak `.agents/skills/SKILL.md` ve `.agents/skills/flutter-quality/SKILL.md` dosyalarına kaydedildi.
