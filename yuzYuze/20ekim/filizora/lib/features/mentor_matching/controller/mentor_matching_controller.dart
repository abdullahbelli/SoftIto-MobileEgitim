import 'package:flutter/foundation.dart';
import '../models/match_request.dart';
import '../models/mentor.dart';

/// Mentor-Menti Eşleşmesi ve Yatırımcı İstekleri Durum Yöneticisi
class MentorMatchingController {
  final ValueNotifier<List<Mentor>> mentors;
  final ValueNotifier<String?> selectedExpertise;
  final ValueNotifier<List<MatchRequest>> matchRequests;

  static final List<Mentor> _defaultMentors = [
    const Mentor(
      id: 'm1',
      name: 'Dr. Ahmet Yılmaz',
      title: 'Kıdemli Yatırım Danışmanı & Girişim Mentoru',
      company: 'TechVentures Studio',
      expertise: 'Yatırım & Finans',
      rating: 4.9,
      bio: 'Erken aşama B2B SaaS girişimlerine tohum yatırım ve finansal modelleme mentörlüğü.',
    ),
    const Mentor(
      id: 'm2',
      name: 'Selin Kaya',
      title: 'Ürün ve Büyüme (Growth) Lideri',
      company: 'AppGrowth Co.',
      expertise: 'Ürün Yönetimi',
      rating: 4.8,
      bio: 'Kullanıcı edinimi, ürün-pazar uyumu (PMF) ve ölçeklenme stratejileri uzmanı.',
    ),
    const Mentor(
      id: 'm3',
      name: 'Burak Demir',
      title: 'CTO & Yapay Zekâ Mühendisi',
      company: 'DeepMindLabs',
      expertise: 'Yapay Zekâ & Tech',
      rating: 5.0,
      bio: 'Yapay zekâ mimarileri, bulut çözümleri ve MVP geliştirme süreçlerinde mentor.',
    ),
    const Mentor(
      id: 'm4',
      name: 'Av. Elif Şahin',
      title: 'Girişim Hukuku ve Fikri Mülkiyet Uzmanı',
      company: 'LexTech Danışmanlık',
      expertise: 'Hukuk & Şirketleşme',
      rating: 4.7,
      bio: 'Şirket kuruluşu, ortaklık sözleşmeleri ve patent/marka tescil danışmanlığı.',
    ),
  ];

