import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/models/user_profile.dart';

/// Profil Düzenleme Diyaloğu
class EditProfileDialog extends StatefulWidget {
  final UserProfile profile;
  final void Function(UserProfile updated) onSave;

  const EditProfileDialog({
    super.key,
    required this.profile,
    required this.onSave,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
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

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.profile.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      username: _usernameController.text.trim(),
    );

    widget.onSave(updated);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Profili Düzenle'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _firstNameController,
                label: 'Ad',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Ad zorunludur';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _lastNameController,
                label: 'Soyad',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Soyad zorunludur';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _usernameController,
                label: 'Kullanıcı Adı',
                validator: (val) {
                  if (val == null || val.trim().length < 3) {
                    return 'Kullanıcı adı en az 3 karakter olmalıdır';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: _handleSave,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
