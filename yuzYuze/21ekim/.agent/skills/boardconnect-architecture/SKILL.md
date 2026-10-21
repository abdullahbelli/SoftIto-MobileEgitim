---
name: boardconnect-architecture
description: BoardConnect Flutter+Supabase mimarisi; auth/OTP, oda güvenliği, misafir oturumları, sonsuz tuval koordinatları, nesne modelleri ve gerçek zamanlı senkronizasyon için kullanılır.
---

# BoardConnect — Mimari / Veri / Realtime Skill'i

## Kullanım
Supabase, auth, veritabanı, RLS, gerçek zamanlı oda, nesne modeli, çizim motoru, dışa aktarma veya performansla ilgili kod değiştirirken bu skill'i uygula. Önce `project.md` ve `boardconnect-general` oku.

## Önerilen katmanlar
- Flutter features: `auth`, `rooms`, `whiteboard`; her birinde gerektikçe `data/domain/presentation`.
- `presentation`: ekran, widget, controller/provider.
- `domain`: model, iş kuralı, event/command tanımları.
- `data`: Supabase repository, DTO ve mapping.
- `core`: yapılandırma, hata, tema ve ortak yardımcılar. Global paylaşılan state'i sınırlı tut.
- Riverpod ile state; tek router (`go_router` önerisi); Supabase Flutter SDK.

## Auth ve güvenlik
- Google OAuth Web + Android/iOS + Windows/macOS/Linux callback/deep link akışlarını ayrı ayrı doğrula.
- E-posta kayıt doğrulama ve şifre kurtarma için **6 sayısal haneli OTP, 90 saniye** ürün gereksinimidir. Supabase Auth varsayılan süre/şablonlarını varsayma; gerçek sunucu tarafı OTP TTL, gönderim limitleri, rate limit ve yeniden gönderim davranışı destekleniyor mu ilk aşamada doğrula. Gerekirse sunucu tarafı güvenli özel OTP akışı tasarla; sırf Flutter sayacıyla 90 saniyelik geçerlilik sağlanmış sayma.
- Kodlar plaintext loglanmamalı/saklanmamalı; deneme sınırı, yeniden gönderimde eski kodun geçersizleşmesi ve tek kullanımlılık tasarlanmalı.
- 6 hane tamamlanmadıkça onay butonu pasif olmalı; kullanıcı kod girdi diye başarılı sayılmaz, sunucu onayı zorunludur.
- Şifre yenileme yalnızca doğrulanmış kurtarma işleminin yetkilendirdiği kısa süreli akışta yapılır; doğrudan istemciden keyfî kullanıcı parolası değiştirme yoktur.
- Misafirler tuvalde tam **editör** yetkisine sahip olabilir; fakat bu, oda silme/yönetici işlemleri veya başka odaların verilerine erişme yetkisi vermez.
- Misafiri anonim auth oturumu + oda üyeliği veya doğrulanmış, kısıtlı token akışı ile yetkilendir; yalnız isim+oda kodu frontend kontrolü güvenli değildir.
- PostgreSQL'de RLS, Storage ve Realtime channel authorization oda üyeliğiyle denetlenir. Client içinde `service_role` ve gizli anahtar bulunmaz.

## Oda modeli
- `profiles`: kullanıcı kimliği/görünen ad/kullanıcı adı.
- `rooms`: ID, ad, sahip, kapasite, oluşturulma ve son değişiklik bilgisi, silinme durumu.
- `room_members`: oda + kullanıcı/konuk oturumu, rol, eşsiz atanmış renk, son erişim; sahip/üye ayrımı.
- Davet kodu ve linki backend tarafından doğrulanır; tahmin edilebilir kısa kodu doğrudan güvenlik anahtarı olarak kabul etme. Çakışma, iptal, süresi ve kötüye kullanım sınırı düşün.
- Çalışmalar listesi erişim hakkı devam eden önceki odaları gösterir.
- Oda sahibi silme talebinde doğrulama/onay ve ilgili veri temizliği/soft delete stratejisi uygula.

