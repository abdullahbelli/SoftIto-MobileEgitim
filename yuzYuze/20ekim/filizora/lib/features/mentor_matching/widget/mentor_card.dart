import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../models/mentor.dart';

/// Mentor Bilgi ve Eşleşme Kartı
class MentorCard extends StatelessWidget {
  final Mentor mentor;
  final VoidCallback onToggleMatch;

  const MentorCard({
    super.key,
    required this.mentor,
    required this.onToggleMatch,
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
            _MentorHeader(mentor: mentor),
            const SizedBox(height: 10),
            Text(
              mentor.bio,
              style: context.textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondary
                    : AppColors.textLightSecondary,
              ),
            ),
            const SizedBox(height: 14),
            _MentorFooter(mentor: mentor, onToggleMatch: onToggleMatch),
          ],
        ),
      ),
    );
  }
}

class _MentorHeader extends StatelessWidget {
  final Mentor mentor;
  const _MentorHeader({required this.mentor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.oceanBlue.withAlpha(30),
          child: Text(
            mentor.name.substring(0, 1),
            style: const TextStyle(
              color: AppColors.oceanBlue,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                mentor.name,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${mentor.title} • ${mentor.company}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        _RatingBadge(rating: mentor.rating),
      ],
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.amber.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 16, color: AppColors.amber),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.amber,
            ),
          ),
        ],
      ),
    );
  }
}

class _MentorFooter extends StatelessWidget {
  final Mentor mentor;
  final VoidCallback onToggleMatch;

  const _MentorFooter({
    required this.mentor,
    required this.onToggleMatch,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.teal.withAlpha(25),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            mentor.expertise,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.teal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: mentor.isMatched ? AppColors.teal.withAlpha(35) : AppColors.orange,
            foregroundColor: mentor.isMatched ? AppColors.teal : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: onToggleMatch,
          icon: Icon(
            mentor.isMatched ? Icons.check_circle_rounded : Icons.person_add_alt_1_rounded,
            size: 18,
          ),
          label: Text(
            mentor.isMatched ? 'Eşleşildi' : 'Eşleşme İsteği',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
