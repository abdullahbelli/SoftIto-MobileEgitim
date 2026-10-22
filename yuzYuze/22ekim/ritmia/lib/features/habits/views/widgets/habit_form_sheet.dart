import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../models/habit.dart';

/// Alışkanlık Ekleme ve Düzenleme Modal Formu (Bottom Sheet).
/// Sürüklenebilir, klavyeye duyarlı ve kapsamlı doğrulama kuralları içerir.
class HabitFormSheet extends StatefulWidget {
  final Habit? habitToEdit;
  final void Function(Habit habit) onSave;
  final void Function(String habitId)? onDelete;

  const HabitFormSheet({
    super.key,
    this.habitToEdit,
    required this.onSave,
    this.onDelete,
  });

  @override
  State<HabitFormSheet> createState() => _HabitFormSheetState();
}

class _HabitFormSheetState extends State<HabitFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetValueController;

  late String _selectedCategory;
  late String _selectedTargetType;
  late List<int> _selectedWeekdays;
  late String _selectedColorKey;
  TimeOfDay? _reminderTime;
  late DateTime _startDate;
  DateTime? _endDate;

  bool get isEditing => widget.habitToEdit != null;

  @override
  void initState() {
    super.initState();
    final h = widget.habitToEdit;
    _nameController = TextEditingController(text: h?.name ?? '');
    _descriptionController = TextEditingController(text: h?.description ?? '');
    _targetValueController = TextEditingController(
      text: h != null ? h.targetValue.toInt().toString() : '1',
    );

    _selectedCategory = h?.category ?? AppConstants.habitCategories.first;
    _selectedTargetType = h?.targetType ?? AppConstants.targetTypeCheck;
    _selectedWeekdays = List<int>.from(h?.scheduledWeekdays ?? [1, 2, 3, 4, 5, 6, 7]);
    _selectedColorKey = h?.accentColorKey ?? 'pink';
    _startDate = h?.startDate ?? DateTime.now();
    _endDate = h?.endDate;

    if (h?.reminderTime != null && h!.reminderTime!.isNotEmpty) {
      final parts = h.reminderTime!.split(':');
      if (parts.length == 2) {
        _reminderTime = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 9,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetValueController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir planlanan gün seçin')),
      );
      return;
    }

    final targetVal = _selectedTargetType == AppConstants.targetTypeCheck
        ? 1.0
        : (double.tryParse(_targetValueController.text) ?? 1.0);

    final reminderStr = _reminderTime != null
        ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
        : null;

    final habit = Habit(
      id: widget.habitToEdit?.id ?? '',
      userId: widget.habitToEdit?.userId ?? 'demo_user',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      category: _selectedCategory,
      iconKey: 'default',
      accentColorKey: _selectedColorKey,
      targetType: _selectedTargetType,
      targetValue: targetVal,
      scheduledWeekdays: _selectedWeekdays,
      startDate: _startDate,
      endDate: _endDate,
      reminderTime: reminderStr,
      createdAt: widget.habitToEdit?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(habit);
    Navigator.of(context).pop();
  }

  Future<void> _handleDelete() async {
    if (widget.habitToEdit == null || widget.onDelete == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alışkanlığı Sil'),
        content: const Text(
          'Bu alışkanlığı silmek istediğinize emin misiniz? Geçmiş tamamlama ve istatistik kayıtlarınız korunacaktır.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('İptal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      widget.onDelete!(widget.habitToEdit!.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final keyboardBottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: keyboardBottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sürükleme Çizgisi (Drag Handle)
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Başlık ve Silme Butonu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEditing ? 'Alışkanlığı Düzenle' : 'Yeni Alışkanlık',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isEditing)
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                          tooltip: 'Alışkanlığı Sil',
                          onPressed: _handleDelete,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Alışkanlık Adı
                  CustomTextField(
                    controller: _nameController,
                    label: 'Alışkanlık Adı *',
                    hint: 'Örn: Kitap Oku, Su İç, Koşu Yap',
                    prefixIcon: Icons.edit_note_rounded,
                    validator: (val) {
                      if (val == null || val.trim().length < 3) {
                        return 'Alışkanlık adı en az 3 karakter olmalıdır';
                      }
                      if (val.trim().length > 60) {
                        return 'Alışkanlık adı en fazla 60 karakter olabilir';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Açıklama (İsteğe bağlı)
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Açıklama (İsteğe bağlı)',
                    hint: 'Kısa motivasyon veya not',
                    prefixIcon: Icons.notes_rounded,
                    maxLines: 2,
                    validator: (val) {
                      if (val != null && val.trim().length > 160) {
                        return 'Açıklama en fazla 160 karakter olabilir';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Kategori Seçimi
                  const Text(
                    'Kategori',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.habitCategories.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      final catColor = AppConstants.categoryColor(cat);
                      final catIcon = AppConstants.categoryIcon(cat);

                      return ChoiceChip(
                        avatar: Icon(catIcon, size: 16, color: isSelected ? Colors.white : catColor),
                        label: Text(cat),
                        selected: isSelected,
                        selectedColor: catColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedCategory = cat);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Hedef Türü
                  const Text(
                    'Hedef Türü',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: AppConstants.targetTypeCheck,
                        label: Text('Evet/Hayır'),
                        icon: Icon(Icons.check_circle_outline_rounded),
                      ),
                      ButtonSegment(
                        value: AppConstants.targetTypeCount,
                        label: Text('Adet'),
                        icon: Icon(Icons.numbers_rounded),
                      ),
                      ButtonSegment(
                        value: AppConstants.targetTypeDuration,
                        label: Text('Dakika'),
                        icon: Icon(Icons.timer_outlined),
                      ),
                    ],
                    selected: {_selectedTargetType},
                    onSelectionChanged: (set) {
                      setState(() => _selectedTargetType = set.first);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Hedef Miktarı (Adet veya Dakika seçilmişse)
                  if (_selectedTargetType != AppConstants.targetTypeCheck) ...[
                    CustomTextField(
                      controller: _targetValueController,
                      label: _selectedTargetType == AppConstants.targetTypeDuration
                          ? 'Günlük Hedef Süre (Dakika) *'
                          : 'Günlük Hedef Miktar (Adet/Sayfa) *',
                      hint: 'Örn: 20',
                      keyboardType: TextInputType.number,
                      prefixIcon: _selectedTargetType == AppConstants.targetTypeDuration
                          ? Icons.access_time_rounded
                          : Icons.flag_rounded,
                      validator: (val) {
                        final parsed = double.tryParse(val ?? '');
                        if (parsed == null || parsed <= 0) {
                          return 'Pozitif bir sayı girmelisiniz';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Tekrarlama / Planlanan Günler
                  const Text(
                    'Tekrarlama Günleri',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (index) {
                      final dayNum = index + 1; // 1 = Pzt ... 7 = Paz
                      final isSelected = _selectedWeekdays.contains(dayNum);
                      final dayName = AppConstants.weekdayShortNames[dayNum] ?? '';

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              if (_selectedWeekdays.length > 1) {
                                _selectedWeekdays.remove(dayNum);
                              }
                            } else {
                              _selectedWeekdays.add(dayNum);
                              _selectedWeekdays.sort();
                            }
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            ),
                          ),
                          child: Text(
                            dayName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Hatırlatıcı Saati
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hatırlatıcı Saati (İsteğe bağlı)',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _reminderTime != null
                                  ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
                                  : 'Saat seçilmedi',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.alarm_rounded, size: 18),
                        label: Text(_reminderTime == null ? 'Saat Belirle' : 'Değiştir'),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _reminderTime ?? const TimeOfDay(hour: 9, minute: 0),
                          );
                          if (picked != null) {
                            setState(() => _reminderTime = picked);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Kaydet Butonu
                  CustomButton(
                    text: isEditing ? 'Değişiklikleri Kaydet' : 'Alışkanlığı Oluştur',
                    onPressed: _handleSave,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
