/// Eşleşme İsteği Durumu
enum MatchRequestStatus {
  pending,
  accepted,
  declined;

  String get displayName {
    switch (this) {
      case MatchRequestStatus.pending:
        return 'Beklemede';
      case MatchRequestStatus.accepted:
        return 'Kabul Edildi';
      case MatchRequestStatus.declined:
        return 'Reddedildi';
    }
  }
}

/// Girişimcinin Yatırımcıya/Mentöre Gönderdiği Eşleşme İsteği Modeli
class MatchRequest {
  final String id;
  final String mentorId;
  final String mentorName;
  final String entrepreneurId;
  final String entrepreneurName;
  final String ideaTitle;
  final String ideaSector;
  final String message;
  final MatchRequestStatus status;
  final DateTime createdAt;

  const MatchRequest({
    required this.id,
    required this.mentorId,
    required this.mentorName,
    required this.entrepreneurId,
    required this.entrepreneurName,
    required this.ideaTitle,
    required this.ideaSector,
    this.message = 'Girişimim hakkında görüşmek ve mentorluk/yatırım desteği almak istiyorum.',
    this.status = MatchRequestStatus.pending,
    required this.createdAt,
  });

  bool get isPending => status == MatchRequestStatus.pending;
  bool get isAccepted => status == MatchRequestStatus.accepted;
  bool get isDeclined => status == MatchRequestStatus.declined;

  MatchRequest copyWith({
    String? id,
    String? mentorId,
    String? mentorName,
    String? entrepreneurId,
    String? entrepreneurName,
    String? ideaTitle,
    String? ideaSector,
    String? message,
    MatchRequestStatus? status,
    DateTime? createdAt,
  }) {
    return MatchRequest(
      id: id ?? this.id,
      mentorId: mentorId ?? this.mentorId,
      mentorName: mentorName ?? this.mentorName,
      entrepreneurId: entrepreneurId ?? this.entrepreneurId,
      entrepreneurName: entrepreneurName ?? this.entrepreneurName,
      ideaTitle: ideaTitle ?? this.ideaTitle,
      ideaSector: ideaSector ?? this.ideaSector,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mentorId': mentorId,
      'mentorName': mentorName,
      'entrepreneurId': entrepreneurId,
      'entrepreneurName': entrepreneurName,
      'ideaTitle': ideaTitle,
      'ideaSector': ideaSector,
      'message': message,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MatchRequest.fromJson(Map<String, dynamic> json) {
    return MatchRequest(
      id: json['id'] as String? ?? '',
      mentorId: json['mentorId'] as String? ?? '',
      mentorName: json['mentorName'] as String? ?? '',
      entrepreneurId: json['entrepreneurId'] as String? ?? '',
      entrepreneurName: json['entrepreneurName'] as String? ?? '',
      ideaTitle: json['ideaTitle'] as String? ?? '',
      ideaSector: json['ideaSector'] as String? ?? '',
      message: json['message'] as String? ?? '',
      status: MatchRequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MatchRequestStatus.pending,
      ),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
