# BoardConnect — PROJECT.md

> **Durum:** Geliştirme (Aşama 2-8 tamamlandı). Flutter Web, Masaüstü ve Mobil iskeleti, Material 3 tema ve sarı vurgu rengi, Mock Repository & LocalStorage mimarisi, tüm Auth ekranları (Giriş, Kayıt, Misafir, 90sn 6 haneli OTP, Şifremi Unuttum, Yeni Şifre), Çalışmalar/Odalar yönetimi, gerçek sonsuz tuval motoru (pan & zoom, kalem, silgi, şekiller, metin, post-it, resim), nesne sabitleme/silme, PNG & SVG indirme ve simüle edilmiş katılımcı sistemi başarıyla geliştirildi.

## 1. Proje Özeti
**BoardConnect**, uzaktan çalışan ekiplerin, öğrencilerin ve diğer kullanıcıların aynı dijital tuval üzerinde eş zamanlı olarak ortak çalışma yapabildiği çok platformlu bir whiteboard uygulamasıdır.

Kullanıcılar; serbest çizim yapabilir, silgi kullanabilir, şekiller çizebilir, metin ekleyebilir, post-it notlar oluşturabilir, görsel yükleyebilir, ortak odalara katılabilir ve çalışmaları PNG / SVG olarak dışa aktarabilir.

## 2. Amaç ve Hedef Kitle
### Amaç
- Uzaktan çalışan ekiplerin aynı tuval üzerinde gerçek zamanlı iş birliği yapmasını sağlamak.
- Beyin fırtınası, planlama, akış diyagramı, taslak çizim ve fikir toplama süreçlerini kolaylaştırmak.
- Hem kayıtlı kullanıcıların hem de misafirlerin kolayca ortak odalara katılabilmesini sağlamak.

### Hedef Kitle
- Uzaktan çalışan ekipler
- Öğrenciler ve proje grupları
- Eğitmenler
- Ürün / tasarım ekipleri
- Hızlı ortak not alma veya fikir üretme ihtiyacı duyan kullanıcılar

## 3. Hedef Platformlar
- **Flutter Web**
- **Windows / macOS / Linux masaüstü**
- **Android / iOS mobil**

Uygulama responsive / adaptive yapıda planlanacaktır. Fare, klavye, dokunmatik ekran ve mümkün olan cihazlarda kalem etkileşimleri dikkate alınacaktır.

## 4. Uygulama Adı ve Tasarım Yaklaşımı
- **Uygulama adı:** `BoardConnect`
- Üst barda her zaman uygulama logosu veya uygulama adı görünür.
- Başlangıç vurgu rengi **sarı tonları** olacaktır.
- Ancak renk teması kullanıcı tarafından ileride değiştirilebilir şekilde tasarlanacaktır.
- **Aydınlık tema** ve **karanlık tema** desteklenecektir.
- Tasarımlar önce **Stitch** üzerinde görülecek, geliştirme **Antigravity** ile ilerletilecektir.

## 5. Teknoloji ve Mimari (Önerilen)
| Katman | Teknoloji / yaklaşım | Kullanım |
|---|---|---|
| İstemci | Flutter + Dart | Web, masaüstü, mobil arayüz |
| UI | Material Design 3 | Tema, bileşenler, responsive yapı |
| State Management | Riverpod (öneri) | Uygulama durumu, oturum, oda, araçlar |
| Routing | go_router (öneri) | Sayfa yönlendirme |
| Çizim sistemi | CustomPainter + Canvas + gesture/pointer yönetimi | Tuval ve nesne çizimi |
| Kimlik doğrulama | Supabase Auth | E-posta/şifre, Google ile giriş |
| Veritabanı | Supabase PostgreSQL | Kullanıcılar, odalar, üyelikler, tahta nesneleri |
| Gerçek zamanlı iletişim | Supabase Realtime | Ortak çalışma, olay yayını |
| Çevrimiçi kullanıcı durumu | Supabase Presence | Oda içi aktif kullanıcılar |
| Depolama | Supabase Storage | Görseller ve varsa diğer medya yüklemeleri |
| Sunucu tarafı ek mantık | RLS + gerekirse Edge Functions / RPC | Yetkilendirme, kod akışı, ek iş kuralları |
| Dışa aktarma | Flutter raster + SVG serileştirme | PNG / SVG indirme |

