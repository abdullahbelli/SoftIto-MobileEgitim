import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/models/user_profile.dart';

/// Profil Düzenleme Alttan Açılır Modalı (EditProfileSheet).
/// Ekranın %70'ini kaplar, klavye açıldığında yukarı kayar,
/// sabit başlık ve sürüklenebilir tutamaç barındırır.
class EditProfileSheet extends StatefulWidget {
  final UserProfile profile;
  final void Function(UserProfile updated) onSave;

  const EditProfileSheet({
    super.key,
    required this.profile,
    required this.onSave,
  });

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.profile.firstName);
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _usernameController = TextEditingController(text: widget.profile.username);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  String get _currentInitials {
    final first = _firstNameController.text.trim();
    final last = _lastNameController.text.trim();
    final f = first.isNotEmpty ? first[0].toUpperCase() : '';
    final l = last.isNotEmpty ? last[0].toUpperCase() : '';
    return f.isNotEmpty ? '$f$l' : widget.profile.initials;
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.profile.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      username: _usernameController.text.trim(),
    );

    widget.onSave(updated);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profil bilgileriniz başarıyla güncellendi.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final keyboardBottom = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.70, // Ekranın %70'ini kaplar
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.6),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: keyboardBottom),
          child: Column(
            children: [
              // Üst Sabit Çubuk ve Başlık
              Container(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Column(
                  children: [
                    // Sürükleme Tutamacı
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(width: 40),
                          const Text(
                            'Profili Düzenle',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            tooltip: 'Kapat',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Kaydırılabilir Form Gövdesi (Scroll Özelliği)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Canlı Avatar Önizlemesi
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: theme.colorScheme.primary,
                                child: Text(
                                  _currentInitials,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Görünen adınız liderlik liglerinde sergilenir',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Ad Alanı
                        CustomTextField(
                          controller: _firstNameController,
                          label: 'Ad *',
                          hint: 'Örn: Ahmet',
                          prefixIcon: Icons.badge_outlined,
                          onChanged: (_) => setState(() {}),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Ad alanı boş bırakılamaz';
                            }
                            if (val.trim().length > 30) {
                              return 'Ad en fazla 30 karakter olabilir';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Soyad Alanı
                        CustomTextField(
                          controller: _lastNameController,
                          label: 'Soyad *',
                          hint: 'Örn: Yılmaz',
                          prefixIcon: Icons.person_outline_rounded,
                          onChanged: (_) => setState(() {}),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Soyad alanı boş bırakılamaz';
                            }
                            if (val.trim().length > 30) {
                              return 'Soyad en fazla 30 karakter olabilir';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Kullanıcı Adı Alanı
                        CustomTextField(
                          controller: _usernameController,
                          label: 'Kullanıcı Adı *',
                          hint: 'Örn: ahmetyilmaz',
                          prefixIcon: Icons.alternate_email_rounded,
                          validator: (val) {
                            if (val == null || val.trim().length < 3) {
                              return 'Kullanıcı adı en az 3 karakter olmalıdır';
                            }
                            if (val.trim().length > 20) {
                              return 'Kullanıcı adı en fazla 20 karakter olabilir';
                            }
                            final validRegex = RegExp(r'^[a-zA-Z0-9_]+$');
                            if (!validRegex.hasMatch(val.trim())) {
                              return 'Yalnızca harf, rakam ve alt çizgi (_) içerebilir';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // E-posta Bilgi Kutusu (Değiştirilemez bilgi)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: theme.colorScheme.outline),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kayıtlı E-posta',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.profile.email,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.lock_outline_rounded,
                                size: 16,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Kaydet Butonu
                        ElevatedButton(
                          onPressed: _handleSave,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                          ),
                          child: const Text('Değişiklikleri Kaydet'),
                        ),
                        const SizedBox(height: 10),

                        // İptal Butonu
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Vazgeç'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
