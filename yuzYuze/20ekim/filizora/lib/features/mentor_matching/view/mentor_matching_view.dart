import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/app_theme_toggle_button.dart';
import '../../../../core/widgets/brand_palette_bar.dart';
import '../../authentication/controller/auth_controller.dart';
import '../controller/mentor_matching_controller.dart';
import '../widget/mentor_card.dart';
import '../widget/mentor_filter_chips.dart';

/// Mentor-Menti Eşleşmesi Ana Sayfası
class MentorMatchingView extends StatelessWidget {
  final MentorMatchingController controller;
  final ThemeController themeController;
  final AuthController? authController;

  const MentorMatchingView({
    super.key,
    required this.controller,
    required this.themeController,
    this.authController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor Eşleşmesi'),
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
            ValueListenableBuilder<String?>(
              valueListenable: controller.selectedExpertise,
              builder: (context, selectedExp, _) {
                return MentorFilterChips(
                  selectedExpertise: selectedExp,
                  onSelect: controller.filterByExpertise,
                );
              },
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: Listenable.merge([controller.mentors, controller.selectedExpertise]),
                builder: (context, _) {
                  final list = controller.filteredMentors;
                  if (list.isEmpty) {
                    return const _EmptyMentorsState();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final mentor = list[index];
                      return MentorCard(
                        mentor: mentor,
                        onToggleMatch: () {
                          final user = authController?.currentUser.value;
                          if (!mentor.isMatched) {
                            controller.sendMatchRequest(
                              mentorId: mentor.id,
                              entrepreneurName: user?.fullName ?? 'Filizora Girişimcisi',
                              ideaTitle: user?.idea?.title ??
                                  (user?.hasIdea == true ? 'Girişim Projesi' : 'Fikir Arayışında Girişimci'),
                              ideaSector: user?.idea?.sector ?? mentor.expertise,
                              entrepreneurId: user?.id,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${mentor.name} için eşleşme isteği iletildi. Yatırımcı onayladığında eşleşme aktifleşecektir.',
                                ),
                                backgroundColor: AppColors.teal,
                              ),
                            );
                          } else {
                            controller.toggleMatch(mentor.id);
                          }
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

class _EmptyMentorsState extends StatelessWidget {
  const _EmptyMentorsState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: AppColors.textSecondary),
          SizedBox(height: 12),
          Text(
            'Seçilen kategoride mentor bulunamadı.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
