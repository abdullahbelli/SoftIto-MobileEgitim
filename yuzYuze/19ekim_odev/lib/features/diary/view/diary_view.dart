import 'package:flutter/material.dart';
import '../controllers/diary_controller.dart';
import '../models/diary_model.dart';

/// Seçilen tarihe ait günlüğü görüntüleme, ekleme, düzenleme ve silme ekranı.
class DiaryView extends StatefulWidget {
  final DateTime selectedDate;
  final DiaryController controller;
  final VoidCallback? onDiarySaved;
  final VoidCallback? onDiaryDeleted;

  const DiaryView({
    super.key,
    required this.selectedDate,
    required this.controller,
    this.onDiarySaved,
    this.onDiaryDeleted,
  });

  @override
  State<DiaryView> createState() => _DiaryViewState();
}

class _DiaryViewState extends State<DiaryView> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();

    // Seçilen tarihin günlüğünü yükle
    widget.controller.loadDiaryForDate(widget.selectedDate).then((_) {
      _syncControllers();
    });
  }

  void _syncControllers() {
    final diary = widget.controller.selectedDiary.value;
    if (diary != null) {
      _titleController.text = diary.title;
      _contentController.text = diary.content;
      _isEditing = false;
    } else {
      _titleController.clear();
      _contentController.clear();
      _isEditing = false; // Kayıt yoksa kullanıcıya boş mesajı göster
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final success = await widget.controller.saveOrUpdateDiary(
      date: widget.selectedDate,
      title: _titleController.text,
      content: _contentController.text,
    );

    if (!mounted) return;

    if (success) {
      setState(() => _isEditing = false);
      widget.onDiarySaved?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Günlük başarıyla kaydedildi.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final error = widget.controller.errorMessage.value ?? 'Bir hata oluştu.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _DeleteConfirmationDialog(),
    );

    if (confirmed != true || !mounted) return;

    final success = await widget.controller.deleteCurrentDiary();
    if (!mounted) return;

    if (success) {
      widget.onDiaryDeleted?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Günlük silindi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_formatHeaderDate(widget.selectedDate)),
        actions: [
          ValueListenableBuilder<DiaryModel?>(
            valueListenable: widget.controller.selectedDiary,
            builder: (context, diary, _) {
              if (diary == null) return const SizedBox.shrink();
              return _HeaderActions(
                isEditing: _isEditing,
                onEditToggle: () => setState(() => _isEditing = !_isEditing),
                onDelete: _handleDelete,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ValueListenableBuilder<bool>(
            valueListenable: widget.controller.isLoading,
            builder: (context, isLoading, _) {
              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return _DiaryViewBody(
                selectedDate: widget.selectedDate,
                controller: widget.controller,
                titleController: _titleController,
                contentController: _contentController,
                isEditing: _isEditing,
                onSave: _handleSave,
                onStartWrite: () => setState(() => _isEditing = true),
              );
            },
          ),
        ),
      ),
    );
  }

  static String _formatHeaderDate(DateTime date) {
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

/// AppBar üzerindeki düzenleme ve silme aksiyon butonları.
class _HeaderActions extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onEditToggle;
  final VoidCallback onDelete;

  const _HeaderActions({
    required this.isEditing,
    required this.onEditToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(isEditing ? Icons.visibility_outlined : Icons.edit_outlined),
          tooltip: isEditing ? 'Görüntüleme Modu' : 'Düzenle',
          onPressed: onEditToggle,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Günlüğü Sil',
          onPressed: onDelete,
        ),
      ],
    );
  }
}

/// Günlük ekranının ana gövde widget'ı.
class _DiaryViewBody extends StatelessWidget {
  final DateTime selectedDate;
  final DiaryController controller;
  final TextEditingController titleController;
  final TextEditingController contentController;
  final bool isEditing;
  final VoidCallback onSave;
  final VoidCallback onStartWrite;

  const _DiaryViewBody({
    required this.selectedDate,
    required this.controller,
    required this.titleController,
    required this.contentController,
    required this.isEditing,
    required this.onSave,
    required this.onStartWrite,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DiaryModel?>(
      valueListenable: controller.selectedDiary,
      builder: (context, diary, _) {
        if (diary == null && !isEditing) {
          return _EmptyDiaryNotice(onStartWrite: onStartWrite);
        }

        if (isEditing) {
          return _DiaryEditorForm(
            titleController: titleController,
            contentController: contentController,
            onSave: onSave,
          );
        }

        return _DiaryReaderCard(diary: diary!);
      },
    );
  }
}

/// Günlük bulunmadığında gösterilen bilgi ve ekleme butonu.
class _EmptyDiaryNotice extends StatelessWidget {
  final VoidCallback onStartWrite;

  const _EmptyDiaryNotice({required this.onStartWrite});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bu güne ait henüz bir günlük yazılmamış.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onStartWrite,
              icon: const Icon(Icons.edit),
              label: const Text('Bu Gün İçin Günlük Yaz'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Günlük düzenleme / oluşturma formu.
class _DiaryEditorForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final VoidCallback onSave;

  const _DiaryEditorForm({
    required this.titleController,
    required this.contentController,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Günlük Başlığı',
            hintText: 'Bugünün başlığı nedir?',
            prefixIcon: Icon(Icons.title),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: contentController,
          decoration: const InputDecoration(
            labelText: 'Günlük İçeriği',
            hintText: 'Bugün neler yaşadın? Düşüncelerini buraya yaz...',
            alignLabelWithHint: true,
          ),
          maxLines: 12,
          minLines: 6,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: onSave,
          icon: const Icon(Icons.save),
          label: const Text('Günlüğü Kaydet'),
        ),
      ],
    );
  }
}

/// Kayıtlı günlüğü okuma görünümü.
class _DiaryReaderCard extends StatelessWidget {
  final DiaryModel diary;

  const _DiaryReaderCard({required this.diary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diary.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 32),
                Text(
                  diary.content,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Günlük silme teyit iletişim kutusu.
class _DeleteConfirmationDialog extends StatelessWidget {
  const _DeleteConfirmationDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Günlüğü Sil'),
      content: const Text(
        'Bu günlüğü silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('İptal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Sil'),
        ),
      ],
    );
  }
}
