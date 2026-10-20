import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../models/venture_stage.dart';

/// Girişim Süreçleri Gantt Şeması ve Zaman Çizelgesi Görünümü
class GanttChartView extends StatelessWidget {
  final List<VentureStage> stages;
  final Function(String stageId, String taskId)? onToggleTask;

  const GanttChartView({
    super.key,
    required this.stages,
    this.onToggleTask,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGanttSummary(context, isDark),
          const SizedBox(height: 20),
          _buildTimelineHeader(context, isDark),
          const SizedBox(height: 12),
          ...stages.map((stage) => _buildGanttStageRow(context, stage, isDark)),
          const SizedBox(height: 24),
          _buildGanttLegend(context, isDark),
        ],
      ),
    );
  }

  Widget _buildGanttSummary(BuildContext context, bool isDark) {
    final completedCount = stages.where((s) => s.isCompleted).length;
    final totalTasks = stages.fold<int>(0, (sum, s) => sum + s.tasks.length);
    final doneTasks = stages.fold<int>(0, (sum, s) => sum + s.completedTasksCount);
    final overallProgress = totalTasks == 0 ? 0.0 : doneTasks / totalTasks;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.waterfall_chart_rounded, color: AppColors.orange, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Girişim Yol Haritası & Gantt Şeması',
                  style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    label: 'Tamamlanan Faz',
                    value: '$completedCount / ${stages.length}',
                    color: AppColors.teal,
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Toplam Süre',
                    value: '20 Hafta',
                    color: AppColors.oceanBlue,
                  ),
                ),
                Expanded(
                  child: _buildMetricTile(
                    label: 'Genel İlerleme',
                    value: '%${(overallProgress * 100).toInt()}',
                    color: AppColors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: overallProgress,
                minHeight: 8,
                backgroundColor: isDark ? AppColors.obsidianBorder : AppColors.lightBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  Widget _buildTimelineHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.obsidianSurface : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              'Aşama / Hafta',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(child: Center(child: Text('H 1-4', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)))),
          Expanded(child: Center(child: Text('H 5-8', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)))),
          Expanded(child: Center(child: Text('H 9-12', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)))),
          Expanded(child: Center(child: Text('H 13-16', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)))),
          Expanded(child: Center(child: Text('H 17-20', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)))),
        ],
      ),
    );
  }

  Widget _buildGanttStageRow(BuildContext context, VentureStage stage, bool isDark) {
    final statusColor = stage.isCompleted
        ? AppColors.teal
        : (stage.isCurrent ? AppColors.orange : AppColors.amber);

    final statusText = stage.isCompleted
        ? 'Tamamlandı'
        : (stage.isCurrent ? 'Devam Ediyor' : 'Planlandı');

    const totalWeeks = 20.0;
    final leftFlex = ((stage.startWeek - 1) / totalWeeks * 100).toInt();
    final widthFlex = (((stage.endWeek - stage.startWeek + 1) / totalWeeks) * 100).toInt().clamp(10, 100);
    final rightFlex = (100 - (leftFlex + widthFlex)).clamp(0, 100);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.obsidianCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: stage.isCurrent ? statusColor : (isDark ? AppColors.obsidianBorder : AppColors.lightBorder),
          width: stage.isCurrent ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  stage.title,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: stage.isCurrent ? statusColor : null,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$statusText • %${(stage.progress * 100).toInt()}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            stage.duration,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          // Gantt Çubuğu
          Row(
            children: [
              if (leftFlex > 0) Spacer(flex: leftFlex),
              Expanded(
                flex: widthFlex,
                child: Container(
                  height: 22,
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(45),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor, width: 1.2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: stage.progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              if (rightFlex > 0) Spacer(flex: rightFlex),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGanttLegend(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Tamamlandı', AppColors.teal),
        const SizedBox(width: 16),
        _buildLegendItem('Aktif Süreç', AppColors.orange),
        const SizedBox(width: 16),
        _buildLegendItem('Planlanan', AppColors.amber),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
