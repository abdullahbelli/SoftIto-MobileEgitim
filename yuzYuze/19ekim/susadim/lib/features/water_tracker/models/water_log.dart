class WaterLog {
  const WaterLog({
    required this.id,
    required this.amountMl,
    required this.timestamp,
    this.label = 'Su',
  });

  final String id;
  final int amountMl;
  final DateTime timestamp;
  final String label;
}
