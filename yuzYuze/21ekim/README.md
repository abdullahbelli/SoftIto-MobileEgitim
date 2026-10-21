# BoardConnect — Çok Platformlu Gerçek Zamanlı Whiteboard

BoardConnect; uzaktan çalışan ekiplerin, tasarımcıların, eğitmenlerin ve öğrencilerin aynı dijital sonsuz tuval üzerinde gerçek zamanlı olarak ortak çalışabildiği modern bir whiteboard (beyaz tahta) uygulamasıdır.

Bu sürüm; **Flutter Web**, **Masaüstü** (macOS, Windows, Linux) ve **Mobil** (Android, iOS) platformlarıyla tam uyumlu mimaride geliştirilmiş olup, harici backend bağımlılığı olmadan **Mock Repository** ve **Yerel Kalıcı Hafıza (LocalStorage / SharedPreferences)** ile çalışır.

---

## 🌟 Öne Çıkan Özellikler

### 1. Sonsuz Tuval (Infinite Whiteboard Engine)
- **Sonsuz Dünya Koordinatları:** Sanal koordinat sistemi (`pan`, `scale`) ile deterministik çizim.
- **Pan & Zoom:** Fare tekerleği, iki parmak dokunmatik kıstırma (pinch-to-zoom) ve Pan aracıyla 0.2x ile 5.0x arası kusursuz yakınlaştırma. Zoom sırasında nesne konumları bozulmaz.
- **Gelişmiş Araç Çubuğu:**
  - 🎯 **Seçim & Taşıma:** Nesneleri seçme, sürükleyerek taşıma.
  - ✋ **Tuval Kaydırma (Pan):** Tuval üzerinde serbest gezinme.
  - ✏️ **Serbest Çizim (Kalem):** Akıcı, yuvarlak uçlu çizimler.
  - 🧹 **İşlevsel Silgi:** Üzerine gelinen çizgi ve nesneleri silme.
  - 📐 **Şekiller (Açılır Menü):** Dikdörtgen, Daire/Elips, Düz Çizgi ve Yön Oku (Ok başı ile). Basıp sürükleyerek boyutlandırma.
  - 📝 **Metin:** Tuvale doğrudan zengin başlık ve açıklamalar ekleme.
  - 📌 **Post-it Notlar:** 6 farklı renk seçeneğiyle yapışkan notlar ve yazar etiketi.
  - 🖼️ **Görsel Ekleme:** Tuval üzerinde görsel kartları konumlandırma.
  - ↩️ / ↪️ **Geri Al (Undo) & İleri Al (Redo):** 30 adıma kadar geçmiş kontrolü.

### 2. Nesne Etkileşimleri & Sabitleme
- Nesne seçildiğinde sağ üst köşesinde aksiyon kutusu belirir:
  - 🗑️ **Çöp Kutusu:** Nesneyi tuvalden siler.
  - 📌 **Raptiye (Sabitleme):** Nesneyi kilitler. Sabitlenen nesne taşınamaz ve yeniden boyutlandırılamaz. İkon durumu (`push_pin` / `push_pin_outlined`) ile kilit durumu görsel olarak anlaşılır.
  - ✍️ **Metin Düzenleme:** Post-it ve metin nesnelerinin içeriğini hızlıca günceller.

### 3. Tuval Arka Plan Desenleri
- **Düz:** Sade boş tuval.
- **Kareli (Grid):** Pan ve zoom ile dinamik ölçeklenen ızgara deseni.
- **Çizgili:** Not alma odaklı satır çizgileri.
- **Kâğıt / Noktalı (Dots):** Eskiz defteri hissi veren noktalı desen.

### 4. Dışa Aktarma (Export)
- 📥 **PNG İndirme:** Tuval içeriğini 2x çözünürlükte rasterize ederek PNG dosyası olarak indirir.
- 📐 **SVG İndirme:** Çizgi, şekil, ok, post-it ve metinleri standart W3C SVG XML vektör formatına serileştirir ve dosya olarak kaydeder.

### 5. Katılımcı & Ortak Çalışma Simülasyonu
- Her kullanıcıya özel atanmış renk paleti (Cyan, Emerald, Turuncu, Mor, Pembe vb.).
- Katılımcıların dünya koordinatlarındaki canlı konumları ve kendi renklerindeki isim etiketleri.
- Üst barda katılımcı avatarları ve `+N` grup rozeti.
- Katılımcı katıldığında ve ayrıldığında çıkan bildirimler (`Selin Yılmaz giriş yaptı`).