### Mimari kararı
İlk sürümde ayrı bir özel backend zorunlu değildir. Supabase tabanlı mimari kullanılacaktır. İleride ihtiyaç olursa ek backend katmanı değerlendirilebilir.

## 6. Kullanıcı Türleri ve Erişim
### 6.1. Kayıtlı kullanıcı
- E-posta / şifre veya Google ile giriş yapabilir.
- Oda oluşturabilir.
- Daha önce oluşturduğu veya katıldığı odaları görebilir.
- Oda kodu veya bağlantı ile paylaşım yapabilir.
- Oda silebilir (yetkisi varsa / sahibi olduğu odalarda).

### 6.2. Misafir kullanıcı
- İsim ve oda / oturum kodu ile giriş yapabilir.
- Odaya katıldıktan sonra **tuvaldeki tüm temel işlemleri yapabilir**.
- Yani misafir kullanıcı da çizim, silgi, şekil, metin, post-it, görsel ekleme gibi işlemleri kullanabilir.
- Misafir erişiminin kapsamı uygulama tarafında açık tutulacak, ancak sunucu tarafında oda bazlı ve güvenli şekilde sınırlandırılacaktır.

### 6.3. Oda sahibi / yetkili kullanıcı
- Oda oluşturur.
- Oda silebilir.
- Odayı bağlantı veya kod ile paylaşabilir.
- İleride daha detaylı yetki sistemi eklenebilir.

## 7. Ekranlar ve Kullanıcı Akışları

### 7.1. Giriş ekranı
İçerik:
- BoardConnect logosu / adı
- E-posta alanı
- Şifre alanı
- **Giriş Yap** butonu
- **Google ile Giriş** butonu
- **Şifremi Unuttum** bağlantısı
- **Kayıt Ol** bağlantısı
- **Misafir** seçeneği

Notlar:
- Temiz ve modern görünüm.
- Sarı tonları başlangıç vurgu rengi olabilir.
- Giriş ekranından tüm ana akışlara geçiş yapılabilmelidir.

### 7.2. Misafir giriş ekranı
İçerik:
- İsim alanı
- Oturum / oda kodu alanı
- **Odaya Gir** butonu

Akış:
- Giriş ekranındaki **Misafir** seçeneği bu ekrana yönlendirir.
- Kullanıcı isim ve kod girer.
- Başarılıysa doğrudan ilgili odaya gider.

### 7.3. Kayıt ol ekranı
İçerik:
- İsim
- Soyisim
- Kullanıcı adı
- E-posta
- Şifre
- **Kayıt Ol** butonu
- **Google ile Giriş** butonu
- Giriş ekranına dönüş bağlantısı

Akış:
- E-posta ile kayıt olunursa doğrulama kodu ekranına geçilir.
- Google ile kayıt / giriş de desteklenir.

### 7.4. E-posta doğrulama kodu ekranı
Kurallar:
- Kod **yalnızca rakamlardan** oluşur.
- Kod **6 haneli** olmalıdır.
- Geçerlilik süresi **90 saniye** olacaktır.
- Sayaç formatı: **dakika:saniye** (`01:30` gibi)

İçerik:
- Bilgilendirme metni
- 6 haneli kod giriş alanı
- Geri sayım alanı
- Süre bitince **Tekrar Gönder** butonu
- **Onayla** butonu

Davranış:
- Kod girilmeden **Onayla** butonu pasif olur.
- Kod başarıyla doğrulanınca kullanıcı oturum akışına devam eder.

### 7.5. Şifremi unuttum ekranı
İçerik:
- E-posta alanı
- Kod giriş alanı
- İlk durumda **Kod Gönder** aksiyonu
- Kod gönderilince sayaç başlar
- Süre bitince **Tekrar Gönder** görünür

Kurallar:
- Gönderilen kod **yalnızca rakamlardan** oluşur.
- Kod **6 hanelidir**.
- Geçerlilik süresi **90 saniyedir**.
- Sayaç formatı **dakika:saniye** biçimindedir.

