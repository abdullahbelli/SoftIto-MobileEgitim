# Ritmia — Proje Tanımı ve Ürün Kuralları

> **Tür:** Flutter ile geliştirilen Android/iOS odaklı alışkanlık kazanma ve takip uygulaması  
> **Durum:** Başlangıç teknik şartnamesi (v1.1 — MVC)  
> **Dil:** Türkçe (metinler yerelleştirmeye hazır olacak)  
> **Çalışma ilkesi:** Önce çalışır, yerel verili MVP; çok kullanıcılı lig/gerçek oturum için backend entegrasyonu ayrıca yapılacak.

## 1. Vizyon, isim ve kimlik

**Uygulama adı: Ritmia**. Slogan: **“Küçük adımlar, güçlü alışkanlıklar.”** Kimlik; yumuşak, sıcak, modern, motive edici ancak çocukça olmayan bir tasarım. Logo: yuvarlatılmış halka/ritim izi içinde filiz ile küçük yükselen kıvılcım birleşimi. Logo ve rozetler SVG/Flutter CustomPainter ile üretilebilir; mümkünse tek bir görsel dil ve tema renkleri kullanılsın. Logo, açılış, giriş/kayıt ve TopBar'da tutarlı olsun. İsim ve sembol uygulama içi çalışma adıdır; yayımlamadan önce marka/mağaza uygunluğu kontrol edilmelidir.

## 2. Temel kullanıcı yolculuğu

1. Açılış (splash) → oturum yoksa **Giriş Yap**, oturum varsa **Alışkanlıklarım**.
2. **Giriş Yap:** ortalanmış logo, kullanıcı adı veya e-posta, şifre, giriş butonu ve “Hesabın yok mu? Kayıt ol”. Şifre göster/gizle, doğrulama ve anlaşılır hata durumları.
3. **Kayıt Ol:** logo, ad, soyad, e-posta, benzersiz kullanıcı adı, şifre, şifre tekrarı, kayıt butonu; girişe dönüş. İstemci doğrulaması: e-posta formatı, kullanıcı adı 3–20 karakter, şifre en az 8 karakter. Gerektiğinde sunucu tarafında da doğrulanmalı.
4. Giriş sonrası ilk sekme **Alışkanlıklarım**. Alt gezinme: Alışkanlıklarım, Takvim, Liderlik, Profil. Alt çubukta ikon + etiket; seçili sekme belirgin.
5. İlk kullanımda boş durum: “Henüz bir alışkanlık eklemediniz.” ve kısa bir teşvik metni. Sağ altta yalnızca **+** simgeli FAB; boş durumda nazik sıçrama animasyonu; kullanıcı etkileşimdeyken veya hareket azaltma ayarında animasyonu kısıtla.
6. **+** → klavyeye göre kayan, sürüklenebilen, kaydırılabilir **modal bottom sheet** içinde alışkanlık formu.
7. Başarıyla ekledikten sonra alışkanlık kartı görünür ve bir günlük hedef işaretlenebilir; gün sonu ilerleme, streak, rozet ve puanlar hesaplanır.

## 3. Alışkanlık ekleme ve düzenleme

