# Filizora — Proje Kılavuzu ve Temel Gereksinimler

Bu doküman, Filizora girişimcilik mobil uygulamasında geliştirme yapacak yapay zekâ ajanları ve yazılım geliştiriciler için bağlayıcı ana proje kılavuzudur. Projede yazılan her kod satırı bu dokümandaki kurallara uymalıdır.

---

## 1. Proje Özeti ve Marka Kimliği

- **Uygulama Adı:** Filizora
- **Slogan:** Fikirden girişime, girişimden büyümeye.
- **Hedef Platformlar:** Öncelikle iOS ve Android; ardından Web, macOS, Windows ve Linux.
- **Flutter SDK:** ^3.29.0
- **Dart SDK:** ^3.0.0
- **Tasarım Dili:** Material 3
- **Tema:** Açık (Light) ve Koyu (Dark) tema desteği.

Uygulamanın amacı; girişimcilerin mentorlarla buluşabileceği, birbirleriyle etkileşim kurabileceği, destek programlarına ulaşabileceği ve kendi girişim süreçlerini takip edebileceği kapsamlı bir mobil ekosistem sunmaktır.

---

## 2. Dört Ana Özellik (Uygulama Kapsamı)

Uygulama kesin olarak aşağıdaki 4 ana sayfadan oluşur. Kullanıcı açıkça talep etmedikçe yeni bir ana sayfa veya kapsam dışı modül eklenemez:

1. **Mentor–Menti Eşleşmesi (`features/mentor_matching`):**  
   Girişimcilerin alanında uzman mentorları listeleyebileceği, uzmanlık alanlarına göre filtreleyebileceği ve eşleşme talebi gönderebileceği alan.
2. **Girişimci Topluluğu (`features/entrepreneur_community`):**  
   Girişimcilerin ekosistem içinde paylaşımlar yapabileceği, diğer girişimcilerin deneyimlerini okuyup etkileşime girebileceği ve beğenebileceği paylaşım alanı.
3. **Destek Programları (`features/support_programs`):**  
   KOSGEB, TÜBİTAK, kalkınma ajansları ve melek yatırım ağlarının girişimcilik desteklerine tek bir merkezden erişilebilen alan.
4. **Girişim Süreci Takibi (`features/venture_tracking`):**  
   Girişimcinin fikir aşamasından şirketleşme ve büyüme fazına kadar kendi aşamalarını, iş olanaklarını ve alt görevlerini takip edebileceği alan.

---

## 3. Çoklu Kullanıcı Rolleri ve Erişim Mimarisi

Uygulama, yerel durum yönetimi (in-memory state) ile çalışan 3 farklı kullanıcı rolünü destekler:

1. **Girişimci (Entrepreneur):**
   - **Giriş Yap:** Daha önce kayıt olmuş girişimciler e-posta adresleriyle doğrudan giriş yapabilir. Onaylı ise ana platforma (`PlatformMainShell`), henüz onay bekliyorsa bekleme ekranına (`PendingApprovalView`) yönlendirilir.
   - **Yeni Kayıt:** Yeni girişimciler ad-soyad, e-posta ve iş fikri beyanı ("İş fikrim var" / "İş fikrim yok") ile kaydolur. Hesap başlangıçta `pendingApproval` (yönetici onayı bekliyor) durumunda tutulur.
   - Yönetici onayı aldıktan sonra 4 ana platform özelliğine erişebilir.
   - Mentorlara eşleşme isteği gönderebilir; istek yatırımcının gelen kutusuna düşer.

2. **Yatırımcı / Mentor (Investor & Mentor):**
   - Yatırımcı/Mentor rolü ile sisteme giriş yapar.
   - Girişimcilerden gelen tüm eşleşme taleplerini **Yatırımcı Portalı (`InvestorDashboardView`)** üzerinden görüntüler.
   - Bekleyen istekleri inceleyip **"Eşleşmeyi Kabul Et"** veya **"Reddet"** aksiyonlarını gerçekleştirir.
   - Kabul edilen eşleşmeleri "Eşleştiğim Girişimciler" sekmesinde takip eder.

