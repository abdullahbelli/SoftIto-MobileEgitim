import 'package:flutter/foundation.dart';
import '../models/community_post.dart';

/// Girişimci Topluluk Akışı Durum Yöneticisi
class CommunityController {
  final ValueNotifier<List<CommunityPost>> posts;

  static final List<CommunityPost> _initialPosts = [
    CommunityPost(
      id: 'p1',
      authorName: 'Zeynep Aktaş',
      authorTitle: 'EcoTech Kurucu Ortak',
      content:
          'KOSGEB Ar-Ge ve İnovasyon desteği için jüri sunumumuzu dün tamamladık! Donanım prototipi geliştirirken en çok dikkat edilen kriter test metrikleriydi. Benzer aşamadaki arkadaşlara deneyimlerimi aktarabilirim.',
      tag: 'KOSGEB Deneyimi',
      likesCount: 14,
      commentsCount: 5,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    CommunityPost(
      id: 'p2',
      authorName: 'Mert Erdem',
      authorTitle: 'SaaS Girişimcisi',
      content:
          'İlk 100 aktif B2B müşteriye ulaşırken soğuk e-posta (cold outreach) yerine LinkedIn topluluk paylaşımları 3 kat daha yüksek dönüşüm sağladı. Organik içerik stratejisi harika çalışıyor.',
      tag: 'Büyüme & Pazarlama',
      likesCount: 28,
      commentsCount: 9,
      createdAt: DateTime.now().subtract(const Duration(hours: 7)),
    ),
    CommunityPost(
      id: 'p3',
      authorName: 'Canan Güneş',
      authorTitle: 'HealthAI Kurucusu',
      content:
          'Yapay zekâ tabanlı sağlık projemiz için tıbbi veri regülasyonu ve KVKK uyumluluğu konusunda deneyimli bir mentor arıyoruz. Mentor eşleşmesinden tavsiye edebileceğiniz isimler var mı?',
      tag: 'Mentorluk & Destek',
      likesCount: 9,
      commentsCount: 3,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  CommunityController({List<CommunityPost>? initialPosts})
      : posts = ValueNotifier<List<CommunityPost>>(initialPosts ?? _initialPosts);

  void addPost({
    required String authorName,
    required String authorTitle,
    required String content,
    required String tag,
  }) {
    if (content.trim().isEmpty) return;

    final newPost = CommunityPost(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      authorName: authorName.trim().isEmpty ? 'Girişimci' : authorName.trim(),
      authorTitle: authorTitle.trim().isEmpty ? 'Topluluk Üyesi' : authorTitle.trim(),
      content: content.trim(),
      tag: tag.trim().isEmpty ? 'Genel' : tag.trim(),
      createdAt: DateTime.now(),
    );

    posts.value = [newPost, ...posts.value];
  }

  void toggleLike(String postId) {
    posts.value = posts.value.map((p) {
      if (p.id == postId) {
        final newIsLiked = !p.isLiked;
        final newCount = newIsLiked ? p.likesCount + 1 : p.likesCount - 1;
        return p.copyWith(
          isLiked: newIsLiked,
          likesCount: newCount < 0 ? 0 : newCount,
        );
      }
      return p;
    }).toList();
  }

  void dispose() {
    posts.dispose();
  }
}
