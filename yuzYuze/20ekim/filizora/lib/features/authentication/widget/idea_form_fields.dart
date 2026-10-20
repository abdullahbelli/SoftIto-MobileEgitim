import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';

/// "İş Fikrim Var" Seçildiğinde Gösterilen Form Alanları
class IdeaFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController sectorController;
  final TextEditingController descriptionController;

  const IdeaFormFields({
    super.key,
    required this.titleController,
    required this.sectorController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.neonCyan.withAlpha(50),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.neonCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'İş Fikri Bilgileri',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.neonCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _FieldLabel(text: 'İş Fikrinin Adı / Başlığı'),
          const SizedBox(height: 6),
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(
              hintText: 'Örn: Akıllı Tarım Sensörleri',
              prefixIcon: Icon(Icons.title_rounded, size: 20),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          _FieldLabel(text: 'Sektör'),
          const SizedBox(height: 6),
          TextFormField(
            controller: sectorController,
            decoration: const InputDecoration(
              hintText: 'Örn: Tarım Teknolojileri, FinTech, Sağlık',
              prefixIcon: Icon(Icons.category_outlined, size: 20),
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          _FieldLabel(text: 'Kısa Açıklama'),
          const SizedBox(height: 6),
          TextFormField(
            controller: descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Çözdüğünüz problem, hedef kitle ve çözümünüz...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