3. **Yönetici (Admin):**
   - Admin rolü ile sisteme giriş yapar (`admin@filizora.com`).
   - **Yönetici Paneli (`AdminDashboardView`)** üzerinden yeni kayıt olan tüm girişimcilerin başvuru ve iş fikirlerini inceler.
   - Girişimcileri tek tıkla **"Başvuruyu Onayla"** veya **"Reddet"** işlemleriyle onaylar.
   - Onaylanan girişimcilerin ana platforma erişimi otomatik olarak aktifleşir.

---

## 4. Eklenen Yeni Özellikler

### 4.1. Girişimci Ekranında "Giriş Yap" ve "Yeni Kayıt" Seçenekleri
- Girişimci sekmesinde yer alan geçiş menüsü ile kullanıcılar:
  - Kayıtlı e-postalarıyla (ör. `bora@test.com`) doğrudan **Giriş Yapabilir**.
  - Yeni bir girişimci hesabı oluşturmak için **Yeni Kayıt Olabilir**.
  - Test ve değerlendirme için hızlı demo e-posta butonları sunulur.

### 4.2. Yönetici Onay ve Denetim Paneli (`features/admin/view/admin_dashboard_view.dart`)
- **İstatistik Kartları:** Onay bekleyen, onaylanan ve toplam girişimci sayıları dinamik olarak gösterilir.
- **Başvuru İnceleme:** Girişimcinin ad-soyad, e-posta, iş fikri başlığı, sektör ve açıklama detayları kart bazında listelenir.
- **Onay / Ret Butonları:** Yeşil/Teal "Başvuruyu Onayla" ve Kırmızı "Reddet" butonları ile durum anında güncellenir.
- **Tüm Kullanıcılar Sekmesi:** Onaylı, bekleyen ve reddedilen tüm platform kullanıcıları rolleriyle birlikte listelenir.

### 4.3. Yatırımcı Portalı & Bekleyen İstekler (`features/investor/view/investor_dashboard_view.dart`)
- **Bekleyen İstekler Listesi:** Girişimcilerin gönderdiği eşleşme talepleri girişimci adı, proje başlığı, sektör ve talep mesajıyla listelenir.
- **Kabul / Ret Yönetimi:** "Eşleşmeyi Kabul Et" veya "Reddet" aksiyonları ile mentorluk süreci başlatılır.
- **Eşleştiğim Girişimciler:** Başarıyla eşleşilen girişimcilerin profilleri ve durumları takip edilir.

### 4.4. Girişim Süreci Takibinde Gantt Şeması (`features/venture_tracking/widget/gantt_chart_view.dart`)
- Girişimcinin aşamalarını zaman çizelgesi formatında gösteren görsel Gantt Şeması sekmesi.
- Her aşama için tamamlanma yüzdesi, zaman aralığı (haftalık/aylık), durum rozeti ve alt görev ilerleme çubukları.

### 4.5. Destek Programlarına Başvuru Yapma (`features/support_programs/widget/application_dialog.dart`)
- Her destek programı için "Başvuru Yap" butonu ve interaktif başvuru formu penceresi.
- Proje başlığı, bütçe talebi, gerekçe ve tahmini süre alanları.
- Başvuru sonrası "Başvuruldu" rozeti ve "Başvurulanlar" filtreleme seçeneği.

### 4.6. "İş Fikrim Yok" Rehberlik ve Yönlendirme Kartı (`features/authentication/widget/no_idea_guidance_card.dart`)
- Kayıt sırasında "İş fikrim yok" seçeneğini işaretleyen kullanıcılara yönelik adım adım ekosistem rehberi ve motivasyonel yönlendirmeler.

---

## 5. Yenilenen Modern Marka Renk Paleti

Girişimcilik ve inovasyon ruhunu yansıtan, yüksek kontrastlı ve prestijli yeni renk paleti:

