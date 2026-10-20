import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/app_theme_toggle_button.dart';
import '../../../../core/widgets/brand_palette_bar.dart';
import '../controller/community_controller.dart';
import '../models/community_post.dart';
import '../widget/create_post_sheet.dart';
import '../widget/post_card.dart';

/// Girişimci Topluluğu Ana Sayfası
class EntrepreneurCommunityView extends StatelessWidget {
  final CommunityController controller;
  final ThemeController themeController;

  const EntrepreneurCommunityView({
    super.key,
    required this.controller,
    required this.themeController,
  });

  void _openCreateSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => CreatePostSheet(
        onPostCreated: (content, tag) {
          controller.addPost(
            authorName: 'Siz',
            authorTitle: 'Girişimci',
            content: content,
            tag: tag,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Girişimci Topluluğu'),
        actions: [
          AppThemeToggleButton(themeController: themeController),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(3),
          child: BrandPaletteBar(height: 3),
        ),
      ),
      body: SafeArea(
        child: ValueListenableBuilder<List<CommunityPost>>(
          valueListenable: controller.posts,
          builder: (context, posts, _) {
            if (posts.isEmpty) {
              return const Center(
                child: Text(
                  'Henüz paylaşım yok. İlk paylaşımı sen yap!',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostCard(
                  post: post,
                  onLike: () => controller.toggleLike(post.id),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateSheet(context),
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('Paylaşım Yap', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