Akış:
- Kod doğrulandıktan sonra yeni şifre oluşturma ekranına geçilir.

### 7.6. Yeni şifre oluşturma ekranı
İçerik:
- Yeni şifre
- Yeni şifre tekrar
- Şifre yönergeleri
- **Şifreyi Onayla** butonu

Akış:
- Başarılı işlem sonrası giriş ekranına yönlendirme yapılır.

### 7.7. Çalışmalar / Odalar ekranı
İçerik:
- Kullanıcının oluşturduğu odalar
- Daha önce çalıştığı / katıldığı odalar
- Oda kartları
- Sağ tarafta veya sağ altta **+** butonu
- **Odaya Katıl** seçeneği

Ek özellikler:
- Kullanıcı kendi odalarını veya erişimi olan eski odaları bu ekranda görebilir.
- Odalar listesinde oda silme işlemi desteklenecektir.
- Oda kartlarında gerekli görülürse katılımcı sayısı, güncellenme tarihi gibi bilgiler yer alabilir.

### 7.8. Oda oluşturma modalı (bottom sheet)
İçerik:
- Oda adı
- Kişi sayısı
- **Oluştur** butonu

Akış:
- Oda oluşturulduğunda kullanıcı ilgili odaya yönlendirilir.
- Oda için paylaşılabilir bir kod üretilir.
- Gerekirse bağlantı ile paylaşım da desteklenir.

### 7.9. Odaya katılma modalı (bottom sheet)
İçerik:
- Oda kodu alanı
- **Gir** butonu

Akış:
- Başarılı girişte kullanıcı ilgili tuvale gider.

### 7.10. Tuval / Whiteboard ekranı
#### Genel yapı
- Tuval **sonsuz** olacaktır.
- Üst barda uygulama logosu veya adı (**BoardConnect**) sabit kalacaktır.
- Sağ üstte oda katılımcıları görünecektir.
- Katılımcı sayısı fazlaysa ilk birkaç kişi görünür, kalanlar gruplanarak gösterilir.

#### Sağ üst kullanıcı alanı
- Oda ilk kurulduğunda, kullanıcı avatarlarının göründüğü alanda başlangıçta **Davet** butonu yer alabilir.
- Kullanıcılar geldikçe bu alanı avatarlar ve davet butonu birlikte paylaşabilir.
- Yani sağ üstte hem kişi avatarları hem de davet aksiyonu yer alabilir.

#### Katılımcı durum bildirimleri
- Odaya yeni biri girdiğinde snackbar gösterilir:
  - `kullanıcı_adı giriş yaptı`
- Biri odadan ayrıldığında snackbar gösterilir:
  - `kullanıcı_adı ayrıldı`

#### Araç çubuğu
Araçlar:
- Kalem
- **Silgi**
- Şekiller
- Metin
- Post-it
- Resim ekleme
- Paylaş
- Dışa aktar
- İndir

Mobil / dikey davranış:
- Araç çubuğu altta bulunabilir.
- Bir süre işlem yapılmazsa saydamlaşarak gizlenebilir.
- Kullanıcı aynı bölgeye dokununca yeniden görünür.

#### Şekiller
- Şekiller açılır menü şeklinde olabilir.
- Şekil seçildiğinde aktif araç durumu görünmelidir.
- Gerekirse `+` göstergesi veya benzer aktif araç işareti kullanılabilir.
- Kullanıcı sürükleyerek şeklin boyutunu çizebilir.

#### Tuval temaları
Tuval arka planı kullanıcı tarafından değiştirilebilir:
- Düz / boş
- Kareli
- Çizgili
- Kâğıt hissi veren görünüm

#### Renk teması
- Başlangıçta sarı tonları kullanılır.
- Ancak ileride kullanıcı tarafından tema rengi değiştirilebilir şekilde planlanacaktır.

#### Kullanıcı konum / işlem gösterimi
- Oda içindeki her kullanıcıya bir renk atanacaktır.
- Kullanıcı tuval üzerinde hangi bölgede işlem yapıyorsa, o bölgede kullanıcının adı kendi rengiyle görünmelidir.
- Bu görünüm, ortak çalışmada kimin nerede işlem yaptığını anlamaya yardımcı olacaktır.
- İsim gösterimi renkli etiket / badge / label biçiminde düşünülebilir.

