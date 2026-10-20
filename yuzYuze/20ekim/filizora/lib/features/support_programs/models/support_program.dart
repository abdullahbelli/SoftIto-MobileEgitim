/// Girişimcilik Destek Programı Modeli (KOSGEB, TÜBİTAK vb.)
class SupportProgram {
  final String id;
  final String title;
  final String institution;
  final String amountLimit;
  final String summary;
  final String category;
  final String deadline;
  final bool isSaved;
  final String eligibility;
  final bool isApplied;
  final String? applicationStatus;
  final DateTime? applicationDate;
  final String? projectTitle;
  final String? requestedAmount;

  const SupportProgram({
    required this.id,
    required this.title,
    required this.institution,
    required this.amountLimit,
    required this.summary,
    required this.category,
    required this.deadline,
    this.isSaved = false,
    required this.eligibility,
    this.isApplied = false,
    this.applicationStatus,
    this.applicationDate,
    this.projectTitle,
    this.requestedAmount,
  });

  SupportProgram copyWith({
    String? id,
    String? title,
    String? institution,
    String? amountLimit,
    String? summary,
    String? category,
    String? deadline,
    bool? isSaved,
    String? eligibility,
    bool? isApplied,
    String? applicationStatus,
    DateTime? applicationDate,
    String? projectTitle,
    String? requestedAmount,
  }) {
    return SupportProgram(
      id: id ?? this.id,
      title: title ?? this.title,
      institution: institution ?? this.institution,
      amountLimit: amountLimit ?? this.amountLimit,
      summary: summary ?? this.summary,
      category: category ?? this.category,
      deadline: deadline ?? this.deadline,
      isSaved: isSaved ?? this.isSaved,
      eligibility: eligibility ?? this.eligibility,
      isApplied: isApplied ?? this.isApplied,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      applicationDate: applicationDate ?? this.applicationDate,
      projectTitle: projectTitle ?? this.projectTitle,
      requestedAmount: requestedAmount ?? this.requestedAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'institution': institution,
      'amountLimit': amountLimit,
      'summary': summary,
      'category': category,
      'deadline': deadline,
      'isSaved': isSaved,
      'eligibility': eligibility,
      'isApplied': isApplied,
      'applicationStatus': applicationStatus,
      'applicationDate': applicationDate?.toIso8601String(),
      'projectTitle': projectTitle,
      'requestedAmount': requestedAmount,
    };
  }

  factory SupportProgram.fromJson(Map<String, dynamic> json) {
    return SupportProgram(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      institution: json['institution'] as String? ?? '',
      amountLimit: json['amountLimit'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      category: json['category'] as String? ?? '',
      deadline: json['deadline'] as String? ?? '',
      isSaved: json['isSaved'] as bool? ?? false,
      eligibility: json['eligibility'] as String? ?? '',
      isApplied: json['isApplied'] as bool? ?? false,
      applicationStatus: json['applicationStatus'] as String?,
      applicationDate: json['applicationDate'] != null
          ? DateTime.tryParse(json['applicationDate'] as String)
          : null,
      projectTitle: json['projectTitle'] as String?,
      requestedAmount: json['requestedAmount'] as String?,
    );
  }
}
