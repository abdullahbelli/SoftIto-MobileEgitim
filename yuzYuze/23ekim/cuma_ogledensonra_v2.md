## Sözleşmeler, SOLID Prensipleri & OOP Mimarisi

### 1.1. `interface` (arayüz/sözleşme)

**Sözlük anlamı** İki bağımsız sistemin biribiryile nasıl konuşacağını belirleyen içi boş metot imzalarından oluşan kurallar bütünü.
**_Neden Kullanılır:_** Bir sınıfa göbekten bağımlı kalmama (örnğin geçek şarj istasyonu ciazı olmadan shate/mock şarj servisiyle testi çalıştırabilmek) için

```dart
abstract interface class StationContreact{
    Future<void> startCharcing(String socketId);
    Stream<double> watchLivePower();
}
```

---

### 1.2. `implements`vs `extends` vs `with`

#### 1.2.1. `implements` (Arayüz sözleşmesi)

**_Sözlük Anlamı:_** Bir sınıfın, bir şablonun belirlediği kralları kabul edip **içini sıfırdan kendisinin doldurması** zorunludur.
**_Neden Kullanılır:_** Farklı sınıflara ortak bir standart sözleşme dayatmak, çoklu arayüz desteği sağlamak ve kodda bağımlılıkları azaltmak için.

#### 1.2.2. `extends`(Kalıtım/miras)

**_Sözlük Anlamı:_** Bir sınıfın başka bir sınınfın özellikleri ve metotlarını doğrudan devr almasıdır..
**_Neden Kullanılır:_** Kod tekrarını önlemek(DRY), mantıksal bir sınıf hiyerarşisi oluşturmak için.

#### 1.2.3. `with`(mixin/yetenek aşılama)

**_Sözlük Anlamı:_** Sınıf hiyerarşisini bozmadan, bağımsız bir sınıfa hazır kod blokları (metotlar ve değişkenler) enjekte etme mekanızmasıdır.
**_Neden kullanılır_** Akraba olmayan sınıflara ortak yetenekler kazandırmak, çoklu kalıtım kimliğini önlemek ve modülerliği arttırmak için.

---

### 1.3. SOLID Prensipleri ( Mobil & Dart Odaklı)

#### 1. S - Single Responsibility pRİNCİPLE (tek Sorumluluk Prensibi)

**_Kural_** Bir sınıfın veya dosyanın değişmesi için **_yalnızca 1 sebebi_** olmalıdır.

#### 2. O - Open/Close Principle (Açık/Kapalı Prensibi)

**_Kural_** Yazılım varlıkları (sınıflar, modüller) **genişletilmeye AÇIK , ancak değiştirilmeye KAPALI** olmalıdır.

#### 3. L - Liskov Substitution Principle (Liskov Yerine Koyma Prensibi)

**_Kural_** Bir üst sınıfın yerine , onun alt sınıflarında herhangi biri geçirildiğinde sistemin davranışı bozulmamalı ve hata fırlatmamalıdır.

#### 4. I - Interface Segregation Principle (Arayüz Ayırma Prensibi)

**_Kural_** İstemciler(sınıflar), kullanmadıkları metotları içermeye zorlanmamalıdır. Şişman (fat) interfaceler yerine küçük amaca önelik arayüzler kurulmalıdır.

#### 5. D - Dependency Inversion Principle (Bağımlılıkların Tersine Çevrilmesi Prensibi)

**_Kural_** Yüksek seviyeli modüller (UI, iş mantığı) düşük seviyeli modüllere (veri tabanı, HTTP istemcisi) doğrudan bağımlı olmamalıdır. Her ikisi de soyutlamalara (abstractions) bağlı olmalıdır.

---

### 1.4. `Coupling`(Bağlaşıklık & `Cohesion`(Uyum)

**_Tightly Coupled ( Sıkı bağımlı):_** Sınıfların birbirinin her detayını bilmesi. Birinde yapılan bir harflik değişiklik diğer 5 dosyayı bozuyrsa sistem sıkı bağımlıdır.
**_Loosely Coupled (Gevşek Bağımlı):_** Sınıfların sadece inerface üzerinden konuşması. Biri değiştiğinde diğeri etkilenez.
**High cohesion ( yüksek uyum):** Bir sınıfın sadece ve sadece kendi uzmanlık alanını yapması.

---

## STREAM TEMELLERİ, CUBIT & ENTERPRISE BLOC

### 2.1. `Stream`Nedir ?( blOc'un Kalbindei Motor)

**_Sözlük Anlamı:_** Zamann içinde parça para gelen, akıp giden asenkron veri dizisi.
**_ BLOC SIRRI _** BLOC kütüpanesi sihirli bir şey yapmaz! BLoC un iinde gizli bir `StreamController`vardır. Event'ler borunun bir ucundan girer(`sink.add`), BLoC onları işler ve diğer ucundan ekrana stat akıtır (`stream.listen`).

### 2.2. Tablo

