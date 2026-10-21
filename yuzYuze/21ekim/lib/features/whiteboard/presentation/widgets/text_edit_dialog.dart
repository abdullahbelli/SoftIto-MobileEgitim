import 'package:flutter/material.dart';

/// Metin ve Post-it not içerik düzenleme diyaloğu
class TextEditDialog extends StatefulWidget {
  final String title;
  final String initialText;
  final ValueChanged<String> onSave;
  final bool showColorPicker;
  final Color? initialColor;
  final ValueChanged<Color>? onColorChanged;

  const TextEditDialog({
    super.key,
    required this.title,
    this.initialText = '',
    required this.onSave,
    this.showColorPicker = false,
    this.initialColor,
    this.onColorChanged,
  });

  static const List<Color> postItColors = [
    Color(0xFFFEF08A), // Sarı
    Color(0xFFBAE6FD), // Açık Mavi
    Color(0xFFBBF7D0), // Açık Yeşil
    Color(0xFFFECDD3), // Açık Pembe
    Color(0xFFE9D5FF), // Açık Mor
    Color(0xFFFED7AA), // Açık Turuncu
  ];

  @override
  State<TextEditDialog> createState() => _TextEditDialogState();
}

class _TextEditDialogState extends State<TextEditDialog> {
  late final TextEditingController _controller;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _selectedColor = widget.initialColor ?? TextEditDialog.postItColors[0];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 5,
              minLines: 3,
              decoration: InputDecoration(
                hintText: 'Metninizi veya notunuzu buraya yazın...',
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
              ),
            ),
            if (widget.showColorPicker) ...[
              const SizedBox(height: 16),
              const Text(
                'Not Rengi Seçin:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: TextEditDialog.postItColors.map((color) {
                  final isSelected = _selectedColor == color;
                  return InkWell(
                    onTap: () {
                      setState(() => _selectedColor = color);
                      widget.onColorChanged?.call(color);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.black87, width: 2.5)
                            : Border.all(color: Colors.black12, width: 1),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.black87,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave(_controller.text.trim());
            Navigator.pop(context);
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
