import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../models/support_program.dart';
import 'application_dialog.dart';

/// Destek Programı Kartı (Başvuru Yapma ve Kaydetme Desteği ile)
class ProgramCard extends StatelessWidget {
  final SupportProgram program;
  final VoidCallback onToggleSave;
  final Function(String projectTitle, String requestedAmount) onApply;
  final VoidCallback? onCancelApplication;

  const ProgramCard({
    super.key,
    required this.program,
    required this.onToggleSave,
    required this.onApply,
    this.onCancelApplication,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProgramHeader(program: program, onToggleSave: onToggleSave),
            const SizedBox(height: 10),
            Text(
              program.summary,
              style: context.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondary
                    : AppColors.textLightSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _ProgramDetailRow(program: program),
            const SizedBox(height: 14),
            _ProgramActionRow(
              program: program,
              onApply: () {
                ApplicationDialog.show(
                  context,
                  program: program,
                  onSubmit: onApply,
                );
              },
              onCancelApplication: onCancelApplication,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgramHeader extends StatelessWidget {
  final SupportProgram program;
  final VoidCallback onToggleSave;

  const _ProgramHeader({
    required this.program,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.oceanBlue.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.account_balance_rounded, color: AppColors.oceanBlue, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                program.title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${program.institution} • ${program.category}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            program.isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: program.isSaved ? AppColors.amber : AppColors.textSecondary,
          ),
          onPressed: onToggleSave,
        ),
      ],
    );
  }
}

class _ProgramDetailRow extends StatelessWidget {
  final SupportProgram program;
  const _ProgramDetailRow({required this.program});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.obsidianSurface : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.obsidianBorder : AppColors.lightBorder,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.payments_outlined, size: 16, color: AppColors.teal),
              const SizedBox(width: 6),
              Text(
                program.amountLimit,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.teal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.event_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                program.deadline,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgramActionRow extends StatelessWidget {
  final SupportProgram program;
  final VoidCallback onApply;
  final VoidCallback? onCancelApplication;

  const _ProgramActionRow({
    required this.program,
    required this.onApply,
    this.onCancelApplication,
  });

  @override
  Widget build(BuildContext context) {
    if (program.isApplied) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.teal.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.teal.withAlpha(80)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Başvurunuz Alındı (${program.applicationStatus ?? 'Değerlendirmede'})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.teal,
                    ),
                  ),
                  if (program.projectTitle != null && program.projectTitle!.isNotEmpty)
                    Text(
                      'Proje: ${program.projectTitle}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (onCancelApplication != null)
              TextButton(
                onPressed: onCancelApplication,
                child: const Text('İptal Et', style: TextStyle(fontSize: 11, color: AppColors.red)),
              ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onApply,
        icon: const Icon(Icons.send_rounded, size: 16),
        label: const Text('Destek Programına Başvuru Yap', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