#### Nesne etkileşimleri
Aşağıdaki nesneler için gelişmiş etkileşim düşünülmektedir:
- Post-it
- Şekiller
- Metin

Bu nesneler için:
- İstenirse **sabitlenebilir**.
- Üzerlerine basılınca sağ üstlerinde küçük aksiyon ikonları görünebilir.
- Silmek için **çöp kutusu** ikonu olur.
- Sabitlemek için **raptiye** ikonu olur.
- Sabitleme kaldırıldığında ikon görünümü değişerek durum anlaşılır.
- Böylece kullanıcı nesnenin sabit mi serbest mi olduğunu anlayabilir.

#### Dışa aktarma
- Çalışma **PNG** olarak indirilebilir.
- Çalışma **SVG** olarak indirilebilir.
- Paylaşım oda kodu veya bağlantı ile olabilir.

## 8. Whiteboard Özellikleri
### Temel özellikler
- Serbest çizim
- Silgi
- Şekiller
- Metin araçları
- Post-it notlar
- Görsel ekleme
- Pan (kaydırma)
- Zoom (yakınlaştırma / uzaklaştırma)
- Sonsuz tuval
- PNG dışa aktarma
- SVG dışa aktarma

### Ortak çalışma özellikleri
- Oda tabanlı ortak çalışma
- Gerçek zamanlı değişim aktarımı
- Katılımcı varlığı / presence
- Kullanıcı başına renk atama
- Kullanıcının aktif konumunu isim etiketiyle gösterme
- Katıldı / ayrıldı snackbar bildirimi
- Kod ile paylaşım
- Bağlantı ile paylaşım

## 9. Gerçek Zamanlı Çalışma Mantığı
- Her oda ayrı bir gerçek zamanlı kanal olarak ele alınır.
- Tuval açıldığında önce mevcut içerik yüklenir.
- Sonrasında canlı değişiklikler dinlenir.
- Tüm tuval sürekli yeniden gönderilmez.
- Sadece değişen nesne veya işlem aktarılır.
- Serbest çizim verileri optimize edilerek gönderilir.
- Presence altyapısı ile aktif kullanıcılar gösterilir.
- Kullanıcılara atanmış renkler yardımıyla canlı çalışma alanları ayırt edilir.

## 10. Önerilen Veri Modeli (Taslak)
### Tablolar
- `profiles`
  - `user_id`
  - `display_name`
  - `first_name`
  - `last_name`
  - `username`
  - `avatar_url`
  - `created_at`

- `rooms`
  - `id`
  - `name`
  - `owner_id`
  - `join_code`
  - `share_link`
  - `max_participants`
  - `created_at`
  - `updated_at`
  - `is_deleted`

- `room_members`
  - `room_id`
  - `user_id` veya misafir referansı
  - `role`
  - `joined_at`
  - `last_accessed_at`
  - `assigned_color`

- `board_objects`
  - `id`
  - `room_id`
  - `type`
  - `payload` (JSONB)
  - `z_index`
  - `version`
  - `is_pinned`
  - `created_by`
  - `created_at`
  - `updated_at`
  - `deleted_at`

- `assets`
  - `id`
  - `room_id`
  - `object_id`
  - `storage_path`
  - `mime_type`
  - `uploaded_by`
  - `created_at`

- `guest_sessions` (gerektiğinde)
  - `id`
  - `guest_name`
  - `room_id`
  - `joined_at`
  - `expires_at`

### Nesne türleri
Başlangıçta desteklenecek nesne türleri:
- `stroke`
- `rectangle`
- `ellipse`
- `arrow`
- `text`
- `sticky_note`
- `image`

## 11. Proje Klasör Mimarisi (Taslak)
```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router/
│   └── theme/
├── core/
│   ├── config/
│   ├── errors/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── rooms/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── whiteboard/
│       ├── data/
│       ├── domain/
│       └── presentation/
│           ├── screens/
│           └── widgets/
└── shared/
```

