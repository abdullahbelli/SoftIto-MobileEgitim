---
name: filizora-design
description: Filizora Görsel Tasarım, Marka Kimliği ve UI/UX Standartları
---

# Filizora — Görsel Tasarım ve UI/UX Kılavuzu

Bu doküman, Filizora uygulamasının marka kimliği, renk paleti, tipografisi, Material 3 tema altyapısı ve arayüz standartlarını tanımlar.

---

## 1. Marka Kimliği ve Logo

- **Uygulama Adı:** Filizora
- **Slogan:** Fikirden girişime, girişimden büyümeye.
- **Konsept:** Filizlenme, girişimci-mentor sinerjisi, topluluk ve sürdürülebilir büyüme.

### 1.1 Logo Kullanımı
- **Görsel Varlık:** `filizora/assets/images/filizora_logo.png`
- **Bileşen:** `filizora/lib/core/widgets/app_logo.dart`
- Logo boyutu ekran ihtiyacına göre `AppLogo(size: ...)` parametresi ile ölçeklenmelidir.
- Logo etrafında yeterli negatif boşluk bırakılmalı, görsel oranları bozulmamalıdır.

---

## 2. Sabit Marka Renk Paleti

Filizora'nın marka kimliği aşağıdaki 5 sabit renkten oluşur. HEX kodları kesinlikle değiştirilemez:

| Renk Adı | HEX Kodu | Kullanım Alanı |
|---|---|---|
| **Ocean Blue** | `#005F85` | Ana marka rengi, temel butonlar, odaklanmış etkileşimler |
| **Teal** | `#3A8B8E` | İkincil bileşenler, etiketler (chips), onay durumları |
| **Orange** | `#FF7720` | Önemli aksiyonlar, roket ikonları, dikkat çekici butonlar |
| **Amber** | `#FAA82C` | Bekleme durumları (kum saati), puan/yıldız rozetleri |
| **Red** | `#DE2C2C` | Hata mesajları, kritik uyarılar, doğrulama hataları |

Tüm renkler yalnızca `filizora/lib/core/constants/app_colors.dart` üzerinden çağrılmalıdır. Sayfa içinde doğrudan `Color(0x...)` tanımlanmaz.

---

## 3. Material 3 Açık ve Koyu Tema

Uygulama Material 3 tasarım dilini tam destekler.

### 3.1 Açık Tema (Light Theme)
- **Zemin:** Ferah açık renk (`#F8FAFC`).
- **Kartlar ve Yüzeyler:** Temiz beyaz (`#FFFFFF`) ve açık gri kenarlıklar (`#E2E8F0`).
- **Metinler:** Okunaklı koyu lacivert/gri tonları (`#0F172A`, `#475569`).
- **Vurgular:** Ocean Blue ağırlıklı buton ve ikonlar.

### 3.2 Koyu Tema (Dark Theme)
- **Zemin:** Koyu obsidyen tonları (`#0B0E14`).
- **Kartlar ve Yüzeyler:** Koyu obsidyen yüzey (`#141923`), kart (`#1C2230`) ve kenarlık (`#283144`).
- **Metinler:** Okunaklı açık tonlar (`#F0F4F8`, `#8B9BB4`).
- **Vurgular:** Beş marka renginin dengeli ve yüksek kontrastlı kullanımı.

### 3.3 Tema Geçişi
- Tema geçişi `ThemeController` üzerinden sağlanır ve tüm sayfaları anında etkiler.

---

## 4. Tipografi, Boşluklar ve Hiyerarşi

- **Tipografi:** `context.textTheme` üzerinden `titleLarge`, `titleMedium`, `bodyMedium`, `bodySmall` kullanılır.
- **Boşluk Standardı:** 4, 8, 12, 16, 20, 24 dp aralıkları kullanılır.
- **Köşe Yuvarlama:**
  - Kartlar: `16.0` dp
  - Butonlar ve Giriş Alanları: `12.0` dp
  - Etiketler (Chips): `8.0` dp

---

## 5. Bileşen Standartları

- **Kartlar (`Card`):** Gölgesiz (`elevation: 0`), temaya duyarlı 1px kenarlıklı, ferah iç boşluklu (16dp).
- **Butonlar (`ElevatedButton`, `FilledButton`, `OutlinedButton`):** Minimum 44dp tıklama yüksekliği, tam genişlikli form aksiyonları.
- **Form Alanları (`TextFormField`):** Temaya duyarlı arka plan dolgulu, belirgin odaklanma kenarlıklı.
- **Navigasyon (`NavigationBar`):** Material 3 alt çubuğu, net ikonlar ve kısa başlıklar.
- **Erişilebilirlik ve Kontrast:** Metin ve arka plan kontrastı WCAG standartlarına uygun tutulmalıdır; hata ve uyarı renkleri gereksiz yere dekorasyon amacıyla kullanılmamalıdır.