### 6. Kimlik Doğrulama (Authentication)
- **Giriş:** Form validasyonları ve şifre gizleme/gösterme.
- **Kayıt Ol:** İsim, soyisim, kullanıcı adı, e-posta ve şifre alanları.
- **Google ile Giriş:** Kullanıcıya entegrasyon durumunu bildiren bilgilendirme diyaloğu.
- **Misafir Girişi:** İsim ve oda kodu girerek hesap açmadan doğrudan odaya editör olarak katılma.
- **E-posta Doğrulama (OTP):** 6 haneli, yalnızca rakamlardan oluşan kod, `01:30` formatında 90 saniyelik geri sayım, süre bitiminde "Tekrar Gönder" butonu, 6 hane tamamlanmadan pasif olan "Onayla" butonu.
- **Şifremi Unuttum:** 90 saniyelik sayaçlı OTP koduyla sıfırlama talebi.
- **Yeni Şifre Oluşturma:** Güvenlik yönergeleri ve şifre eşleşme kontrolü.

### 7. Odalar ve Çalışmalar Yönetimi
- Oluşturulan ve katılınan odaların listesi (Oda adı, katılım kodu, kurucu, katılımcı sayısı).
- **Yeni Oda Oluştur:** Bottom sheet üzerinden oda adı ve maksimum kişi sayısı (2-30) belirleme.
- **Odaya Katıl:** Bottom sheet üzerinden davet koduyla odaya katılma.
- **Odayı Sil:** Yanlış silinmeleri önleyen onay diyaloğu.
- **Davet & Paylaşım:** Katılım kodunu ve bağlantıyı tek dokunuşla panoya kopyalama.

### 8. Tasarım & Tema Sistemi
- **Material Design 3** ilkeleri.
- **Sıcak Amber / Sarı Palet** (`#F59E0B`).
- **Açık (Light) & Koyu (Dark) Tema:** Tek dokunuşla geçiş ve `SharedPreferences` ile tercih hafızası.
- **Dinamik Vurgu Rengi:** Kullanıcı istediği zaman amber, altın, turuncu, yeşil, mavi veya mor renk paletini seçebilir.
- **Responsive Arayüz:** Mobil dikey modda araç çubuğu hareketsizlik halinde otomatik saydamlaşır (auto-dim). Geniş masaüstü ve web ekranlarında ergonomik dock düzeni sunar.

---

## 📂 Klasör Mimarisi

```text
lib/
├── main.dart                                   # Uygulama başlatma ve ProviderScope bağlama
├── app/
│   ├── app.dart                                # MaterialApp.router, tema ve yönlendirici
│   ├── router/
│   │   └── app_router.dart                     # go_router rota tanımları ve yetki yönlendirmeleri
│   └── theme/
│       ├── app_theme.dart                      # Light & Dark Material 3 temaları ve renk paletleri
│       └── theme_provider.dart                 # Riverpod tema modu ve vurgu rengi yöneticileri
├── core/
│   ├── config/
│   │   └── app_constants.dart                  # Sabitler (OTP süresi, LocalStorage anahtarları vb.)
│   ├── errors/
│   │   └── app_exception.dart                  # Hata yönetimi sınıfı
│   ├── utils/
│   │   ├── download_helper.dart                # Çapraz platform dosya indirme köprüsü
│   │   ├── download_helper_web.dart            # Flutter Web için Blob & Anchor indirme
│   │   └── download_helper_stub.dart           # Masaüstü/Mobil dosya indirme taslağı
│   └── widgets/
│       └── app_logo.dart                       # BoardConnect marka logosu ve başlığı
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   └── mock_auth_repository.dart       # SharedPreferences tabanlı kimlik doğrulama
│   │   ├── domain/
│   │   │   ├── auth_repository.dart            # Soyut auth arayüzü (Supabase için hazır)
│   │   │   └── user_model.dart                 # Kullanıcı veri modeli
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── auth_controller.dart        # Riverpod auth durumu
│   │       └── screens/
│   │           ├── login_screen.dart           # Giriş ekranı
│   │           ├── register_screen.dart        # Kayıt ekranı
│   │           ├── guest_login_screen.dart     # Misafir girişi ekranı
│   │           ├── otp_verification_screen.dart# 6 haneli, 90 sn sayaçlı doğrulama ekranı
│   │           ├── forgot_password_screen.dart # Şifremi unuttum ekranı
│   │           └── reset_password_screen.dart  # Yeni şifre belirleme ekranı
│   ├── rooms/
│   │   ├── data/
│   │   │   └── local_room_repository.dart      # Kalıcı oda listesi deposu
│   │   ├── domain/
│   │   │   ├── room_model.dart                 # Oda veri modeli
│   │   │   └── room_repository.dart            # Soyut oda arayüzü
│   │   └── presentation/
│   │       ├── controllers/
│   │       │   └── rooms_controller.dart       # Riverpod oda yönetimi
│   │       ├── screens/
│   │       │   └── rooms_screen.dart           # Çalışmalar ve odalar ana ekranı
│   │       └── widgets/
│   │           ├── create_room_sheet.dart      # Oda oluşturma bottom sheet'i
│   │           ├── join_room_sheet.dart        # Odaya katılma bottom sheet'i
│   │           ├── room_card.dart              # Oda kartı bileşeni
│   │           └── share_room_dialog.dart      # Davet ve kod paylaşım penceresi
│   └── whiteboard/
│       ├── data/
│       │   └── local_whiteboard_repository.dart# Odaya ait nesneleri yerel saklayan depo
│       ├── domain/
│       │   ├── board_object.dart               # Stroke, Shape, StickyNote, Text, Image modelleri
│       │   ├── canvas_theme.dart               # Arka plan desen türleri (Grid, Ruled, Dots, Plain)
│       │   ├── participant.dart                # Katılımcı ve renk atama modeli
│       │   └── whiteboard_repository.dart      # Soyut tuval veri arayüzü
│       └── presentation/
│           ├── controllers/
│           │   └── whiteboard_controller.dart  # Tuval motoru, pan, zoom, araçlar ve SVG export
│           ├── screens/
│           │   └── whiteboard_screen.dart      # Sonsuz tuval ekranı
│           └── widgets/
│               ├── canvas_background_painter.dart # Arka plan deseni çizicisi
│               ├── canvas_painter.dart         # Nesneleri ve canlı katılımcıları çizen motor
│               ├── object_action_overlay.dart  # Seçili nesne aksiyonları (Sil, Raptiye, Düzenle)
│               ├── shapes_menu.dart            # Şekil seçim menüsü
│               ├── text_edit_dialog.dart       # Post-it ve metin düzenleme penceresi
│               └── whiteboard_toolbar.dart     # Responsive araç çubuğu
```

