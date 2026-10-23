/// Hugging Face Motivasyon Sözü Modeli.
/// Alıntı metni, yazar, Hugging Face veri seti kaynağı ve etiketleri barındırır.
class MotivationQuote {
  final String text;
  final String author;
  final String? originalText;
  final String source;
  final String? tag;
  final DateTime fetchedAt;

  const MotivationQuote({
    required this.text,
    required this.author,
    this.originalText,
    this.source = 'Hugging Face 🤗',
    this.tag,
    required this.fetchedAt,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'author': author,
        'originalText': originalText,
        'source': source,
        'tag': tag,
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory MotivationQuote.fromJson(Map<String, dynamic> json) => MotivationQuote(
        text: json['text'] as String,
        author: json['author'] as String? ?? 'Anonim',
        originalText: json['originalText'] as String?,
        source: json['source'] as String? ?? 'Hugging Face 🤗',
        tag: json['tag'] as String?,
        fetchedAt: json['fetchedAt'] != null
            ? DateTime.parse(json['fetchedAt'] as String)
            : DateTime.now(),
      );
}
