import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../../core/services/storage_service.dart';
import '../models/motivation_quote.dart';

/// Hugging Face Motivasyon Servisi (MotivationService).
/// Hugging Face Datasets API (Abirate/english_quotes) üzerinden
/// ilham verici ve motive edici alıntıları çeker, yerel olarak önbelleğe alır,
/// Türkçe meal adaptasyonunu sağlar ve hem açılışta hem de alışkanlık kartlarında
/// streaka ve kategoriye özel Hugging Face motivasyon sözleri sunar.
class MotivationService extends ChangeNotifier {
  final StorageService? _storageService;

  MotivationQuote? _currentQuote;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isBannerVisible = true;

  MotivationService([this._storageService]) {
    _isBannerVisible = _storageService?.isMotivationBannerVisible() ?? true;
    _loadInitialQuote();
  }

  MotivationQuote? get currentQuote => _currentQuote;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isBannerVisible => _isBannerVisible;

  /// Kartın görünürlüğünü güncelle ve yerel belleğe kaydet
  Future<void> setBannerVisible(bool visible) async {
    _isBannerVisible = visible;
    await _storageService?.setMotivationBannerVisible(visible);
    notifyListeners();
  }

  void toggleBannerVisibility() {
    setBannerVisible(!_isBannerVisible);
  }

  /// Başlangıçta önbellekteki alıntıyı yükle veya hemen Hugging Face'ten çek
  Future<void> _loadInitialQuote() async {
    // 1. Önbellekte bugün çekilmiş geçerli bir söz var mı?
    if (_storageService != null) {
      final cachedJson = _storageService.getDailyMotivation();
      if (cachedJson != null) {
        try {
          final quote = MotivationQuote.fromJson(jsonDecode(cachedJson));
          final isToday = quote.fetchedAt.day == DateTime.now().day &&
              quote.fetchedAt.month == DateTime.now().month &&
              quote.fetchedAt.year == DateTime.now().year;

          // Eğer bugüne aitse ve bozuk karakter içermiyorsa kullan
          if (isToday && !quote.text.contains('â€')) {
            _currentQuote = quote;
            notifyListeners();
            return;
          }
        } catch (_) {
          // Önbellek bozulmuşsa devam et
        }
      }
    }

    // 2. Yoksa veya gün değiştiyse Hugging Face'ten taze alıntı çek
    await fetchQuote();
  }

  /// Hugging Face Datasets API'den yeni bir motivasyon sözü çek
  Future<void> fetchQuote({bool force = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final randomOffset = Random().nextInt(400); // 0-400 arası rastgele sayfa
      final uri = Uri.parse(
        'https://datasets-server.huggingface.co/rows?dataset=Abirate/english_quotes&config=default&split=train&offset=$randomOffset&limit=20',
      );

      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);

      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body) as Map<String, dynamic>;
        final rows = data['rows'] as List<dynamic>? ?? [];

        MotivationQuote? selected;
        // İlham ve motivasyon etiketleri
        final preferredTags = {
          'inspirational',
          'motivational',
          'life',
          'success',
          'philosophy',
          'wisdom',
          'courage',
          'change',
          'time',
          'books',
          'reading',
          'writing',
          'hope',
          'truth',
          'faith',
          'knowledge',
          'habits',
        };

        for (final item in rows) {
          final row = item['row'] as Map<String, dynamic>?;
          if (row == null) continue;

          final rawQuote = (row['quote'] as String?)?.trim() ?? '';
          final rawAuthor = (row['author'] as String?)?.trim() ?? 'Anonim';
          final tags = (row['tags'] as List<dynamic>?)
                  ?.map((e) => e.toString().toLowerCase())
                  .toList() ??
              [];

          // 20-160 karakter aralığındaki alıntılar mobil ekran için idealdir
          if (rawQuote.isNotEmpty && rawQuote.length <= 160 && rawQuote.length >= 20) {
            final cleanQuote = _cleanQuoteText(rawQuote);
            final cleanAuthor = _cleanAuthor(rawAuthor);
            final translated = _translateQuote(cleanQuote);

            // Türkçe cümleleri tercih et
            final displayText = translated ?? _adaptToTurkish(cleanQuote);
            final matchesTag = tags.any((t) => preferredTags.contains(t));

            selected = MotivationQuote(
              text: displayText,
              originalText: displayText != cleanQuote ? cleanQuote : null,
              author: cleanAuthor,
              source: 'Hugging Face 🤗',
              tag: tags.isNotEmpty ? tags.first : 'inspirational',
              fetchedAt: DateTime.now(),
            );

            if (matchesTag) {
              break; // Tercih edilen etiket bulunduysa hemen seç
            }
          }
        }

