import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Destek Programı Kategori Çipleri
class ProgramFilterChips extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onSelect;

  static const List<String> categories = [
    'Tümü',
    'Hibe',
    'Tohum Yatırım',
    'Hızlandırıcı',
  ];

  const ProgramFilterChips({
    super.key,
    required this.selectedCategory,
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
          final isSelected = isAll ? (selectedCategory == null) : (selectedCategory == cat);

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              selectedColor: AppColors.neonLime.withAlpha(35),
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
