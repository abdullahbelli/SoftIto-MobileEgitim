import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Yeni Topluluk Gönderisi Oluşturma Alt Sayfası
class CreatePostSheet extends StatefulWidget {
  final Function(String content, String tag) onPostCreated;

  const CreatePostSheet({
    super.key,
    required this.onPostCreated,
  });

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final _contentController = TextEditingController();
  String _selectedTag = 'Girişimcilik';

  static const List<String> tags = [
    'Girişimcilik',
    'KOSGEB Deneyimi',
    'Büyüme & Pazarlama',
    'Mentorluk & Destek',
    'Yatırım',
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _contentController.text.trim();
    if (text.isEmpty) return;

    widget.onPostCreated(text, _selectedTag);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Toplulukta Paylaş',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            maxLines: 4,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Bir soru sorun, deneyiminizi veya başarınızı paylaşın...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: tags.map((tag) {
                final isSelected = _selectedTag == tag;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text('#$tag'),
                    selected: isSelected,
                    selectedColor: AppColors.neonCyan.withAlpha(35),
                    onSelected: (_) {
                      setState(() {
                        _selectedTag = tag;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Paylaş'),
            ),
          ),
        ],
      ),
    );
  }
}