## Sonsuz tuval ve nesneler
- Sonsuz tuval **sonsuz veritabanı boyutu** demek değildir. Tüm nesneler sanal dünya koordinatlarında (`x`,`y`) bulunur; kamera `panX`, `panY`, `scale` dönüşümüyle görüntüler. Negatif koordinatlar ve çok uzak konumlar desteklenmeli.
- Input (dokunma/fare) koordinatlarını world-space'e çevir; zoom düzeyi değişince nesne konumları bozulmamalı.
- Nesnelerin kararlı UUID'leri, türleri, özellikleri, z-index, sürümü, `is_pinned` durumu, oluşturucu bilgisi ve `deleted_at` tutulabilir.
- Tipler: `stroke`, `rectangle`, `ellipse`, `arrow`, `text`, `sticky_note`, `image`.
- Silgi davranışını açık belirt: ilk sürümde nesne bazlı silme veya stroke silme; kısmi stroke silme ayrı algoritma gerektirir. Kodda davranışı tutarlı uygula.
- Sabitleme (`is_pinned`) post-it, metin, şekiller içindir; sabitlenen nesne kazara taşınmaz/yeniden boyutlandırılmaz. Silme ve sabitlemeyi kaldırma yetki kuralını ayrıca koru.
- Undo/redo, çoklu seçim gibi kesinleşmemiş özellikleri otomatik zorunlu hale getirme.

## Gerçek zamanlı protokol
- Oda başına yetkilendirilmiş Realtime kanalı: kalıcı nesne değişiklikleri + Presence + geçici imleç/konum mesajları.
- Katılımcılar kendi renkleriyle temsil edilir; imleç/işlem etiketinde kullanıcı adı + renk görünür.
- Giriş/ayrılış SnackBar olayları Presence geçişlerinden üretilirken başlangıç snapshot'ı ve geçici kopmalar nedeniyle yanlış/tekrarlı duyuru üretilmemeli.
- Kalıcı veri için güvenli veritabanı yazma gerekir; **Broadcast tek başına saklama değildir**.
- İşlem türlerini açıkça modelle (`object_created`, `object_updated`, `object_deleted`, `pointer_moved`, `presence_changed` vb.). Her mesaja `roomId`, `objectId` (varsa), `actorId`, sıra/sürüm ve kimlik/işlem ID ekle.
- Kalem hareketleri ve cursor güncellemelerini throttle/batch et; ağda her frame'i sınırsız gönderme.
- Aynı nesneye eş zamanlı dokunuşlarda optimistic concurrency/version check kullan; çakışma çözülmeden sessiz veri kaybına izin verme.
- Bağlantı koptuğunda local unsaved değişiklikleri belirt; reconnect sonrası kalıcı durumu yeniden çekip güncellemeleri tutarlı eşleştir.
- Odadaki kullanıcı kapasitesi sunucu tarafında atomik şekilde doğrulanmalı.

## PNG / SVG ve görseller
- PNG, istenen görünür alan veya nesne sınırlarını kapsayan kontrollü export alanında üretilir; sonsuz canvas'ın tamamını rasterize etmeye çalışma.
- SVG için world-space nesnelerini ayrı bir serializer ile çizgi/şekil/metin bileşenlerine dönüştür; font ve resim referansları için taşınabilirlik stratejisi uygula.
- Platforma göre dosya kaydetme/paylaşma arayüzünü ayır.
- Görsel yüklemede MIME/tür, boyut, oda erişimi ve Storage RLS denetimleri yap.

## Veri bütünlüğü ve doğrulama
- `profiles`, `rooms`, `room_members`, `board_objects`, `assets` başlangıç tabloları; `guest_sessions` gerektiğinde.
- İndeks: oda + son değişiklik, oda + nesne, oda + üye. Uniqueness ve foreign key kullan.
- Odaya ait her okuma/yazma isteğinde üyelik/izin kontrolü olsun.
- RLS testleri: dış oda erişimi, misafir düzenleme, misafir oda silme reddi, oda doluluğu, silinmiş oda, hatalı davet kodu.
- En az iki farklı istemci oturumuyla senkronizasyon, reconnect, aynı anda taşıma ve silme senaryolarını test et.

## Mimari kontrol soruları
- Bu iş akışı istemcide mi, sunucuda mı doğrulanmalı?
- Bu olay kalıcı mı yoksa geçici mi?
- Başka oda/kullanıcı verilerine erişim engelleniyor mu?
- Yeniden bağlandığında doğru sonuç üretiliyor mu?
- Sonsuz canvas zoom/pan koordinatları deterministik mi?
- Web/mobil/masaüstü davranış farkları test edildi mi?
