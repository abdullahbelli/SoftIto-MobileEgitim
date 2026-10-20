import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../models/community_post.dart';

/// Topluluk Gönderisi Kartı
class PostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onLike;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
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
            _PostAuthorHeader(post: post),
            const SizedBox(height: 12),
            Text(
              post.content,
              style: context.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 12),
            _PostTag(tag: post.tag),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _PostInteractionBar(post: post, onLike: onLike),
          ],
        ),
      ),
    );
  }
}

class _PostAuthorHeader extends StatelessWidget {
  final CommunityPost post;
  const _PostAuthorHeader({required this.post});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.neonTeal.withAlpha(40),
          child: Text(
            post.authorName.isNotEmpty ? post.authorName.substring(0, 1) : 'G',
            style: const TextStyle(
              color: AppColors.neonTeal,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.authorName,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                post.authorTitle,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PostTag extends StatelessWidget {
  final String tag;
  const _PostTag({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.neonCyan.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '#$tag',
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.neonCyan,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PostInteractionBar extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onLike;

  const _PostInteractionBar({
    required this.post,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    final likeColor = post.isLiked ? AppColors.neonCrimson : AppColors.textSecondary;

    return Row(
      children: [
        InkWell(
          onTap: onLike,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Icon(
                  post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 18,
                  color: likeColor,
                ),
                const SizedBox(width: 6),
                Text(
                  '${post.likesCount}',
                  style: TextStyle(
                    fontSize: 13,
                    color: likeColor,
                    fontWeight: post.isLiked ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              '${post.commentsCount}',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}