---

## 🚀 Çalıştırma Adımları

### Gereksinimler
- Flutter SDK (>= 3.24.0)
- Dart SDK (>= 3.5.0)
- Google Chrome (Web için) veya macOS/Windows masaüstü geliştirme ortamı

### Bağımlılıkları Yükleme
```bash
flutter pub get
```

### Kod Kalitesi ve Test
```bash
# Kod biçimlendirme
dart format .

# Statik kod analizi (0 hata hedefi)
dart analyze

# Birim ve widget testlerini çalıştırma
flutter test
```

### Flutter Web'de Başlatma
```bash
flutter run -d chrome
```

### macOS Masaüstünde Başlatma
```bash
flutter run -d macos
```

---

## 🔑 Demo Giriş Bilgileri

Uygulama açıldığında test edebileceğiniz hazır demo hesabı:
- **E-posta:** `demo@boardconnect.com`
- **Şifre:** `Password123*`
- **Demo Doğrulama Kodu (OTP):** `123456` (veya herhangi 6 haneli sayı)
- **Hazır Demo Odaları:**
  - `BC-DEMO` (Sprint Planlama & Fikir Odası)
  - `BC-DESIGN` (Mobil UI Taslak & Whiteboard)

*Not: "Misafir Olarak Odaya Katıl" seçeneğiyle hiçbir hesap olmadan da doğrudan tuvale bağlanabilirsiniz.*

---

## 📋 Gelecek Supabase Entegrasyonu (TODO)

Aşağıdaki adımlar, backend katmanı hazır olduğunda mevcut UI ve State katmanına dokunulmadan kolayca devreye alınacaktır:

- [ ] **Supabase Projesi Kurulumu:** Supabase üzerinde PostgreSQL tabloları (`profiles`, `rooms`, `room_members`, `board_objects`, `assets`) oluşturulacak.
- [ ] **SupabaseAuthRepository Uygulaması:** `lib/features/auth/domain/auth_repository.dart` arayüzü `Supabase.instance.client.auth` ile eşlenecek.
- [ ] **Gerçek 6 Haneli OTP & Rate Limit:** Sunucu tarafında 90 saniye geçerli e-posta OTP doğrulama akışı (Edge Function veya Supabase Auth SMTP) yapılandırılacak.
- [ ] **Google OAuth Entegrasyonu:** Web, macOS ve Mobil için OAuth URL yönlendirmeleri ve deep link akışları bağlanacak.
- [ ] **SupabaseRoomRepository Uygulaması:** `room_repository.dart` PostgreSQL RPC ve RLS sorgularıyla çalışacak şekilde bağlanacak.
- [ ] **Supabase Realtime & Presence:** `whiteboard_repository.dart` kanal üzerinden `broadcast` ve `presence` dinleyicileriyle çok cihazlı anlık imleç ve nesne senkronizasyonuna geçirilecek.
- [ ] **Supabase Storage:** Görsel nesneleri için bucket oluşturulacak ve resim yükleme RLS kuralları belirlenecek.
- [ ] **Stitch UI Tasarımları:** İleride tasarım ekibinden gelecek Stitch tasarımlarına göre Material 3 token'ları ve görsel detaylar güncellenecek.