| Renk Adı | HEX Kodu | Kullanım Alanı |
|---|---|---|
| **Royal Indigo (Primary)** | `#4F46E5` | Ana marka rengi, birincil butonlar ve teknoloji vurgusu |
| **Filiz Emerald** | `#10B981` | Filizlenme, büyüme, tohum aşaması, onay ve başarı rozetleri |
| **Violet Glow** | `#6366F1` | Dinamik etkileşimler, ikincil vurgular ve koyu mod odakları |
| **Electric Cyan** | `#06B6D4` | İnovasyon geçişleri ve modern gradyan çizgileri |
| **Golden Amber** | `#F59E0B` | Bekleme durumları, derecelendirme ve yıldız rozetleri |
| **Rose Crimson** | `#F43F5E` | Hata mesajları, başvuru retleri ve kritik bildirimler |

Renkler merkezi olarak `filizora/lib/core/constants/app_colors.dart` dosyasında tanımlanır ve ekranlara buradan dağıtılır.

---

## 6. Açık ve Koyu Tema Gereksinimleri

- **Açık Tema (Light Theme):** Modern beyaz kartlar (`#FFFFFF`), ferah zemin (`#F8FAFC`), okunaklı koyu metinler (`#0F172A`), şık şeffaf AppBar ve Royal Indigo marka vurguları.
- **Koyu Tema (Dark Theme):** Koyu obsidyen tonlarında zeminler (`#090D16`), derin gece kartları (`#1E293B`), okunaklı açık metinler (`#F8FAFC`) ve kontrollü gradyan kullanımı.
- **Tema Yönetimi:** `ThemeController` ile yönetilir; harici ağır paketler kullanılmaz.

---

## 7. Mimari Klasör Yapısı

Bütün uygulama kodları `filizora/lib/` altında özellik bazlı mimaride tutulur:

```text
filizora/
├── assets/
│   └── images/
│       └── filizora_logo.png
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   └── app_constants.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── theme_controller.dart
│   │   ├── extensions/
│   │   │   └── context_extensions.dart
│   │   └── widgets/
│   │       ├── app_logo.dart
│   │       ├── app_theme_toggle_button.dart
│   │       └── brand_palette_bar.dart
│   ├── features/
│   │   ├── admin/
│   │   │   └── view/
│   │   │       └── admin_dashboard_view.dart
│   │   ├── investor/
│   │   │   └── view/
│   │   │       └── investor_dashboard_view.dart
│   │   ├── authentication/
│   │   │   ├── controller/
│   │   │   ├── models/
│   │   │   ├── view/
│   │   │   └── widget/
│   │   ├── mentor_matching/
│   │   │   ├── controller/
│   │   │   ├── models/
│   │   │   │   ├── mentor.dart
│   │   │   │   └── match_request.dart
│   │   │   ├── view/
│   │   │   └── widget/
│   │   ├── entrepreneur_community/
│   │   │   ├── controller/
│   │   │   ├── models/
│   │   │   ├── view/
│   │   │   └── widget/
│   │   ├── support_programs/
│   │   │   ├── controller/
│   │   │   ├── models/
│   │   │   ├── view/
│   │   │   └── widget/
│   │   └── venture_tracking/
│   │       ├── controller/
│   │       ├── models/
│   │       ├── view/
│   │       └── widget/
│   └── main.dart
├── test/
│   └── widget_test.dart
├── pubspec.yaml
└── README.md
```

---

## 8. Kod Kalitesi Standartları

- **State Yönetimi:** Sayfa seviyesinde ağır `setState` kullanımından kaçınılmalıdır. Durumlar `ValueNotifier` / `ChangeNotifier` tabanlı controller'lar ile yönetilir.
- **Küçük Widget'lar:** 40 satırı aşan `build` metotları daha küçük alt widget'lara bölünmelidir.
- **`const` Kullanımı:** Statik arayüz öğelerinde mutlaka `const` kullanılmalıdır.
- **Paket Kullanımı:** Gereksiz veya ağır paketler eklenmemelidir.

---

## 9. Test ve Doğrulama Komutları

Değişikliklerin ardından aşağıdaki komutlar `filizora/` dizininde çalıştırılmalı ve doğrulanmalıdır:

```bash
# Bağımlılıkları alma
flutter pub get

# Statik kod analizi
dart analyze # veya flutter analyze

# Birim ve widget testleri
flutter test
```