## 12. Antigravity Geliştirme Kuralları
1. Kod yazmadan önce bu `project.md` dosyasını oku.
2. Mevcut yapıyı bozmadan ilerle.
3. Web, masaüstü ve mobil uyumluluğunu koru.
4. Responsive taşmaları kontrol et.
5. Özellikleri modüler geliştir.
6. Servis anahtarlarını kaynak koda gömme.
7. Yeni büyük özelliklerden sonra `project.md` güncelle.
8. `skill.md` dosyaları daha sonra hazırlanacak.
9. Geliştirme sırasında kullanıcı akışlarını ve ekran mantığını bu belgeye uygun şekilde uygula.
10. Tuval nesneleri, servisler, repository yapısı ve UI kodları mümkün olduğunca ayrık tutulmalı.

## 13. Geliştirme Aşamaları
- **Aşama 1:** Stitch tasarımları ve ekran akışları
- **Aşama 2:** Flutter iskeleti, tema, routing, Supabase bağlantısı
- **Aşama 3:** Auth akışları (giriş, kayıt, Google, doğrulama, şifre sıfırlama, misafir)
- **Aşama 4:** Çalışmalar / odalar ekranı, oda oluşturma, katılma, silme
- **Aşama 5:** Sonsuz tuval, çizim, silgi, şekiller, metin, post-it, resim ekleme
- **Aşama 6:** Realtime ortak çalışma, kullanıcı renkleri, canlı konum etiketleri, snackbar bildirimleri
- **Aşama 7:** Sabitleme, nesne aksiyonları, paylaşım, PNG / SVG dışa aktarma
- **Aşama 8:** Test, UX iyileştirme, performans, erişilebilirlik

## 14. Henüz Kesinleşmeyen Kararlar
- Logo tasarımı
- Kesin renk paleti seçenekleri
- Davet akışının detayları
- Yetki sistemi detayları
- Oda paylaşım bağlantısının teknik yapısı
- Çoklu seçim, undo/redo, kısayollar gibi ek gelişmiş özellikler
- Sabitlenen nesnelerin tam davranış kuralları

## 15. Notlar ve Değişiklik Geçmişi
- **2026-10-21:** İlk planlama sürümü oluşturuldu.
- **2026-10-21 / güncelleme:** Uygulama adı BoardConnect olarak belirlendi. Sonsuz tuval, silgi, kullanıcı renkleri, canlı konum etiketi, 6 haneli sayısal doğrulama kodu, 90 saniye süre, misafir tam tuval erişimi, sabitleme, oda silme, davet butonu, paylaşım seçenekleri ve snackbar bildirimleri eklendi.
- **2026-10-21 / uygulama sürümü:** Flutter projesi `yuzYuze/21ekim` altında oluşturuldu. Feature-based modüler mimari kuruldu:
  - `core/theme/`: Amber / sıcak sarı Material 3 açık ve koyu tema, dinamik renk seçici.
  - `features/auth/`: Giriş, Kayıt, Misafir, 90 saniye sayaçlı 6 haneli OTP doğrulama, Şifremi Unuttum ve Yeni Şifre ekranları `MockAuthRepository` ile bağlandı.
  - `features/rooms/`: Odalar listesi, kartlar, oda oluşturma ve katılma modal'ları, oda silme onay penceresi, davet ve kod paylaşımı `LocalRoomRepository` ile yerel hafızaya bağlandı.
  - `features/whiteboard/`: Sonsuz koordinat sistemi (`pan`, `scale`), CustomPainter çizim motoru, kalem, silgi, şekiller (dikdörtgen, elips, çizgi, ok), metin, post-it ve görsel kartları, sabitleme (`is_pinned`) kontrolü, nesne aksiyon kutusu, 4 tuval arka plan deseni (düz, kareli, çizgili, kâğıt/noktalı), PNG ve standart SVG dışa aktarma (indirme), katılımcı renk rozetleri ve bildirimleri eksiksiz tamamlandı.
  - Statik analiz (`dart analyze`: 0 hata), birim ve duman testleri (`flutter test`: 8/8 başarılı) ve web derlemesi (`flutter build web`: başarılı) tamamlandı.
