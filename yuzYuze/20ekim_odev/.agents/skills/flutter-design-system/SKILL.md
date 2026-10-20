---
name: rotiva-flutter-design-system
description: Rotiva marka kimliği, Material Design 3, erişilebilir tema ve tekrar kullanılabilir UI bileşenleri.
---
# Tasarım Sistemi Skill

## Marka
- Ad `Rotiva`; araç kiralama + yol hissi. Logo: stilize `R` + tek parça yol eğrisi + konum bitiş noktası; orijinal vektör/Flutter çizimi.
- Işık teması: `seedColor #1764C0`, beyaz/açık mavi yüzeyler; koyu metin.
- Koyu tema: `seedColor #FF922B`, arka plan `#15191F` civarı; açık metin, turuncu CTA.
- Renkler tema üzerinden gelsin: `Theme.of(context).colorScheme`; her widgetta sabit mavi/turuncu verme.
- Kontrast, özellikle koyu temada turuncu buton üzerindeki metin kontrol edilmeli.

## Material 3
`ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(...))` ile iki tema. `themeMode` kullanıcı ayarı ile `system/light/dark` olabilir; kullanıcı açık ve koyu modu elle seçebilir.

## Bileşenler
- Araç kartı: yerel resim/fallback, model, lokasyon, günlük fiyat, yakıt/vites, puan, CTA.
- Filtre ekranı: `ChoiceChip`, `FilterChip`, `DropdownButtonFormField`, gerekirse bottom sheet.
- Form: `TextFormField`, alan hatası, yardımcı metin; tıklanma hedefleri min. ~48dp.
- CTA: tek birincil buton, ikincil action için outlined/text.
- Silme, sözleşme, başarı için tutarlı `AlertDialog`.
- Fiyat özetinde ara toplam, ekstralar, indirim ve kalın genel toplam.

## Ekran uyumu
- 360–430dp genişlikte taşma olmamalı. Uzun sayfa `SingleChildScrollView`.
- Klavye açıldığında buton/alan görünürlüğünü koru.
- Tablet/Chrome genişliğinde ana içerik için makul `maxWidth` kullan; kartlarda responsive sütun sayısı.
- Görsel yoksa kırık Image göstermek yerine fallback asset/ikon.
- Tema değiştirince tüm ekranlar, navigation ve dialog renkleri tutarlı değişsin.

## UI dili
- Tüm son kullanıcı metinleri Türkçe, para `₺`, tarihler yerel/gün-ay-yıl.
- Loading, boş ekran, hata ve başarılı işlem durumlarını ayrı tasarla.
- Semantics label, anlaşılır kontrast, yalnız renkle bilgi aktarmama.
