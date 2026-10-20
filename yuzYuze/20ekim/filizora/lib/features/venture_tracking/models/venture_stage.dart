/// Girişim Aşamasındaki Alt Görev Modeli
class VentureTask {
  final String id;
  final String title;
  final bool isDone;

  const VentureTask({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  VentureTask copyWith({String? id, String? title, bool? isDone}) {
    return VentureTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'isDone': isDone};
  }

  factory VentureTask.fromJson(Map<String, dynamic> json) {
    return VentureTask(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      isDone: json['isDone'] as bool? ?? false,
    );
  }
}

/// Girişim Süreç Aşaması Modeli (Gantt Şeması ve Süreç Takibi Desteği ile)
class VentureStage {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final bool isCurrent;
  final List<VentureTask> tasks;
  final int startWeek;
  final int endWeek;
  final String duration;

  const VentureStage({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.isCurrent = false,
    this.tasks = const [],
    this.startWeek = 1,
    this.endWeek = 4,
    this.duration = '4 Hafta',
  });

  int get completedTasksCount => tasks.where((t) => t.isDone).length;
  double get progress => tasks.isEmpty ? (isCompleted ? 1.0 : 0.0) : (completedTasksCount / tasks.length);

  VentureStage copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    bool? isCurrent,
    List<VentureTask>? tasks,
    int? startWeek,
    int? endWeek,
    String? duration,
  }) {
    return VentureStage(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      isCurrent: isCurrent ?? this.isCurrent,
      tasks: tasks ?? this.tasks,
      startWeek: startWeek ?? this.startWeek,
      endWeek: endWeek ?? this.endWeek,
      duration: duration ?? this.duration,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'isCurrent': isCurrent,
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'startWeek': startWeek,
      'endWeek': endWeek,
      'duration': duration,
    };
  }

  factory VentureStage.fromJson(Map<String, dynamic> json) {
    return VentureStage(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      isCurrent: json['isCurrent'] as bool? ?? false,
      startWeek: json['startWeek'] as int? ?? 1,
      endWeek: json['endWeek'] as int? ?? 4,
      duration: json['duration'] as String? ?? '4 Hafta',
      tasks: (json['tasks'] as List<dynamic>?)
              ?.map((e) => VentureTask.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Girişimcinin Takip Ettiği İş Olanakları ve Fırsatlar
class BusinessOpportunity {
  final String id;
  final String title;
  final String source;
  final String potentialValue;
  final String status;

  const BusinessOpportunity({
    required this.id,
    required this.title,
    required this.source,
    required this.potentialValue,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'source': source,
      'potentialValue': potentialValue,
      'status': status,
    };
  }

  factory BusinessOpportunity.fromJson(Map<String, dynamic> json) {
    return BusinessOpportunity(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      source: json['source'] as String? ?? '',
      potentialValue: json['potentialValue'] as String? ?? '',
      status: json['status'] as String? ?? 'Görüşülüyor',
    );
  }
}
