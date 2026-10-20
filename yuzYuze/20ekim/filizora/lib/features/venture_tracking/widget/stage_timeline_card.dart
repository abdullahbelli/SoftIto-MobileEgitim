import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../models/venture_stage.dart';

/// Girişim Süreç Aşaması Kartı (İlerleme çubuğu ve alt görev kontrol listesi ile)
class StageTimelineCard extends StatelessWidget {
  final VentureStage stage;
  final Function(String taskId) onToggleTask;

  const StageTimelineCard({
    super.key,
    required this.stage,
    required this.onToggleTask,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = stage.isCompleted
        ? AppColors.teal
        : (stage.isCurrent ? AppColors.orange : AppColors.amber);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StageCardHeader(stage: stage, statusColor: statusColor),
            const SizedBox(height: 8),
            Text(
              stage.description,
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _StageProgressBar(stage: stage, statusColor: statusColor),
            const SizedBox(height: 12),
            _TaskList(stage: stage, onToggleTask: onToggleTask),
          ],
        ),
      ),
    );
  }
}

class _StageCardHeader extends StatelessWidget {
  final VentureStage stage;
  final Color statusColor;

  const _StageCardHeader({
    required this.stage,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          stage.isCompleted
              ? Icons.check_circle_rounded
              : (stage.isCurrent ? Icons.play_circle_filled_rounded : Icons.radio_button_unchecked_rounded),
          color: statusColor,
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            stage.title,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: stage.isCurrent ? AppColors.orange : null,
            ),
          ),
        ),
        if (stage.isCurrent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.orange.withAlpha(30),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Aktif Aşama',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}

class _StageProgressBar extends StatelessWidget {
  final VentureStage stage;
  final Color statusColor;

  const _StageProgressBar({
    required this.stage,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tamamlanma: %${(stage.progress * 100).toInt()}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(
              '${stage.completedTasksCount}/${stage.tasks.length} Görev',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: stage.progress,
          color: statusColor,
          backgroundColor: isDark ? AppColors.obsidianBorder : AppColors.lightBorder,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }
}

class _TaskList extends StatelessWidget {
  final VentureStage stage;
  final Function(String taskId) onToggleTask;

  const _TaskList({
    required this.stage,
    required this.onToggleTask,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: stage.tasks.map((task) {
        return InkWell(
          onTap: () => onToggleTask(task.id),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
            child: Row(
              children: [
                Icon(
                  task.isDone ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                  color: task.isDone ? AppColors.teal : AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 13,
                      decoration: task.isDone ? TextDecoration.lineThrough : null,
                      color: task.isDone
                          ? AppColors.textSecondary
                          : (isDark ? AppColors.textPrimary : AppColors.textLightPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