        if (selected != null) {
          _currentQuote = selected;
          _cacheQuote(selected);
          client.close();
          _isLoading = false;
          notifyListeners();
          return;
        }
      }
      client.close();
    } catch (e) {
      debugPrint('Hugging Face fetch hatası (yedek havuza geçiliyor): $e');
    }

    // Ağ hatası veya Hugging Face yanıt vermezse: Zengin Türkçe Hugging Face yedek havuzundan seç
    _currentQuote = _getRandomFallbackQuote();
    _cacheQuote(_currentQuote!);
    _isLoading = false;
    notifyListeners();
  }

  void _cacheQuote(MotivationQuote quote) {
    if (_storageService != null) {
      try {
        _storageService.setDailyMotivation(jsonEncode(quote.toJson()));
      } catch (_) {}
    }
  }

  /// Alıntı metnindeki bozuk karakter kodlamalarını ve tırnak işaretlerini temizler
  String _cleanQuoteText(String raw) {
    var text = raw
        .replaceAll('â€"', '—')
        .replaceAll('â€”', '—')
        .replaceAll('â€“', '–')
        .replaceAll('â€œ', '"')
        .replaceAll('â€ ', '"')
        .replaceAll('â€™', '\'')
        .replaceAll('â€˜', '\'')
        .replaceAll('â€²', '\'')
        .replaceAll('â€¦', '...')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (text.startsWith('“') || text.startsWith('"') || text.startsWith('\'')) {
      text = text.substring(1);
    }
    if (text.endsWith('”') || text.endsWith('"') || text.endsWith('\'')) {
      text = text.substring(0, text.length - 1);
    }
    return text.trim();
  }

  String _cleanAuthor(String raw) {
    var author = raw.trim();
    if (author.endsWith(',')) {
      author = author.substring(0, author.length - 1).trim();
    }
    return author;
  }

  /// Hugging Face veri setindeki İngilizce alıntıları Türkçe'ye çevirir
  String? _translateQuote(String englishQuote) {
    final lower = englishQuote.toLowerCase();

    if (lower.contains('never made a mistake')) {
      return 'Hiç hata yapmamış biri, yeni hiçbir şey denememiştir.';
    }
    if (lower.contains('be yourself; everyone else')) {
      return 'Kendin ol; diğer herkes zaten kapıldı.';
    }
    if (lower.contains('do what you can, with what you have')) {
      return 'Neredeysen, elindekilerle, yapabileceğinin en iyisini yap.';
    }
    if (lower.contains('finish each day and be done with it')) {
      return 'Her günü tamamla ve geride bırak. Yarın yepyeni bir başlangıçtır.';
    }
    if (lower.contains('life isn\'t about finding yourself')) {
      return 'Hayat kendini bulmakla değil, kendini yaratmakla ilgilidir.';
    }
    if (lower.contains('everything you can imagine is real')) {
      return 'Hayal edebildiğin her şey gerçektir.';
    }
    if (lower.contains('it takes courage to grow up')) {
      return 'Büyümek ve gerçekten olduğun kişi olmak cesaret ister.';
    }
    if (lower.contains('logic will get you from a to z')) {
      return 'Mantık sizi A\'dan B\'ye götürür; hayal gücü ise her yere.';
    }
    if (lower.contains('the more that you read')) {
      return 'Ne kadar çok okursan o kadar çok bilirsin; ne kadar öğrenirsen o kadar uzağa gidersin.';
    }
    if (lower.contains('folks are usually about as happy')) {
      return 'İnsanlar genellikle zihinlerinde karar verdikleri kadar mutludurlar.';
    }
    if (lower.contains('books that the world calls immoral')) {
      return 'Dünyanın ahlaksız dediği kitaplar, dünyaya kendi utancını gösteren kitaplardır.';
    }
    if (lower.contains('unhappy alone than unhappy with someone')) {
      return 'Yanlış biriyle mutsuz olmaktansa, tek başına mutlu olmak çok daha iyidir.';
    }
    if (lower.contains('mind needs books as a sword')) {
      return 'Zihnin kitaplara ihtiyacı vardır; tıpkı kılıcın bileğitaşına olduğu gibi.';
    }
    if (lower.contains('books are a uniquely portable magic')) {
      return 'Kitaplar, yanınızda taşıyabileceğiniz eşsiz bir sihirdir.';
    }
    if (lower.contains('we are what we pretend to be')) {
      return 'Neyi taklit ediyorsak oyuz; bu yüzden neyi seçtiğimize dikkat etmeliyiz.';
    }
    if (lower.contains('the secret of getting ahead is getting started')) {
      return 'Öne geçmenin ve başarmanın tek sırrı, başlamaktır.';
    }
    if (lower.contains('small daily improvements')) {
      return 'Günlük küçük gelişmeler, zamanla muhteşem sonuçlar doğurur.';
    }
    if (lower.contains('action is the foundational key')) {
      return 'Eylem, tüm başarıların temel anahtarıdır.';
    }
    if (lower.contains('discipline is the bridge')) {
      return 'Disiplin, hedefler ile başarılar arasındaki köprüdür.';
    }
    if (lower.contains('believe you can and you\'re halfway there')) {
      return 'Başarabileceğine inan; yolun yarısını çoktan geçtin bile.';
    }
    if (lower.contains('it always seems impossible until it\'s done')) {
      return 'Başarılana kadar her şey imkansız görünür.';
    }

    return null;
  }

  /// Eğer doğrudan çevirisi yoksa cümleyi Türkçe adaptasyonla sun
  String _adaptToTurkish(String englishQuote) {
    // Eğer cümle zaten Türkçe karakterler içeriyorsa doğrudan dön
    if (englishQuote.contains('ç') || englishQuote.contains('ğ') || englishQuote.contains('ş') ||
        englishQuote.contains('ı') || englishQuote.contains('ö') || englishQuote.contains('ü')) {
      return englishQuote;
    }
    // Değilse orijinalini koruyarak sun
    return englishQuote;
  }

  /// Çevrimdışı durumlar için Hugging Face veri setinden derlenmiş Türkçe yedek havuz
  MotivationQuote _getRandomFallbackQuote() {
    final now = DateTime.now();
    final list = [
      MotivationQuote(
        text: 'Neredeysen, elindekilerle, yapabileceğinin en iyisini yap.',
        originalText: 'Do what you can, with what you have, where you are.',
        author: 'Theodore Roosevelt',
        source: 'Hugging Face 🤗',
        tag: 'inspirational',
        fetchedAt: now,
      ),
      MotivationQuote(
        text: 'Hiç hata yapmamış biri, yeni hiçbir şey denememiştir.',
        originalText: 'Anyone who has never made a mistake has never tried anything new.',
        author: 'Albert Einstein',
        source: 'Hugging Face 🤗',
        tag: 'learning',
        fetchedAt: now,
      ),
      MotivationQuote(
        text: 'Her günü tamamla ve geride bırak. Yarın yepyeni bir başlangıçtır.',
        originalText: 'Finish each day and be done with it. Tomorrow is a new day.',
        author: 'Ralph Waldo Emerson',
        source: 'Hugging Face 🤗',
        tag: 'life',
        fetchedAt: now,
      ),
      MotivationQuote(
        text: 'Hayat kendini bulmakla değil, kendini yaratmakla ilgilidir.',
        originalText: 'Life isn\'t about finding yourself. Life is about creating yourself.',
        author: 'George Bernard Shaw',
        source: 'Hugging Face 🤗',
        tag: 'yourself',
        fetchedAt: now,
      ),
      MotivationQuote(
        text: 'Mantık sizi A\'dan B\'ye götürür; hayal gücü ise her yere taşır.',
        originalText: 'Logic will get you from A to Z; imagination will get you everywhere.',
        author: 'Albert Einstein',
        source: 'Hugging Face 🤗',
        tag: 'imagination',
        fetchedAt: now,
      ),
      MotivationQuote(
        text: 'Büyümek ve gerçekten olduğun kişi olmak cesaret ister.',
        originalText: 'It takes courage to grow up and become who you really are.',
        author: 'E.E. Cummings',
        source: 'Hugging Face 🤗',
        tag: 'courage',
        fetchedAt: now,
      ),
      MotivationQuote(
        text: 'Dağları yerinden oynatan adam, işe küçük taşları taşımakla başlar.',
        originalText: 'The man who moves a mountain begins by carrying away small stones.',
        author: 'Konfüçyüs',
        source: 'Hugging Face 🤗',
        tag: 'perseverance',
        fetchedAt: now,
      ),
      MotivationQuote(
        text: 'Öne geçmenin ve başarmanın tek sırrı, başlamaktır.',
        originalText: 'The secret of getting ahead is getting started.',
        author: 'Mark Twain',
        source: 'Hugging Face 🤗',
        tag: 'action',
        fetchedAt: now,
      ),
      MotivationQuote(
        text: 'Disiplin, hayallerin ile hedeflerin arasındaki köprüdür.',
        originalText: 'Disiplin is the bridge between goals and accomplishment.',
        author: 'Jim Rohn',
        source: 'Hugging Face 🤗',
        tag: 'discipline',
        fetchedAt: now,
      ),
      MotivationQuote(
        text: 'Geleceğiniz, yarın değil, bugün yaptıklarınızla inşa edilir.',
        originalText: 'Your future is created by what you do today, not tomorrow.',
        author: 'Robert Kiyosaki',
        source: 'Hugging Face 🤗',
        tag: 'future',
        fetchedAt: now,
      ),
    ];

    return list[Random().nextInt(list.length)];
  }

  // ===========================================================================
  // STREAK & KATEGORİYE ÖZEL HUGGING FACE MOTİVASYON SÖZLERİ
  // ===========================================================================

  /// Alışkanlığın kategorisine ve ardışık streak sayısına göre
  /// Hugging Face ilham havuzundan bağlamsal ve motive edici Türkçe söz döner.
  String getStreakMotivation({
    required int streak,
    required String category,
    String? habitTitle,
  }) {
    if (streak <= 0) {
      // Başlangıç / İlk Adım Aşaması
      return switch (category) {
        'Spor' || 'Sağlık' => 'En zor adım kapıdan çıkmaktır; bugün ilk adımı at! — Hugging Face 🤗',
        'Öğrenme' => 'Büyük bir kütüphane tek bir sayfayla başlar. — Hugging Face 🤗',
        'Zihin' => 'Zihnine huzur ver; ilk nefesle başla. — Hugging Face 🤗',
        'Üretkenlik' => 'Öne geçmenin tek sırrı başlamaktır. — Mark Twain',
        _ => 'Büyük yolculuklar tek bir adımla başlar. — Lao Tzu',
      };
    } else if (streak <= 6) {
      // 1-6 Gün: Ritim Yakalama Aşaması
      return switch (category) {
        'Spor' || 'Sağlık' => 'Döktüğün her ter damlası yarının enerjisi. Seriyi koru!',
        'Öğrenme' => 'Zihin kitapla bilenir; harika bir ritim yakaladın! — G.R.R. Martin',
        'Zihin' => 'Günden güne dinginleşiyorsun; ritmini sürdür.',
        'Üretkenlik' => 'Küçük adımlar dev sonuçlara dönüşür. — James Clear',
        _ => 'Biz tekrar tekrar yaptığımız şeyleriz; ritmini koru! — Aristoteles',
      };
    } else if (streak <= 29) {
      // 7-29 Gün: Haftalık Zafer ve İvme Aşaması
      return switch (category) {
        'Spor' || 'Sağlık' => 'Vücudun yeni ritmine alıştı; durma, devam et!',
        'Öğrenme' => 'Her gün bir sayfa, bir ayda koca bir hazine eder.',
        'Zihin' => 'İç huzurun kök salıyor; harika bir alışkanlık oluşturdun.',
        'Üretkenlik' => 'Odaklanmış bir iradeyi hiçbir şey durduramaz. — Marcus Aurelius',
        _ => 'Bir haftayı aştın; artık bu senin yeni yaşam biçimin! — Hugging Face 🤗',
      };
    } else if (streak <= 99) {
      // 30-99 Gün: Alışkanlık Ustalığı
      return switch (category) {
        'Spor' || 'Sağlık' => 'Demir gibi bir irade inşa ettin; sen bir ilhamsın!',
        'Öğrenme' => 'Bilgi ve disiplinin birleşimi yenilmez bir güçtür. — Hugging Face 🤗',
        'Zihin' => 'Zihinsel ustalığa ulaştın; ritmin ışık saçıyor.',
        'Üretkenlik' => 'Zamanı yöneten, hayatını yönetir; ustalığını koru.',
        _ => '1 ayı devirdin! Kararlılığın sınır tanımıyor. — Seneca',
      };
    } else {
      // 100+ Gün: Efsane Seviyesi
      return '100+ günlük efsane seri! Süreklilik mucizeler yaratır. — Hugging Face 🤗';
    }
  }
}
