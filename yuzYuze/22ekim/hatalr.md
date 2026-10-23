# Ritmia — Mimari, Kod Kalitesi ve Hardcode İnceleme Raporu

> **Tarih:** 23 Ekim 2026  
> **Konum:** `yuzYuze/22ekim/ritmia`  
> **Hazırlayan:** Antigravity AI Pair Programmer  
> **Amaç:** `project.md` teknik şartnamesi ve `.agents/skills` rehberleri doğrultusunda projede tespit edilen hardcode kullanımları, mimari sapmaları, SOLID ihlallerini ve çözüm önerilerini dokümante etmek.

---

## 1. Mimari Sapmalar ve Veri Saklama Hataları

### 1.1. SQLite / Drift Yerine SharedPreferences Kullanımı (Kritik Mimari Sapma)
- **Şartname Kuralı (`project.md` Madde 9 & 10):**  
  > *"SQLite/drift yerel alışkanlık/günlük kayıtları; shared_preferences yalnız tema ve basit ayarlar için."*
- **Mevcut Durum:**  
  `StorageService` ve `LocalHabitRepository` sınıfları, tüm alışkanlık modellerini (`Habit`) ve günlük ilerleme kayıtlarını (`HabitDayProgress`) JSON string formatında `SharedPreferences` (`ritmia_habits` anahtarı) içerisine yazıp okumaktadır.
- **Doğurduğu Riskler:**
  1. **Ölçeklenebilirlik Kaybı:** Kullanıcı 10 alışkanlık takip edip 1 yıl veri topladığında, her tekil gün işaretlemesinde yüzlerce kilobaytlık devasa bir JSON string tokenize edilip tekrar diske yazılmaktadır.
  2. **ACID ve İlişkisel Bütünlük Eksikliği:** SQLite'ın sağladığı yabancı anahtar (foreign key), indeksleme ve transaction güvenceleri yoktur. Veri kaybı veya dosya bozulması (corrupted state) riski yüksektir.
  3. **Tarihsel Sorgu Hantallığı:** Takvim ısı haritası ve streak hesapları için tüm liste RAM'e yüklenmek zorundadır; tarih aralığı filtreleme sorguları (`WHERE localDate BETWEEN ...`) veritabanı seviyesinde işletilememektedir.
- **Çözüm Önerisi:**  
  `sqflite` veya `drift` kütüphanesi entegre edilerek `habits` ve `habit_day_progress` tabloları ilişkisel şemaya dönüştürülmeli; `HabitRepository` bu SQLite arayüzünü implemente etmelidir.

---

### 1.2. Tek Sorumluluk İlkesi (SRP) İhlali — `StorageService`
- **Mevcut Durum:**  
  `StorageService` sınıfı hem UI tema tercihlerini (`themeMode`, `accentColor`), hem kullanıcı profilini, hem de iş modellerini (`Habit`) saklamaktadır.
- **Risk:**  
  Depolama katmanı şişmekte (God Object eğilimi) ve farklı sorumluluklar tek bir sınıfa bağımlı hale gelmektedir.
- **Çözüm:**  
  `ThemePreferences` / `SettingsStorage` yalnızca ayarları; `HabitDatabase` ise SQLite üzerinden alışkanlıkları yönetmelidir.

---

## 2. Hardcoded Değerler ve Sihirli Sayılar (Magic Numbers)

### 2.1. Metinlerin ve Hata Mesajlarının Hardcode Edilmesi (l10n Eksikliği)
- **Şartname Kuralı (`project.md` Madde 1):**  
  > *"Dil: Türkçe (metinler yerelleştirmeye hazır olacak)."*
- **Mevcut Durum:**  
  - Form validasyon mesajları (`'Alışkanlık adı en az 3 karakter olmalıdır'`, `'Açıklama en fazla 160 karakter olabilir'`),
  - SnackBar ve diyalog metinleri,
  - Motivasyon cümleleri (`AppConstants.motivationMessage`),
  - Buton ve başlık metinleri,  
  doğrudan Widget sınıfları (`habit_form_sheet.dart`, `login_view.dart`, `leaderboard_view.dart`) içine Türkçe string olarak gömülmüştür.
- **Çözüm:**  
  `flutter_localizations` ve `.arb` dosyaları (`intl`) ile `AppLocalizations.of(context)` yapısına geçilmeli veya en azından merkezi bir `AppStrings` sınıfı kurulmalıdır.

---

### 2.2. View Katmanında Skor Formülü Hardcode'u (MVC İhlali)
- **Mevcut Durum (`leaderboard_view.dart` L:39):**
  ```dart
  userScore: habitCtrl.overallStreak * 15 + 40,
  userCompletedCount: habitCtrl.overallStreak * 2 + 3,
  userMaxStreak: habitCtrl.overallStreak,
  ```
- **Hata:**  
  Kullanıcının lig skoru ve tamamlama katsayısı hesabı doğrudan `LeaderboardView` widget'ının `initState` yaşam döngüsünde hardcode edilmiştir.
- **Neden Yanlış:**  
  Puanlama kuralları `project.md` Madde 6'da açıkça belirtilen matematiksel kurallardır (+10p tamamlama, +5p günlük bonus, rozet puanları). Bu hesaplama View'da değil, `LeaderboardService` veya `HabitStreakService` içinde hesaplanıp Controller tarafından ViewModel'e sunulmalıdır.

---

### 2.3. Sabit Demo Kullanıcı Kimliği (`'demo_user'`)
- **Mevcut Durum (`demo_auth_repository.dart` & `storage_service.dart`):**  
  `'demo_user'` ID değeri, `@demo_kullanici` rumuzu ve mock veriler birden fazla dosyada statik string literali olarak tekrarlanmaktadır.
