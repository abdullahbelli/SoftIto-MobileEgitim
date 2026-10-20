# Filizora — Mobil Uygulaması

> **Fikirden girişime, girişimden büyümeye.**

Girişimcilerin mentorlarla eşleşmesini, toplulukla etkileşim kurmasını, kamu destek programlarına (KOSGEB, TÜBİTAK vb.) erişmesini ve girişim süreçlerini adım adım takip etmesini sağlayan modern, modüler ve özellik-bazlı (feature-first) Flutter uygulaması.

---

## 🚀 Proje Yapısı

Uygulama, `.agents/skills/` mimari ve tasarım kurallarına tam uyumlu olarak özellik bazlı mimaride geliştirilmiştir:

```text
proje_koku/
├── .agents/
│   └── skills/
│       ├── architecture/
│       │   └── SKILL.md
│       ├── design/
│       │   └── SKILL.md
│       ├── examples/
│       │   └── sample_screen.dart
│       ├── references/
│       │   └── state_flow.md
│       └── script/
│           └── generate_feature.sh
├── filizora/
│   ├── assets/
│   │   └── images/
│   │       └── filizora_logo.png
│   ├── lib/
│   │   ├── core/
│   │   │   ├── constants/
│   │   │   │   ├── app_colors.dart
│   │   │   │   └── app_constants.dart
│   │   │   ├── theme/
│   │   │   │   ├── app_theme.dart
│   │   │   │   └── theme_controller.dart
│   │   │   ├── extensions/
│   │   │   │   └── context_extensions.dart
│   │   │   └── widgets/
│   │   │       ├── app_logo.dart
│   │   │       └── app_theme_toggle_button.dart
│   │   ├── features/
│   │   │   ├── authentication/
│   │   │   │   ├── controller/
│   │   │   │   ├── models/
│   │   │   │   ├── view/
│   │   │   │   └── widget/
│   │   │   ├── mentor_matching/
│   │   │   │   ├── controller/
│   │   │   │   ├── models/
│   │   │   │   ├── view/
│   │   │   │   └── widget/
│   │   │   ├── entrepreneur_community/
│   │   │   │   ├── controller/
│   │   │   │   ├── models/
│   │   │   │   ├── view/
│   │   │   │   └── widget/
│   │   │   ├── support_programs/
│   │   │   │   ├── controller/
│   │   │   │   ├── models/
│   │   │   │   ├── view/
│   │   │   │   └── widget/
│   │   │   └── venture_tracking/
│   │   │       ├── controller/
│   │   │       ├── models/
│   │   │       ├── view/
│   │   │       └── widget/
│   │   └── main.dart
│   ├── test/
│   │   └── widget_test.dart
│   ├── pubspec.yaml
│   └── README.md
├── PROJECT.md
└── SKILL.md
```

---

## 🎨 5 Sabit Marka Rengi

- **Ocean Blue (`#005F85`):** Ana marka rengi ve temel etkileşimler
- **Teal (`#3A8B8E`):** İkincil bileşenler
- **Orange (`#FF7720`):** Önemli aksiyonlar ve vurgular
- **Amber (`#FAA82C`):** Yardımcı vurgular
- **Red (`#DE2C2C`):** Hata ve uyarı durumları

---

## 📱 Dört Ana Özellik

1. **Mentor–Menti Eşleşmesi:** Mentorları uzmanlık alanına göre filtreleme ve eşleşme talebi gönderme.
2. **Girişimci Topluluğu:** Girişimciler arası gönderi paylaşımı, filtreleme ve beğeni etkileşimi.
3. **Destek Programları:** KOSGEB, TÜBİTAK ve kamu desteklerinin listelenmesi ve kaydedilmesi.
4. **Girişim Süreci Takibi:** Girişimin mevcut aşaması (Fikir, MVP, Pazar vb.) ve aşama görevlerinin takibi.

---

## 🔐 Kayıt ve Yönetici Onayı Akışı

1. Kullanıcı ad, soyad ve e-posta ile kayıt ekranına gelir.
2. Kullanıcıya **"İş fikrim var"** ve **"İş fikrim yok"** seçenekleri sunulur.
3. İş fikri varsa fikir başlığı, sektör ve açıklama formu doldurulur.
4. Kayıt tamamlandığında kullanıcı hesabı `pendingApproval` (Yönetici Onayı Bekliyor) durumuna alınır.
5. Onay bekleyen kullanıcı 4 ana sayfaya erişemez ve durum bildirim ekranında tutulur.
6. Yönetici onayı verildikten sonra 4 ana özelliğe erişim açılır.

---

## 🛠️ Çalıştırma ve Test

Tüm komutlar `filizora/` klasöründe çalıştırılmalıdır:

```bash
# Bağımlılıkları yükle
flutter pub get

# Statik analizi çalıştır
dart analyze

# Testleri çalıştır
flutter test
```