  static final List<MatchRequest> _defaultRequests = [
    MatchRequest(
      id: 'req_1',
      mentorId: 'm1',
      mentorName: 'Dr. Ahmet Yılmaz',
      entrepreneurId: 'usr_init_1',
      entrepreneurName: 'Zeynep Aksoy',
      ideaTitle: 'AgriSense — Akıllı Tarım Sensörleri',
      ideaSector: 'AgriTech & IoT',
      message: 'Erken aşama sensör prototipimiz hazır. Tohum yatırım ve ticarileşme için mentorluk talep ediyoruz.',
      status: MatchRequestStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    MatchRequest(
      id: 'req_2',
      mentorId: 'm1',
      mentorName: 'Dr. Ahmet Yılmaz',
      entrepreneurId: 'usr_init_2',
      entrepreneurName: 'Canberk Yıldız',
      ideaTitle: 'FinFlow — KOBİ Nakit Akışı Yönetimi',
      ideaSector: 'FinTech',
      message: 'Banka entegrasyonlarımız tamamlandı. Yatırım turu öncesi finansal modelleme desteği rica ediyoruz.',
      status: MatchRequestStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  MentorMatchingController({
    List<Mentor>? initialMentors,
    List<MatchRequest>? initialRequests,
  })  : mentors = ValueNotifier<List<Mentor>>(initialMentors ?? _defaultMentors),
        selectedExpertise = ValueNotifier<String?>(null),
        matchRequests = ValueNotifier<List<MatchRequest>>(initialRequests ?? _defaultRequests);

  List<Mentor> get filteredMentors {
    final exp = selectedExpertise.value;
    if (exp == null || exp.isEmpty) {
      return mentors.value;
    }
    return mentors.value.where((m) => m.expertise == exp).toList();
  }

  /// Bekleyen istekler (Yatırımcı paneli için)
  List<MatchRequest> get pendingRequests {
    return matchRequests.value.where((r) => r.isPending).toList();
  }

  /// Kabul edilmiş istekler
  List<MatchRequest> get acceptedRequests {
    return matchRequests.value.where((r) => r.isAccepted).toList();
  }

  void filterByExpertise(String? expertise) {
    selectedExpertise.value = expertise;
  }

  /// Girişimcinin mentöre eşleşme isteği göndermesi
  void sendMatchRequest({
    required String mentorId,
    required String entrepreneurName,
    required String ideaTitle,
    String? ideaSector,
    String? message,
    String? entrepreneurId,
  }) {
    final mentor = mentors.value.firstWhere(
      (m) => m.id == mentorId,
      orElse: () => mentors.value.first,
    );

    _updateMentorMatched(mentorId, true);

    final newRequest = MatchRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      mentorId: mentorId,
      mentorName: mentor.name,
      entrepreneurId: entrepreneurId ?? 'current_usr',
      entrepreneurName: entrepreneurName.isNotEmpty ? entrepreneurName : 'Filizora Girişimcisi',
      ideaTitle: ideaTitle.isNotEmpty ? ideaTitle : 'Yenilikçi Girişim Projesi',
      ideaSector: ideaSector ?? mentor.expertise,
      message: message ?? 'Girişimim hakkında görüşmek ve mentorluk/yatırım desteği almak istiyorum.',
      status: MatchRequestStatus.pending,
      createdAt: DateTime.now(),
    );

    matchRequests.value = [newRequest, ...matchRequests.value];
  }

  /// Yatırımcının isteği kabul etmesi
  void acceptMatchRequest(String requestId) {
    matchRequests.value = matchRequests.value.map((req) {
      if (req.id == requestId) {
        _updateMentorMatched(req.mentorId, true);
        return req.copyWith(status: MatchRequestStatus.accepted);
      }
      return req;
    }).toList();
  }

  /// Yatırımcının isteği reddetmesi
  void declineMatchRequest(String requestId) {
    matchRequests.value = matchRequests.value.map((req) {
      if (req.id == requestId) {
        return req.copyWith(status: MatchRequestStatus.declined);
      }
      return req;
    }).toList();
  }

  /// Mentörün eşleşme durumunu güncelle
  void _updateMentorMatched(String mentorId, bool isMatched) {
    mentors.value = mentors.value.map((m) {
      if (m.id == mentorId) {
        return m.copyWith(isMatched: isMatched);
      }
      return m;
    }).toList();
  }

  /// Geleneksel toggle desteği (test uyumluluğu için)
  void toggleMatch(String mentorId) {
    final mentor = mentors.value.firstWhere(
      (m) => m.id == mentorId,
      orElse: () => mentors.value.first,
    );
    final targetMatched = !mentor.isMatched;
    _updateMentorMatched(mentorId, targetMatched);

    if (targetMatched) {
      final newRequest = MatchRequest(
        id: 'req_${DateTime.now().millisecondsSinceEpoch}',
        mentorId: mentorId,
        mentorName: mentor.name,
        entrepreneurId: 'current_usr',
        entrepreneurName: 'Girişimci',
        ideaTitle: 'İş Fikri',
        ideaSector: mentor.expertise,
        status: MatchRequestStatus.pending,
        createdAt: DateTime.now(),
      );
      matchRequests.value = [newRequest, ...matchRequests.value];
    } else {
      matchRequests.value = matchRequests.value.where((r) => r.mentorId != mentorId).toList();
    }
  }

  void dispose() {
    mentors.dispose();
    selectedExpertise.dispose();
    matchRequests.dispose();
  }
}
