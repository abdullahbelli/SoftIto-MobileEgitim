---
name: rotiva-rental-business-rules
description: Araç uygunluğu, arama/filtre, kiralama ücretleri, teslim seçenekleri, ödeme simülasyonu ve değerlendirme kuralları.
---
# Kiralama İş Kuralları Skill

## Arama ve stok
- İl değiştiğinde ilçe sıfırlanır; ilçeler yalnız seçili ile bağlıdır.
- Tarih aralığı `[başlangıç, bitiş)` kullan; bitiş daha ileri gün olmalı.
- Araç aktif değilse veya çakışan aktif/onaylı rezervasyonu varsa o tarihlerde kiralanamaz.
- Çakışma koşulu: `newStart.isBefore(oldEnd) && oldStart.isBefore(newEnd)`.
- Filtre kombinasyonunda AND; boş filtre tüm araçları getirir.

## Yaş ve ehliyet
- Araç yaş ve ehliyet süresi eşiklerini kiralama öncesi kontrol et.
- Kullanıcı kayıt formunda doğum tarihi/ehliyet yılı girmez; ilk kiralamada topla ve profilinde göster.
- Tam yıl hesabı yap; örneğin doğum günü henüz gelmediyse yaş bir yıl küçük olabilir.

## Fiyat formülü
```
gun = endDate - startDate  // takvim gün farkı, >= 1
aracBedeli = gun * gunlukUcret
kmEki = gun * secilenKmPaketininGunlukUcreti
teslimat = adreseTeslim ? teslimatUcreti : 0
nakitIndirimi = (subedenTeslim && subedeNakit) ? (aracBedeli + kmEki) * 0.10 : 0
toplam = aracBedeli + kmEki + teslimat - nakitIndirimi
```
- Saatlik ücret detayda **bilgi amaçlı**, bu projede saatlik rezervasyon yok.
- Fiyat değiştikçe özet güncellenir; hesap formülü UI dışında tek yerde olmalı.
- Para hassasiyeti için mümkünse kuruş cinsinden `int` hesapla, formatlayınca `₺` ile göster.

## Teslim / ödeme matrisi
| Teslim | Kart (demo) | EFT (demo) | Şubede nakit (demo) |
|---|---|---|---|
| Şubeden | Evet, indirim yok | Evet, indirim yok | Evet, %10 indirim |
| Adrese | Evet, teslim ücreti | Evet, teslim ücreti | **Hayır** |

- Kullanıcı teslim türünü nakit seçiliyken adrese değiştirirse ödeme yöntemi otomatik temizlenmeli ve açıklama gösterilmeli.
- Sözleşme kabul edilmeden ödeme ekranına geçilemez.
- Gerçek ödeme bilgisi alınmaz. `simüle ödemeyi tamamla` ile demo kiralama kaydı oluştur.

## Durumlar
- Örnek: `pending → approved → active → completed`; iptal yalnız izinli aşamalarda.
- `completed` olmayan kiralamada yorum kapalı.
- İptal edilen kiralamalar takvimde stok engellememeli.
- Kiralamaya bağlanmış araç aktifse silinemez; geçmişi bozmamak için soft delete/pasife alma uygun.

## Değerlendirmeler
- Araç puanı: araç yorumlarının 1–5 yıldız aritmetik ortalaması.
- Müşteri puanı: demo yönetici değerlendirmesi veya ayrı tutulan örnek müşteri skorlarından türetilmeli; araç yıldızlarıyla karıştırma.
- Hiç değerlendirme yoksa 0 yıldızlı gerçek puan gibi gösterme; "Puan yok".

## Zorunlu test senaryoları
1. 3 gün × 1000 ₺ = 3000 ₺.
2. 3 gün × 200 ₺ km paketi = 600 ₺ ek ücret.
3. Şubeden+naktinde (3000+600) üzerinden 360 ₺ indirim; toplam 3240 ₺.
4. Adrese teslim ücreti örn. 450 ₺ ise kartla toplam 4050 ₺; nakit seçimi kapalı.
5. Mevcut `[10,13)` ve yeni `[13,15)` çakışmaz, `[12,15)` çakışır.
6. Aynı kişi tamamlanan kiralamaya ikinci değerlendirme kaydı oluşturamaz.
7. Ek km ve teslim seçeneği değişince toplam anında yeniden hesaplanır.