**Form alanları:**
- Alışkanlık adı (zorunlu, 3–60 karakter), kısa açıklama (isteğe bağlı, max 160).
- Kategori (Sağlık, Spor, Öğrenme, Zihin, Üretkenlik, Diğer) ve kategoriyle eşleşen ikon; isteğe bağlı görsel/ikon seçimi. V1'de ikon seçimi yeterli, kullanıcı görsel yüklemesi sonraki aşama.
- Hedef tipi: **Tamamlandı/Tamamlanmadı**, **Adet**, **Dakika**. Hedef miktarı tipine göre örn. 1 kez, 20 sayfa, 30 dakika; pozitif sayı zorunlu.
- Tekrarlama: **Her gün** veya **haftanın seçilen günleri** (en az bir gün). Varsayılan her gün.
- Başlangıç tarihi (varsayılan bugün). Bitiş tarihi opsiyonel; bitiş, başlangıçtan önce olamaz.
- İsteğe bağlı hatırlatma saati (v1'de arayüz/saklama; gerçek yerel bildirimler ayrı izin ve entegrasyon gerektirir).
- Renk seçimi (önceden tanımlı, erişilebilir palet).

**İşlem kuralları:**
- Form hem ekleme hem düzenleme için yeniden kullanılır; düzenleme kartın sağ üstündeki **kalem** simgesinden açılır.
- Silme, kart menüsündeki veya düzenleme içindeki **çöp kutusu** ile yapılır; geri dönüşü olmayan silmeden önce onay diyaloğu. V1'de soft delete önerilir; mevcut geçmişi ve istatistiği korumak için silinmiş alışkanlık aktif listede görünmez.
- Bir gün içindeki ilerleme 0..hedef aralığında gösterilir; artırma/azaltma ve tamamlandı işaretleme vardır. Hedefe ulaşıldığında o gün tamamlanmış sayılır. Bir günü tekrar işaretlemek ek puan kazandırmaz.
- Değişen hedef/tekrar kuralı, **gelecek planlanan günlere** uygulanır; geçmiş tamamlanma kayıtları ve daha önce kazanılan puanlar geriye dönük manipüle edilmez. Geçmiş kayıt gününün hedefi `targetSnapshot` içinde tutulur.
- Gelecek günlere tamamlanma yazılamaz. Geçmiş gün düzenleme v1'de **yalnızca mevcut gün**; geçmiş düzeltme ileriki sürüm işi.

## 4. Alışkanlıklarım ekranı

- Üst uygulama çubuğu: **ortada Ritmia logosu**, sağda alev simgesi ve **genel streak** sayısı; logo etkileşimi opsiyonel.
- Genel streak: o gün planlanmış tüm alışkanlıklar tamamlandıysa başarılı gün. Planlı alışkanlığı olmayan gün genel streak'i artırmaz veya kırmaz; önceki ve sonraki planlı günlerin sürekliliği korunur. Hiç aktif plan yoksa 0 gösterilir. Kullanıcının bugün henüz tamamlamadığı planlar varken, dünkü seri hemen sıfırlanmaz; ancak gün bittiğinde kırılır.
- Kart: alışkanlık adı, kategori görseli/ikonu, bugünkü hedef ve ilerleme çubuğu, **alışkanlığa özgü ardışık planlı gün serisi**, bağlamsal motivasyon metni, güncel tamamla/ilerlet kontrolü, sağ üstte kalem ikonu. Silme işlemi kalemle açılan düzenleme formundaki çöp kutusundan veya erişilebilir overflow menüsünden.
- Motivasyon örnekleri: 0 gün → “Bugün ilk adımını at!”; 1–6 → “Harika gidiyorsun, seriyi koru!”; 7–29 → “Bir haftayı aştın, ritmi yakaladın!”; 30–364 → “İstikrarın ilham veriyor!”; 365+ → “Bir yılı geride bıraktın!”; eksik gün için yargılamayan metin.
- Boş, yükleniyor, hata, erişilebilirlik ve dar ekran durumları düşünülür.

## 5. Takvim ve günlük rapor

**Karar: Ana Takvim ekranı gün bazlı genel görünüm olacak; alışkanlık detayına girildiğinde aynı bileşenin o alışkanlığa filtrelenmiş görünümü sunulacak.** Böylece günlük tablo ile alışkanlık bazlı analiz birlikte mümkündür.

- Aylık takvim, aylar arası geçiş, bugüne git eylemi; gelecekteki günler nötr.
- Günün planlanan alışkanlıklarından tamamlananların oranına göre ton: **%100 koyu yeşil**, **%67–99 orta yeşil**, **%34–66 açık yeşil**, **%1–33 soluk yeşil**, **%0 kırmızı**; o gün planlı hiçbir alışkanlık yoksa nötr gri. Renk dışında sayısal oran veya `x/y` etiketi de olmalı.
- Güne dokununca bottom sheet veya sayfa: tarih, tamamlanan/toplam, hangi alışkanlıkların tamamlandığı, miktar/hedef, genel/alışkanlık streak, motive edici durum mesajı. Geçmiş verilere yalnızca bakılır.
- Alışkanlık detayındaki “Geçmişi Gör” ile o alışkanlığa filtrelenmiş takvim ve seri istatistikleri açılır.
- Planlanan günler ve tarih hesabı kullanıcının **yerel takvim günü** temelinde yapılır; UTC'de anlık zaman saklanır, günlük kayıt anahtarı `YYYY-MM-DD` yerel gün olarak tutulur. Saat dilimi değişiklikleri için tutarlı dönüşüm politikası test edilir.

## 6. Liderlik panosu ve lig sistemi

**Katılım isteğe bağlı:** İlk açılışta “Yarışmaya katılmak ister misin?” açıklaması; **Katıl** ve **Şimdilik değil** seçenekleri. Reddederse kişisel takibe devam eder, daha sonra profilden/lig ekranından katılabilir. Profilde görünen adın ligde kullanılması için katılım öncesi onay alınır.

**Ligler:** Tohum → Filiz → Tomurcuk → Çiçek → Yıldız (en alt → en üst). Her **lig grubu en fazla 15 katılımcı**; aynı lig seviyesinde çok grup olabilir. Sıralama grup içindedir. Her hafta **Pazartesi 00:00 – Pazar 23:59:59** yerel saatine göre puan toplanır; yeni hafta sunucu otoritesiyle resetlenir. Takvim saatleri sunucuda güvenilir hafta kimliğine çevrilir.

**Haftalık kural:**
- Grubun puanına göre **ilk 5** üst lige yükselir (en üst ligde kalır), **son 5** alt lige düşer (en alt ligde kalır), diğerleri korunur.
- **Katılımcı sayısı 10 veya daha azsa** terfi/düşme bölgeleri çakışmasın diye `min(5, floor(N/3))` üst ve alt kişi kullanılır. N=1–2 için hareket yok; 15 kişilik dolu grupta 5/5 kuralı aynen geçerlidir.
- Puan eşitliğinde: daha fazla tamamlanan planlı alışkanlık → daha yüksek en uzun haftalık seri → puana daha erken ulaşan kayıt → benzersiz kullanıcı ID. Son sıra sunucuya göre belirlenir.
- Haftanın ilk 3'üne **altın/gümüş/bronz haftalık derece rozeti**; rozetler haftaya ve grup kimliğine bağlı olarak arşivlenir. Üst/alt lig sınırında lig seviyesi değişmez, fakat konum/başarı gösterilir.
- Haftalık başlangıç anında katılanlar mevcut haftaya katılabilir; sıralama ve hareket hesaplaması dönem sonunda yapılır. Sıfır üyeli/eksik gruplar sunucuda dengelenebilir; 15 sınırı aşılmaz.

**Puan kuralı (v1, öneri ve kesinleştirilmiş):**
- Planlı günde tamamlanan her alışkanlık = **10 puan** (hedef miktarına bağlı ek puan yok; yüksek hedefler haksız avantaj yaratmasın).
- Bir günün **bütün planlı alışkanlıkları** tamamlanırsa **+5 günlük bonus** (o gün planlı en az 1 alışkanlık varsa).
- Alışkanlık bazında **ardışık planlı tamamlanma serisi** 7, 30, 365'e ulaştığında **bir kereye mahsus** sırasıyla **+20/+60/+200 puan**; yalnızca eşik hangi hafta aşıldıysa o haftanın puanına eklenir.
- Bir kullanıcı için **günlük sıralama puanı en çok 55**: ilk 5 tamamlanan alışkanlık (50) + günlük bonus (5); eşik rozet puanları ayrıca bu üst sınır dışında tek seferlik verilir. Böylece onlarca basit alışkanlık ekleyerek sınırsız puan alınamaz.
- Puanlar yalnızca sunucuda doğrulanan, benzersiz `userId+habitId+localDate+awardType` olaylarından hesaplanır; tekrar isteğinde çift puan verilmez. Retroaktif düzeltme yönetimi sunucu kurallarıyla yapılmalıdır.

**ÖNEMLİ altyapı sınırı:** Gerçek kullanıcı sıralaması, grup ataması, haftalık lig geçişleri, senkronizasyon ve güvenilir puan hesabı **backend gerektirir**. Backend henüz kurulmamışsa UI ve veri modelleri geliştirilsin; örnek veriler “**Demo lig — örnek veriler**” olarak açıkça etiketlensin. Diğer kullanıcılar gerçekmiş gibi gösterilmesin ve gerçek lig çalışıyor izlenimi verilmesin. Sonradan Supabase/Auth + Postgres + RLS + sunucu fonksiyonları/scheduled jobs eklenebilecek şekilde soyut arayüzler kullanılsın.

## 7. Rozetler ve profil

**Alışkanlık başarı rozetleri** (alışkanlık bazında 7, 30, 365 ardışık **planlı gün**):
- **7 gün – İlk Kıvılcım** (bronz/turuncu ışık)
- **30 gün – Sağlam Ritim** (gümüş/mor ışık)
- **365 gün – Ritmin Ustası** (altın/ışıltılı ışık)

Birden fazla alışkanlık için ayrı kazanım kaydı olabilir. Haftalık lig sıralaması rozetleri farklı bir aile olarak saklanır. Kazanılmamış rozet silik ve kilitli görünür; kazanılmış olan kazanıldığı tarih ve hangi alışkanlıktan geldiğiyle gösterilir. Tüm çizimler aynı çizgi kalınlığı, şekil dili ve gölge mantığını kullanır; emoji, rastgele stok ikon ve üretken görseller gelişi güzel karıştırılmaz.

**Profil:** Avatar/baş harf, ad-soyad, @kullanıcıadı, e-posta, kayıt tarihi, toplam tamamlanan gün, en iyi seri, rozetlerim, yarışma katılımı, profil düzenle, görünüm ve vurgu rengi, çıkış yap. Profil düzenleme doğrulaması; çıkış yapmadan önce gerekirse onay; yerel veriler sessizce silinmez.

## 8. Tema ve tasarım

- **Aydınlık tema (varsayılan):** Pudra pembe `#FCE7F3`, ana pembe `#DB2777`, koyu metin `#301526`, beyaz/kırık beyaz yüzeyler. Erişilebilir kontrast için açık zeminlerde ana pembe metin rengi ve buton içeriği test edilmeli.
- **Karanlık tema:** Morumsu mürdüm/gece eriği `#1B1421`, yüzey `#292033`, vurgu gül-koralı `#FB7185`, metin `#F9F1F7`.
- Kullanıcı açık/koyu/sistem seçenekleri ve önceden tanımlı vurgu renkleri (pembe, mor, mavi, yeşil, turuncu) arasında seçim yapabilir. Seçim yerel kalıcıdır.
- Material 3; 8 pt spacing sistemi, yuvarlatılmış kartlar, dokunma alanı min. 48x48 logical pixel, metin büyütmede taşma olmamalı, animasyonlar ölçülü.
- Tasarım önce 360–430 dp telefon; tablet/yatay ekranlarda uyarlansın. Klavyede form alanları kaybolmasın.

## 9. Teknik kapsam ve mimari

- Flutter + Dart, **mobile-first Android/iOS**; Material 3.
- **Feature-first MVC (Model–View–Controller) + SOLID**. Eğitimde görülen MVC klasör isimlerini ve sorumluluklarını kullan.
  - **Model:** `Habit`, `HabitDayProgress` vb. veri yapıları; gerektiğinde JSON/SQLite dönüşümleri ayrı mapper ile.
  - **View:** Ekranlar, kartlar, formlar, animasyonlar ve sadece arayüzle ilgili geçici durumlar. Veritabanına doğrudan erişmez.
  - **Controller:** Kullanıcı eylemlerini karşılar, veriyi yükler/değiştirir, işlem durumunu yönetir ve View'e bildirir. Widget kodunu veya SQL sorgusunu içine almaz.
  - **Service:** Streak, rozet, puan ve lig gibi tekrar kullanılabilir karmaşık iş kurallarını Controller'dan ayırır.
  - **Repository:** SQLite/ileride API okuma-yazma işlemlerini soyutlar; ayrı bir Clean Architecture `data/domain/presentation` düzeni **kurma**.
- Başlangıçta anlaşılır olsun diye **ChangeNotifier + Provider** kullan; `HabitController extends ChangeNotifier` gibi. `go_router` gezinme; **SQLite/drift** yerel alışkanlık/günlük kayıtları; `shared_preferences` yalnız tema ve basit ayarlar için. Projeye uygun güncel kararlı paket sürümlerini doğrula.
- Gerçek kimlik doğrulama **backend olmadan güvenli biçimde yapılamaz**. V1 için `AuthRepository` sözleşmesi ve **yalnızca development/demo** oturum simülatörü oluşturulsun. Düz metin parola SQLite veya SharedPreferences'a yazılmasın. Demo oturumu gerçek hesapmış gibi sunulmasın.
- Lig için `LeaderboardRepository` arayüzü + açıkça etiketlenmiş `DemoLeaderboardRepository`; gerçek uygulama geldiğinde değiştirilebilir.
- Kritik hesaplar (`streak`, takvim oranı, rozet eşikleri, puan, lig hareketleri) saf fonksiyon/servis şeklinde test edilebilir olmalı.
- Controller arayüze loading, success, empty, error durumlarını sunar; Repository hatalarını anlaşılır mesajlara dönüştürür.

## 10. Önerilen klasör yapısı

```text
lib/
  main.dart
  app/
    app.dart
    routes/app_router.dart
    theme/app_theme.dart
  core/
    constants/
    services/
    utils/
    widgets/
  features/
    auth/
      models/
      views/
      controllers/
      repositories/
    habits/
      models/habit.dart
      models/habit_day_progress.dart
      views/my_habits_view.dart
      views/widgets/habit_card.dart
      views/widgets/habit_form_sheet.dart
      controllers/habit_controller.dart
      repositories/habit_repository.dart
      services/habit_streak_service.dart
    calendar/{models,views,controllers,services}/
    leaderboard/{models,views,controllers,repositories,services}/
    badges/{models,views,controllers,services}/
    profile/{models,views,controllers,repositories}/
  l10n/
assets/
  branding/
  badges/
test/
  unit/
  widget/
  integration/
.agent/
  skills/
    flutter-ui-design/SKILL.md
    flutter-mvc-architecture/SKILL.md
    flutter-development-rules/SKILL.md
project.md
```

`{models,views,...}` gösterimi klasör gruplarını kısaltır. **Gerçek projede yalnız ihtiyaç duyulan klasörleri üret.** MVC klasörleri her özelliğin içinde yer alır. Repository/Service MVC'yi değiştiren ayrı mimari katmanlar değil, SOLID'i koruyan yardımcı sorumluluklardır.

## 11. Veri modelleri (minimum)

- `UserProfile`: id, firstName, lastName, email, username, avatarPath?, joinedAt, leaderboardOptIn.
- `Habit`: id, userId, name, description?, category, iconKey, accentColorKey, targetType, targetValue, scheduledWeekdays, startDate, endDate?, reminderTime?, archivedAt?, createdAt, updatedAt.
- `HabitDayProgress`: habitId, localDate, amount, targetSnapshot, completedAt?, scheduleSnapshot, updatedAt; (`habitId`, `localDate`) unique.
- `BadgeDefinition`, `EarnedBadge`: badgeId, userId, habitId?, leagueWeekId?, earnedAt, awardedEventId (unique).
- `League`: id, tier, weekId, maxMembers=15; `LeagueMember`: leagueId, userId; `ScoreEvent`: idempotencyKey, points, reason, localDate, serverTimestamp.
- `UserSettings`: themeMode, accentColorKey, notificationPreferences.

## 12. MVP ile ileri aşamanın ayrımı

**MVP'de gerçekten çalışacak:** navigasyon, bütün temel ekranlar, demo oturum, yerel alışkanlık CRUD, hedef takibi, local streak/takvim, rozet hesaplama, profil arayüzü/düzenlemenin yerel simülasyonu, tema, demo lig arayüzü.

**Entegrasyon bekleyen:** gerçek e-posta/hesap ve şifre sıfırlama, birden çok cihaz senkronizasyonu, gerçek kullanıcı ligi/terfi, merkezi puan güvenliği, push veya yerel bildirim izinleri, fotoğraf yükleme, canlı bildirimler. Bunları bitmiş gibi göstermeyin.

## 13. Test ve kabul kriterleri

1. Yeni kullanıcı giriş/kayıt sayfaları ve boş Alışkanlıklarım ekranını görür; + butonu zıplar ve form modal açılır.
2. Alışkanlık ekle/düzenle/sil ve anlık ilerleme güncellemesi çalışır; silme onay gerektirir.
3. Farklı hedef tipleri ve haftalık tekrarlama takvimde doğru hesaplanır.
4. Plan dışı gün gri görünür; %0 planlı gün kırmızı; tamamlanan orana göre yeşil koyulaşır. Gün detayı açılır.
5. 7/30/365 **planlı başarılı gün** rozetleri tam eşiğinde ve yalnız bir kez verilir; aynı kayıt yeniden yazıldığında ikinci puan/rozet oluşmaz.
6. Gün kapanmadan streak yanlışlıkla sıfırlanmaz; tarih sınırları, hafta başlangıcı, saat dilimi için testler olur.
7. 15 kişilik grupta 5 yükselir/5 düşer; 10 veya az kullanıcıda bölgeler çakışmaz; eşitlikler deterministik çözülür.
8. Lig katılımı zorunlu değildir; reddedilirse yarışma dışı mod devam eder.
9. Tema ve renk tercihi uygulama yeniden başlatıldığında saklanır; light/dark erişilebilirlik sağlanır.
10. `flutter analyze`, biçimlendirme ve temel unit/widget testleri başarılı olur; gerçek backend yokken demo etiketi görünür.

## 14. Antigravity çalışma kuralları

- Önce `project.md` ve ilgili `.agent/skills/**/SKILL.md` dosyalarını oku; bu dokümanları kaynak kabul et.
- Yalnızca görevin kapsamına giren dosyaları değiştir; var olan çalışır modülleri bozma, gereksiz yeniden yazma yapma.
- Her aşamadan sonra analiz/test çalıştır; yapılan değişikliği, bilinen kısıtı ve sonraki işi kısa raporla.
- Yeni özellik eklendiğinde `project.md` içindeki ilgili bölüm ve gerekirse skill yönergelerini güncelle; tamamlanmayan işlemi tamamlanmış gösterme.
- Kaynak kodda öğretici ama **anlamlı** Türkçe açıklamalar; özellikle iş kuralı ve karmaşık algoritmalar açıklanır. Her satıra tekrar eden yorum yazılmaz.