### 2.3. BLoC 'un 3 Temel Elemanı: `Event`,`State`,`Emitter`

**_Event (Olay)_** kullanıcının veya sistemin BLoC'a attığı emir fişi.
_mini Sözdizimi:_ `class StartChargingRequested extends ChargingEvent {final String socketId;}``

**_State (Durum)_** Ekranın o milisaniyedeki dondurulmuş fotoğrafı (snapshot).
_Mini Szödizimi:_ `class ChargingActiveState extends ChargingState {final double kwh;}``
**Özel Durumlar:** `Initial`, `Loading`, `Loaded`, `Error``

**\*Emitter** BLoC'un ürettiği yeni state'i ekrana fırlattığı megafon borusu.
**Kural:** Senkron çalışır ; `emit(NewState())`dendiği anda UI'daki builder'lar tetiklenir.

Kullanıcı ekrandayken asenkron işlem başlar (await api.fetchSockets()). Kullanıcı cevap gelmeden geri tuşuna basıp sayfayı kapatır. BLoC/Cubit yok edildiği (closed) için hemen ardından gelen emit() satırı:

**Hata:** `StateError: Cannot emit new states after calling close`
hatasını fırlatır ve uygulama çöker!

**Çözüm:** Asenkron await satırından sonraki her emit mutlaka şu şekilde korunmalıdır:

```dart
final data = await repository.getData();
if (!isClosed) {
  emit(DataLoaded(data));
}
```

### 3.1. `Side Effect` (Yan Etki) Neden `BlocBuilder`'ın tek görevi **Widget döndrmektir**.

- Flutter otoru ekranı saniyede 60 kez çizilebilir (Rebuild). Eğer siz `BlocBuilder`içine `ScaffoldMessenger.showSnackBar`veya `Navigator.push`yazarsanız; kullanıcı cihazı yan çevirdiğinde veya klavye açıldığında kullanıcıya **üst üste 10 defa SnackBar patlar veya 10 kez yeni sayfa açılır!**

- **Kural** Yan etkiler SADECE `BlocListener` içine yazılır; çünkü `listener` sayfa rebuild olduğunda değil, **yalnzıca State değiştiğinde 1 kez** tetiklenir!

### 3.2. `BlocSelector`(Mikro Performas & Pil Tasarrufu)

- **Kavram:** State'in içindeki onlarca alandan sadece **1 tanesini süzüp izlemek**.

---

## 4. EŞİTLİK, DEĞİŞMEZLİK & BLOCOBSERVER

### 4.1. `Reference Equality` vs `Value Equality`

- **Dart Varsayılanı (Referans Eşitliği):** İki nesnenin bellekteki (RAM) adresi aynı mı?
  `Soket('A') == Soket('A')` --> false \*\*İçerikleri aynı olsa da RAM'deki evleri farklıdır.\*\*

- **Değer Eşitliği (Value Equality):**
  Nesnelerin içindeki veriler aynı mı?
  `Equatable`paketi tam olarak bunu çözer: Nesneleri RAM adresine göre değil, `props` listesindeki alanların değerine göre karşılaştırır.

### 4.2. `props`Listesi Yazılmazsa Ne Olur?

- BLoC ekran kartını yormak için şu denetimi yapar : `if (yeniState == eskiState) ekraniCizme();`
- Eğer siz `StationLoaded`state'ine yeni bir `filterType`alanı eklerseniz ama `props`içine yazmayı unutusanız; BLoC iki state'i eşit zanneder ve **ekranı güncellemez, arayüz douk kalır!**

### 4.3. `Immutability`(Değişmezlik) & `copyWith`

- **Kural:** State sınıflarının üm alanları `fnal`olmalıdır. Değişmez.
- **`copyWith` Mantığı:** Eski nesenin (örn) 5 alanını okruyup, sadece değişen 1 alanını güncelleyerek taze bir nesne üretne yöntemidir.

```dart
final guncel = state.copyWith(isCharging:true);//Diğer alanlar bozulmadan kopyalanır
```

### 4.4. `BlocObserver` (Tüm Uygulamayı Röntgenleme)

- **Kavram:** uygulamadaki tüm BLoC ve Cubitlerin arkasında çalışan merkezi bir kara kutu / telemetri kaydedici.
- **Ne İşe Yarar?:** Hangi ekranda hangi Event fırlatılı, State nereden nereye geçti (`onTransition`) ve nerede hata fırlatıldı (`onError`) te merkezden konsola loglanır. Kurumsal projelerde analitik ve çökme takibi için zorunludur.

## 5. CLEAN ARCHITECTURE KATMANLARI & SORUMLULUK

### 5.1. `Entity` ve `Model / DTO`

- **`Entity`(Varlık)** Saf iş nesnesifdir. Bİr şarj soketinin gerçek hayattaki özelliklerini (`id`, `kw` , `durum`) tutar. `fromJson`veya `toJson`içermez.
- **`Model /DTO` /Data Transfer Object)** API'den gelen ham JSON verisini karşılayan taşıyıcıdır. ` Entity`den türer; `fromJson`ve `toJson`metotlarını barındırır.
  **"Neden Entity içine `fromJson`yazmıyoruz? Cevap: Yarın backend json yerine xml veya protobuf formatINDA GEÇERSE ; Domain katmanındaki iş kurallarımız ve UI sayfalarımızı zerre kadar etkilenmesin ,sadece DATA katmanındaki mODEL etilensin diye!**

### 5.2 `UseCase` (Kullanım Senaryosu)

- **Kavram:** kullanıcınn veya sistemin gerçekleştirebilceği **tek atomik bir iş kıuralı** Örnekler: StartChargingSessionUseCase, GetStationSocketsUseCase, RefundWalletBalanceUseCase. Kural: Her UseCase sınıfının içinde sadece tek bir call() veya execute() fonksiyonu bulunur

### 5.3. `Repository Contract`(Sözleşme) `Repository Implementation`(Somut)

- **Contract (Domain Katmanında):** Sadece sözleşmedir (abstract interface class StationRepository). Verinin nereden geleceğini bilmez.
- **Implementation (Data Katmanında):** Sözleşmeyi uygulayan somut sınıftır (class StationRepositoryImpl implements StationRepository). Verinin önce yerel diskten mi yoksa internetten mi çekileceğine karar verir.

## 6. BAĞIMLILIK YÖNETİMİ: DEPENDENCY INJECTION & `get_it`

### 6.1. Neden `new Dio()` Yazmak Yasaktır?

Eğer 5 ayrı sayfada `final dio = Dio();` derseniz:

1. Bellekte 5 ayrı bağlantı havuzu açılır, telefonun soket sınırını zorlar.
2. Base URL veya Timeout değiştiğinde 5 ayrı dosyayı elle değiştirmek zorunda kalırsınız.
3. Test yazarken sahte (mock) veri enjekte edemezsiniz.

### 6.2. `GetIt` Kayıt Tipleri: Singleton vs LazySingleton vs Factory

- **`Singleton`:** Uygulama açıldığı milisaniyede nesneyi üretir ve belleğe çiviler.
- **`LazySingleton`:** Uygulama açıldığında üretmez! Ne zaman ilk kez birisi `sl<Dio>()` derse o an üretir ve sonrasında hep aynı nesneyi verir. (Bellek ve açılış hızı dostudur).
- **`Factory`:** Her çağrıldığında yepyeni, sıfır bir kopyasını üretir.

Eğer 5 ayrı sayfada final dio = Dio(); derseniz:

Bellekte 5 ayrı bağlantı havuzu açılır, telefonun soket sınırını zorlar.
Base URL veya Timeout değiştiğinde 5 ayrı dosyayı elle değiştirmek zorunda kalırsınız.
Test yazarken sahte (mock) veri enjekte edemezsiniz.

## 7. KURUMSAL AĞ MİMARİSİ: DIO, INTERCEPTOR & HTTP STATUS KODLARI

Sözlük Anlamı: Ağ isteği telefondan çıkıp internete gitmeden önce veya sunucudan cevap gelip koda düşmeden önce araya girip paketi inceleyen/değiştiren güvenlik noktası.

### 7.2. Bearer Token & Payload

Bearer Token: "Bu anahtarı taşıyan kişi giriş yapmaya yetkilidir" anlamına gelen şifrelenmiş kimlik kartı metni (Authorization: Bearer eyJhbGci...).
Payload: Bir API isteğiyle sunucuya gönderilen veya sunucudan bize dönen asıl veri gövdesi (Body).

### 7.3. HTTP Durum Kodları Sözlüğü (Sınıfa Tahtada Sorulacak)

- **200 OK:** İstek başarılı, veri gövdede.
- **201 Created:** Yeni kayıt (örneğin yeni şarj oturumu) başarıyla oluşturuldu.
- **400 Bad Request:** İstemci hatası; eksik veya hatalı parametre gönderdin.
- **401 Unauthorized:** Token yok veya süresi dolmuş; hemen Login'e yönlendir!
- **403 Forbidden:** Giriş yaptın ama bu veriyi görmeye yetkin yok (Admin değilsin).
- **404 Not Found:** Aradığın soket veya istasyon sunucuda bulunamadı.
- **500 Server Error:** Backend sunucusu patladı; istemcilik bir hata yok.

## 8. VERİ DAYANIKLILIĞI: CACHE-FIRST & SAVUNMACI KODLAMA

### 8.1. Cache-First (Önce Önbellek) Stratejisi

- **Mantık:** Kullanıcı şarj istasyonu listesini açtığında 1 saniye bile beyaz ekranda spinner bekletme! Diskteki dünkü veriyi **0.01 milisaniyede** ekrana bas. Arka planda sunucudan taze veriyi çek; gelince ekranı ve diski sessizce güncelle.

### 8.2. `Defensive Programming`(Savunmacı Programlama)

- **Mantık:** Sunucudan gelen veriye asla %100 güvenmeme prensibi.
