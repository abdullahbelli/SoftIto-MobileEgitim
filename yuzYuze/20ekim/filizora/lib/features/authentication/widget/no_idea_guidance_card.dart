import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';

/// "İş Fikrim Yok" seçildiğinde gösterilen yönlendirici rehber ve ilgi alanı kartı
class NoIdeaGuidanceCard extends StatefulWidget {
  final ValueChanged<List<String>>? onInterestsChanged;

  const NoIdeaGuidanceCard({
    super.key,
    this.onInterestsChanged,
  });

  @override
  State<NoIdeaGuidanceCard> createState() => _NoIdeaGuidanceCardState();
}

class _NoIdeaGuidanceCardState extends State<NoIdeaGuidanceCard> {
  final Set<String> _selectedInterests = {};

  final List<String> _interestOptions = const [
    'Yazılım & Yapay Zekâ',
    'E-Ticaret & Pazaryeri',
    'Sürdürülebilirlik & Yeşil Enerji',
    'FinTech & Finansal Çözümler',
    'Sağlık Teknolojileri',
    'Sosyal Girişimcilik',
    'Eğitim & EdTech',
    'Tarım & Gıda Teknolojisi',
  ];

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
    widget.onInterestsChanged?.call(_selectedInterests.toList());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? AppColors.obsidianCard : const Color(0xFFF0FDF4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? AppColors.teal.withAlpha(80) : AppColors.teal.withAlpha(120),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withAlpha(35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppColors.amber,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'İş Fikriniz Yok mu? Hiç Sorun Değil!',
                        style: context.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.oceanBlue,
                        ),
                      ),
                      Text(
                        'Filizora\'da fikrinizi birlikte yeşerteceğiz.',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: AppColors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildFeatureBullet(
              context,
              icon: Icons.people_outline_rounded,
              title: 'Mentorluk Rehberliği',
              desc: 'Deneyimli mentorlarla görüşerek yeteneklerinize uygun fırsatları keşfedebilirsiniz.',
            ),
            const SizedBox(height: 8),
            _buildFeatureBullet(
              context,
              icon: Icons.forum_outlined,
              title: 'Topluluktan İlham Alın',
              desc: 'Girişimcilerin paylaşımlarını inceleyip ekosistemdeki trendleri takip edebilirsiniz.',
            ),
            const SizedBox(height: 8),
            _buildFeatureBullet(
              context,
              icon: Icons.account_balance_outlined,
              title: 'Kamu Destekleri & Hibeler',
              desc: 'KOSGEB ve TÜBİTAK çağrılarını görerek desteklenen alanlara yönelebilirsiniz.',
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Text(
              'İlginizi Çeken Alanları Seçin (Opsiyonel):',
              style: context.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimary : AppColors.textLightPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _interestOptions.map((interest) {
                final isSelected = _selectedInterests.contains(interest);
                return FilterChip(
                  label: Text(interest),
                  selected: isSelected,
                  selectedColor: AppColors.teal.withAlpha(50),
                  checkmarkColor: AppColors.teal,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? AppColors.teal
                        : (isDark ? AppColors.textSecondary : AppColors.textLightSecondary),
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.teal : (isDark ? AppColors.obsidianBorder : AppColors.lightBorder),
                  ),
                  onSelected: (_) => _toggleInterest(interest),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBullet(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.teal),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: context.textTheme.bodySmall?.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.textLightSecondary,
                height: 1.3,
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
