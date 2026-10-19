class WorkoutEntry {
  const WorkoutEntry({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.burnedCalories,
    required this.timestamp,
  });

  final String id;
  final String title;
  final int durationMinutes;
  final int burnedCalories;
  final DateTime timestamp;
}
