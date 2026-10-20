---
name: rotiva-project-orchestrator
description: Rotiva Flutter eğitim projesi için kapsam, kod kalitesi ve uzman skill seçimini yöneten ana beceri.
---
# Rotiva — Ana Skill

## Kaynak önceliği
1. `PROJECT.md`: ürün kapsamı ve iş kuralları (tek gerçek kaynak).
2. Bu `SKILL.md`: çalışma rutini.
3. Konuya uygun alt skill dosyası: uygulama yöntemi.
4. Var olan çalışan kod: entegrasyon bağlamı.

## Ne zaman hangi skill okunur?
- `flutter-architecture/SKILL.md`: klasörleme, state, model, repository, navigasyon.
- `flutter-design-system/SKILL.md`: Material 3, light/dark tema, renkler, bileşenler, uyumluluk ve logo.
- `flutter-forms-auth/SKILL.md`: form, validator, kayıt/giriş, KVKK/açık rıza, diyalog.
- `rental-business-rules/SKILL.md`: araç filtreleri, kiralama, uygunluk, fiyat, ödeme ve puanlar.
- `flutter-quality/SKILL.md`: test, analiz, erişilebilirlik, hata/boş/yükleniyor durumları.

## Sabit çalışma kuralları
- Yalnız `20ekim_odev/` içindeki kod/dosyalara müdahale et.
- Flutter uygulaması `rotiva/` içindedir; dıştaki MD dosyalarını `lib` içine kopyalama.
- Kod kolay anlaşılır olsun. Orta düzey karmaşıklık gerektiren çözüm yerine başlangıç seviyesinde temiz yaklaşımı seç.
- Backend, gerçek ödeme, gerçek kimlik doğrulama ve uzak görsel zorunluluğu getirme.
- İş kuralları ekran widget'larının içine gömülmesin; küçük controller / service / utility fonksiyonlarına ayrıştırılsın.
- Her butona çalışan bir görev ver; senaryo eksikse mock akış ile bitir.
- Tutarlı null safety, `const`, kısa widgetlar, anlamlı isimler ve kullanıcıya Türkçe mesaj kullan.
- Paket kullanmadan yapılabilen işleri gereksiz paketle çözme.
- Gereksinimi değiştirmek gerekiyorsa önce belgelerdeki ilgili alanı da güncelle; sessizce kapsam düşürme.

## Uygulama sırası
1. Mevcut çalışma alanını kontrol et, kullanıcı dosyalarını silme.
2. Ana navigasyon, modeller, örnek veri, tema ve temel ekranlar.
3. Her feature'ı uçtan uca (form → işlem → liste güncellemesi) tamamla.
4. Bir feature bitince `flutter analyze` ve ilgili testleri çalıştır; hataları gider.
5. Sonunda `flutter test` ve mümkünse `flutter run -d chrome` ile doğrula.
6. Türkçe raporda: oluşturulan/değişen dosyalar, nelerin çalıştığı, test sonucu, demo sınırları.

## Tamamlanma standardı
`PROJECT.md` bölüm 12 maddelerinin tümü karşılandığında tamamlanmış say. Sahte kart ödemesi açıkça **simülasyon** olarak etiketlenmeli. 
