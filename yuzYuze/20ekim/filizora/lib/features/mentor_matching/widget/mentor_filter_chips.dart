import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Uzmanlık Alanına Göre Filtreleme Çipleri
class MentorFilterChips extends StatelessWidget {
  final String? selectedExpertise;
  final ValueChanged<String?> onSelect;

  static const List<String> categories = [
    'Tümü',
    'Yatırım & Finans',
    'Ürün Yönetimi',
    'Yapay Zekâ & Tech',
    'Hukuk & Şirketleşme',
  ];

  const MentorFilterChips({
    super.key,
    required this.selectedExpertise,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: categories.map((cat) {
          final isAll = cat == 'Tümü';
          final isSelected = isAll ? (selectedExpertise == null) : (selectedExpertise == cat);

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              selectedColor: AppColors.neonCyan.withAlpha(45),
              onSelected: (_) {
                onSelect(isAll ? null : cat);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
