import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/app_theme_toggle_button.dart';
import '../../../../core/widgets/brand_palette_bar.dart';
import '../controller/support_programs_controller.dart';
import '../widget/program_card.dart';
import '../widget/program_filter_chips.dart';

/// Destek Programları Ana Sayfası
class SupportProgramsView extends StatelessWidget {
  final SupportProgramsController controller;
  final ThemeController themeController;

  const SupportProgramsView({
    super.key,
    required this.controller,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destek Programları'),
        actions: [
          AppThemeToggleButton(themeController: themeController),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(3),
          child: BrandPaletteBar(height: 3),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<String?>(
                      valueListenable: controller.selectedCategory,
                      builder: (context, cat, _) {
                        return ProgramFilterChips(
                          selectedCategory: cat,
                          onSelect: controller.filterByCategory,
                        );
                      },
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: controller.showOnlyApplied,
                    builder: (context, onlyApplied, _) {
                      return FilterChip(
                        avatar: Icon(
                          Icons.verified_outlined,
                          size: 16,
                          color: onlyApplied ? Colors.white : AppColors.teal,
                        ),
                        label: Text(
                          'Başvurularım (${controller.appliedCount})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: onlyApplied ? Colors.white : AppColors.teal,
                          ),
                        ),
                        selected: onlyApplied,
                        selectedColor: AppColors.teal,
                        backgroundColor: AppColors.teal.withAlpha(25),
                        side: BorderSide(
                          color: onlyApplied ? AppColors.teal : AppColors.teal.withAlpha(60),
                        ),
                        onSelected: controller.toggleShowOnlyApplied,
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  controller.programs,
                  controller.selectedCategory,
                  controller.showOnlyApplied,
                ]),
                builder: (context, _) {
                  final list = controller.filteredPrograms;
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inbox_outlined, size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          Text(
                            controller.showOnlyApplied.value
                                ? 'Henüz bir programa başvuru yapmadınız.'
                                : 'Seçilen kriterde destek programı bulunamadı.',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final program = list[index];
                      return ProgramCard(
                        program: program,
                        onToggleSave: () => controller.toggleSave(program.id),
                        onApply: (title, budget) {
                          controller.applyToProgram(
                            program.id,
                            projectTitle: title,
                            requestedAmount: budget,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${program.title} başvurunuz başarıyla alındı!'),
                              backgroundColor: AppColors.teal,
                            ),
                          );
                        },
                        onCancelApplication: () {
                          controller.cancelApplication(program.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Başvuru geri çekildi.'),
                              backgroundColor: AppColors.red,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
