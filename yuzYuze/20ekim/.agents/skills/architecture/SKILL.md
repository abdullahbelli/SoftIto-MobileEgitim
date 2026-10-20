---
name: filizora-architecture
description: Filizora Mimari ve Kod Organizasyonu Standartları
---

# Filizora — Mimari ve Kod Organizasyonu Kuralları

Bu doküman, Filizora projesinde kod mimarisi, klasör hiyerarşisi, durum yönetimi ve kod kalitesi standartlarını tanımlar.

---

## 1. Özellik Bazlı Mimari (Feature-Driven Architecture)

Bütün uygulama kodları `filizora/lib/` altında bulunur. Kodlar tek bir dosyada veya devasa sınıflarda toplanmaz; her özellik kendi modüler klasöründe yaşar.

### 1.1 `core/` Sorumlulukları
Uygulama genelinde paylaşılan, belirli bir iş alanına ait olmayan çekirdek bileşenler:
- `core/constants/`: Merkezi sabitler (`app_colors.dart`, `app_constants.dart`).
- `core/theme/`: Tema ve tema kontrolcüleri (`app_theme.dart`, `theme_controller.dart`).
- `core/extensions/`: Yardımcı uzantılar (`context_extensions.dart`).
- `core/widgets/`: Yeniden kullanılabilir global görsel bileşenler (`app_logo.dart`, tema butonları vb.).

### 1.2 `features/` Sorumlulukları
Her işlevsel modül bağımsız bir klasöre sahiptir:
- `features/authentication/`: Kayıt, giriş ve yönetici onayı bekleme.
- `features/mentor_matching/`: Mentor ve menti eşleşmesi.
- `features/entrepreneur_community/`: Girişimci paylaşım ve etkileşim akışı.
- `features/support_programs/`: KOSGEB ve girişimcilik destekleri.
- `features/venture_tracking/`: Girişim süreci ve aşama takibi.

---

## 2. Klasör İçi Katman Ayrımı (Controller, Model, View, Widget)

Her özellik klasörü içinde aşağıdaki 4 alt klasör bulunmalıdır:

```text
features/<feature_name>/
├── controller/   # İş mantığı, veri yönetimi, ValueNotifier/ChangeNotifier
├── models/       # Veri sınıfları, immutability, toJson/fromJson serialization
├── view/         # Sayfa seviyesi Scaffold ekranları (koordinasyon ve yönlendirme)
└── widget/       # Sayfaya özel, parçalanmış küçük UI bileşenleri
```

- **Controller:** UI durumunu ve veri işlemlerini yürütür. Sayfaların içine iş mantığı gömülmez.
- **Model:** `@immutable` veri modelleri, `copyWith` metotları ve JSON dönüşümleri içerir.
- **View:** `Scaffold` barındıran, alt widget'ları bir araya getiren ana ekranlardır.
- **Widget:** 40 satırı aşmayan, tek bir arayüz parçasından sorumlu bağımsız alt bileşenlerdir.

---

## 3. State Yönetimi Standartları

- Sayfa düzeyinde ağır `setState` kullanımından kesinlikle kaçınılmalıdır.
- `setState` yalnızca yerel arayüz durumları (sekme değişimi, metin gizleme/gösterme gibi anlık UI etkileşimleri) için kullanılabilir.
- Uygulama ve özellik durumları Flutter'ın yerleşik `ValueNotifier` / `ChangeNotifier` veya hafif controller sınıfları ile yönetilir.
- Kullanıcı onayı alınmadan Bloc, Riverpod, Redux gibi ağır harici state management paketleri eklenmez.

---

## 4. Kod Kalitesi ve Performans Kuralları

- **`const` Kullanımı:** Değişmeyen tüm widget'larda, EdgeInsets tanımlarında ve stillerde `const` kullanılmalıdır.
- **Build Metotlarını Bölme:** 40 satırı aşan `build` metotları okunabilirlik ve render performansı için özel widget sınıflarına (`StatelessWidget`) ayrılmalıdır.
- **Kod Tekrarını Önleme:** Benzer işlevler ve veri yapıları kopyalanmamalı, uygun ortak fonksiyon veya widget haline getirilmelidir.
- **Gereksiz Bağımlılıkları Önleme:** Flutter ve Dart standart kütüphanelerinin çözebildiği durumlar için harici paket eklenmemelidir.
- **İsimlendirme Standartları:**
  - Dosyalar: `snake_case` (ör: `mentor_matching_controller.dart`)
  - Sınıflar: `PascalCase` (ör: `MentorMatchingController`)
  - Değişkenler ve metotlar: `camelCase` (ör: `filterByExpertise`)

---

## 5. Yeni Özellik Ekleme Süreci

Yeni bir özellik oluşturulacağı zaman `.agents/skills/script/generate_feature.sh` script'i kullanılmalıdır:

```bash
bash .agents/skills/script/generate_feature.sh <özellik_adi>
```

Kurallar:
- Önceden var olan klasörler korunur, üzerine yazılmaz.
- İlgili controller, model, view ve widget katmanları eksiksiz yapılandırılır.
- Kodlar yazıldıktan sonra mutlaka test ve analiz çalıştırılır.

---

## 6. Test Edilebilirlik

- Model sınıfları serileştirme (`toJson` / `fromJson`) ve `copyWith` için birim testlerine sahip olmalıdır.
- Controller durum değişimleri (`filter`, `toggle`, `register`) test edilebilir arayüzler sunmalıdır.
- Ekran geçişleri ve akışlar widget testleriyle doğrulanabilir olmalıdır.