- **Çözüm:**  
  `AppConstants.demoUserId` gibi merkezi bir sabite bağlanmalıdır.

---

### 2.4. Tasarım Ölçüleri ve Aralıklar (Spacing / Radius Magic Numbers)
- **Mevcut Durum:**  
  `SizedBox(height: 14)`, `SizedBox(height: 16)`, `BorderRadius.circular(18)`, `BorderRadius.circular(20)`, `BorderRadius.circular(22)`, `BorderRadius.circular(28)` değerleri widget'lar arasında dağınık şekilde elle girilmiştir.
- **Çözüm:**  
  8-pt grid sistemine tam uyumlu `AppSpacing.sm (8)`, `AppSpacing.md (16)`, `AppSpacing.lg (24)` ve `AppRadius.card (20)`, `AppRadius.sheet (28)` sabitleri tanımlanmalıdır.

---

## 3. Renk ve Tema Yönetimi Denetimi

### 3.1. Karanlık Temada Vurgu Rengi Entegrasyonu (Giderildi)
- **Önceki Durum:**  
  Widget'lar içerisinde `isDark ? AppColors.darkSurface : theme.colorScheme.surface` ve `isDark ? AppColors.darkBorder : theme.colorScheme.outline` şeklinde sabit mürdüm rengi kodları (`0xFF261D2F` ve `0xFF4D3A58`) kullanılıyordu. Bu durum, kullanıcı tema rengini (örneğin Turuncu veya Yeşil) seçtiğinde karanlık temanın bu renge bürünmesini engelliyordu.
- **Uygulanan Düzeltme:**  
  1. `AppColors.dynamicDarkBackground`, `dynamicDarkSurface`, `dynamicDarkBorder`, `dynamicDarkPrimaryContainer` metodları HSL renk uzayında seçilen vurgu renginin tonunu (Hue) baz alacak şekilde yeniden formüle edildi.
  2. Tüm widget'lardaki hardcoded kontroller kaldırılıp doğrudan `theme.colorScheme.surface`, `outline`, `surfaceContainerHighest` bileşenlerine bağlandı.

### 3.2. Takvim Isı Haritasında Sabit Kırmızı-Yeşil Kullanımı (Giderildi)
- **Önceki Durum:**  
  Takvim ısı haritasında yapılmayan günler için sabit kırmızı (`#EF4444`), yapılan günler içinse sabit yeşil tonları (`#15803D` .. `#DCFCE7`) kullanılıyordu. Bu durum kullanıcının seçtiği vurgu rengiyle uyumsuzdu.
- **Uygulanan Düzeltme:**  
  `AppColors.dynamicHeatMapColor` metodu yazılarak; kullanıcının seçtiği aktif tema rengine göre yapılmayanlardan (%0) yapılanlara (%100) doğru rengin kademeli olarak koyulaşıp doygunlaştığı HSL tabanlı dinamik ısı haritası mekanizması kuruldu. `DayDetailSheet` ve takvim gösterge (legend) bileşenleri de bu dinamik yapıya bağlandı.

---

## 4. SOLID Prensipleri Açısından İnceleme

| Prensip | Durum | Açıklama |
| :--- | :---: | :--- |
| **S - Single Responsibility** | ⚠️ Kısmi | `StorageService` hem ayar hem model kalıcılığı yönetiyor. `LeaderboardView` skor hesabı yapıyor. |
| **O - Open/Closed** |  İyi | `BadgeDefinition` ve `AppConstants` yeni kategoriler/rozetler eklenmesine elverişli. |
| **L - Liskov Substitution** |  İyi | `AuthRepository` ve `LeaderboardRepository` arayüzleri, demo sınıfları ile yer değiştirilebilir yapıda. |
| **I - Interface Segregation** |  İyi | Alışkanlık, takvim ve lig sorumlulukları küçük ve odaklanmış repository/controller'lara ayrılmış. |
| **D - Dependency Inversion** | ⚠️ Kısmi | Controller'lar arayüz yerine doğrudan somut `StorageService` sınıfına bağımlı. |

---

## 5. Hata Yönetimi ve Dayanıklılık (Error Handling)

1. **Failure Hiyerarşisi Yok:**  
   Hatalar `Exception` veya doğrudan ham `String` olarak yakalanmaktadır. `DatabaseFailure`, `ValidationFailure`, `AuthFailure` gibi yapılandırılmış hata sınıfları eksiktir.
2. **Kritik İş Kuralları İçin Unit Test Eksikliği:**  
   - 15 kişilik lig grubunda ilk 5'in yükselip son 5'in düşme algoritması,
   - 10'dan az katılımcıda `min(5, floor(N/3))` kuralı,
   - Pazar gecesi sıfırlanma ve ardışık gün serisinin gün bitmeden kırılmama kuralı,  
   için otomatik unit testler yazılmalıdır.

---

## 6. Öncelikli Aksiyon Planı (Refactoring Roadmap)

1. **Adım 1 (P0):** `StorageService` içindeki alışkanlık CRUD operasyonlarını `sqflite` veya `drift` paketine taşımak.
2. **Adım 2 (P1):** `LeaderboardView` içindeki skor hesaplama kodunu `LeaderboardService` içine saf fonksiyon olarak taşımak.
3. **Adım 3 (P1):** Projeye `intl` ve `AppLocalizations` ekleyerek Türkçe metinleri `.arb` dosyalarında merkezileştirmek.
4. **Adım 4 (P2):** Kritik algoritmalar (streak, lig terfi/düşme, rozet puanı) için `test/unit/` altında test senaryolarını tamamlamak.
