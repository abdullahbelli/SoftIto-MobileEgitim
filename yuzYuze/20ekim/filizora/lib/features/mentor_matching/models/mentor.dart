/// Mentor Bilgisi Modeli
class Mentor {
  final String id;
  final String name;
  final String title;
  final String company;
  final String expertise;
  final double rating;
  final bool isAvailable;
  final bool isMatched;
  final String bio;

  const Mentor({
    required this.id,
    required this.name,
    required this.title,
    required this.company,
    required this.expertise,
    required this.rating,
    this.isAvailable = true,
    this.isMatched = false,
    required this.bio,
  });

  Mentor copyWith({
    String? id,
    String? name,
    String? title,
    String? company,
    String? expertise,
    double? rating,
    bool? isAvailable,
    bool? isMatched,
    String? bio,
  }) {
    return Mentor(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      company: company ?? this.company,
      expertise: expertise ?? this.expertise,
      rating: rating ?? this.rating,
      isAvailable: isAvailable ?? this.isAvailable,
      isMatched: isMatched ?? this.isMatched,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'company': company,
      'expertise': expertise,
      'rating': rating,
      'isAvailable': isAvailable,
      'isMatched': isMatched,
      'bio': bio,
    };
  }

  factory Mentor.fromJson(Map<String, dynamic> json) {
    return Mentor(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      company: json['company'] as String? ?? '',
      expertise: json['expertise'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      isAvailable: json['isAvailable'] as bool? ?? true,
      isMatched: json['isMatched'] as bool? ?? false,
      bio: json['bio'] as String? ?? '',
    );
  }
}
