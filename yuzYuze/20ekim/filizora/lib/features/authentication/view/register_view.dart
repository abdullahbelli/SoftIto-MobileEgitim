import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/app_theme_toggle_button.dart';
import '../../../../core/widgets/brand_palette_bar.dart';
import '../controller/auth_controller.dart';
import '../models/user_account.dart';
import '../widget/auth_header.dart';
import '../widget/idea_form_fields.dart';
import '../widget/idea_selection_toggle.dart';
import '../widget/no_idea_guidance_card.dart';

/// Girişimci kimlik doğrulama modu (Yeni Kayıt / Giriş)
enum EntrepreneurAuthMode { register, login }

/// Çoklu Rol Destekli Giriş ve Kayıt Ekranı (Girişimci, Yatırımcı, Admin)
class RegisterView extends StatefulWidget {
  final AuthController authController;
  final ThemeController themeController;

  const RegisterView({
    super.key,
    required this.authController,
    required this.themeController,
  });

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  EntrepreneurAuthMode _entrepreneurMode = EntrepreneurAuthMode.register;

  // Girişimci Kayıt Kontrolleri
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ideaTitleController = TextEditingController();
  final _ideaSectorController = TextEditingController();
  final _ideaDescriptionController = TextEditingController();

  // Girişimci Giriş Kontrolleri
  final _loginEmailController = TextEditingController(text: 'bora@test.com');
  final _loginPasswordController = TextEditingController(text: 'filizora2026');

  // Yatırımcı Kontrolleri
  final _investorNameController = TextEditingController(text: 'Dr. Ahmet Yılmaz');
  final _investorEmailController = TextEditingController(text: 'ahmet@techventures.com');
  final _investorExpertiseController = TextEditingController(text: 'Yatırım & Finans');

  // Admin Kontrolleri
  final _adminEmailController = TextEditingController(text: 'admin@filizora.com');
  final _adminPasswordController = TextEditingController(text: 'filizora2026');

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _ideaTitleController.dispose();
    _ideaSectorController.dispose();
    _ideaDescriptionController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _investorNameController.dispose();
    _investorEmailController.dispose();
    _investorExpertiseController.dispose();
    _adminEmailController.dispose();
    _adminPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleEntrepreneurRegister() async {
    final success = await widget.authController.register(
      fullName: _fullNameController.text,
      email: _emailController.text,
      role: UserRole.entrepreneur,
      ideaTitle: _ideaTitleController.text,
      ideaSector: _ideaSectorController.text,
      ideaDescription: _ideaDescriptionController.text,
    );
    _checkError(success);
  }

  Future<void> _handleEntrepreneurLogin() async {
    final success = await widget.authController.loginWithEmail(
      _loginEmailController.text,
    );
    _checkError(success);
  }

  Future<void> _handleInvestorLogin() async {
    final success = await widget.authController.register(
      fullName: _investorNameController.text,
      email: _investorEmailController.text,
      role: UserRole.investor,
    );
    _checkError(success);
  }

  void _handleAdminLogin() {
    widget.authController.loginAsRole(UserRole.admin);
  }

  void _checkError(bool success) {
    if (!success && mounted) {
      final msg = widget.authController.errorMessage.value ?? 'Lütfen alanları kontrol ediniz.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: AppColors.rose,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
        actions: [
          AppThemeToggleButton(themeController: widget.themeController),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(3),
          child: BrandPaletteBar(height: 3),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AuthHeader(),
              const SizedBox(height: 16),
              ValueListenableBuilder<UserRole>(
                valueListenable: widget.authController.selectedRole,
                builder: (context, role, _) {
                  return _RoleSelectorSegmented(
                    currentRole: role,
                    onRoleChanged: widget.authController.setRole,
                  );
                },
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<UserRole>(
                valueListenable: widget.authController.selectedRole,
                builder: (context, role, _) {
                  switch (role) {
                    case UserRole.entrepreneur:
                      return _EntrepreneurFormSection(
                        authController: widget.authController,
                        mode: _entrepreneurMode,
                        onModeChanged: (m) => setState(() => _entrepreneurMode = m),
                        nameController: _fullNameController,
                        emailController: _emailController,
                        titleController: _ideaTitleController,
                        sectorController: _ideaSectorController,
                        descController: _ideaDescriptionController,
                        loginEmailController: _loginEmailController,
                        loginPasswordController: _loginPasswordController,
                        onRegisterSubmit: _handleEntrepreneurRegister,
                        onLoginSubmit: _handleEntrepreneurLogin,
                      );
                    case UserRole.investor:
                      return _InvestorFormSection(
                        nameController: _investorNameController,
                        emailController: _investorEmailController,
                        expertiseController: _investorExpertiseController,
                        onSubmit: _handleInvestorLogin,
                      );
                    case UserRole.admin:
                      return _AdminFormSection(
                        emailController: _adminEmailController,
                        passwordController: _adminPasswordController,
                        onSubmit: _handleAdminLogin,
                      );
                  }
                },
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              _QuickDemoRolesSection(authController: widget.authController),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleSelectorSegmented extends StatelessWidget {
  final UserRole currentRole;
  final ValueChanged<UserRole> onRoleChanged;

  const _RoleSelectorSegmented({
    required this.currentRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giriş Yapılacak Rolü Seçiniz:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<UserRole>(
            segments: const [
              ButtonSegment(
                value: UserRole.entrepreneur,
                label: Text('Girişimci'),
                icon: Icon(Icons.rocket_launch_outlined),
              ),
              ButtonSegment(
                value: UserRole.investor,
                label: Text('Yatırımcı'),
                icon: Icon(Icons.trending_up_rounded),
              ),
              ButtonSegment(
                value: UserRole.admin,
                label: Text('Admin'),
                icon: Icon(Icons.admin_panel_settings_outlined),
              ),
            ],
            selected: {currentRole},
            onSelectionChanged: (set) => onRoleChanged(set.first),
          ),
        ),
      ],
    );
  }
}

class _EntrepreneurFormSection extends StatelessWidget {
  final AuthController authController;
  final EntrepreneurAuthMode mode;
  final ValueChanged<EntrepreneurAuthMode> onModeChanged;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController titleController;
  final TextEditingController sectorController;
  final TextEditingController descController;
  final TextEditingController loginEmailController;
  final TextEditingController loginPasswordController;
  final VoidCallback onRegisterSubmit;
  final VoidCallback onLoginSubmit;

  const _EntrepreneurFormSection({
    required this.authController,
    required this.mode,
    required this.onModeChanged,
    required this.nameController,
    required this.emailController,
    required this.titleController,
    required this.sectorController,
    required this.descController,
    required this.loginEmailController,
    required this.loginPasswordController,
    required this.onRegisterSubmit,
    required this.onLoginSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _EntrepreneurModeSwitcher(mode: mode, onModeChanged: onModeChanged),
        const SizedBox(height: 16),
        if (mode == EntrepreneurAuthMode.register) ...[
          _UserBasicInfoSection(nameController: nameController, emailController: emailController),
          const SizedBox(height: 20),
          _IdeaSection(
            authController: authController,
            titleController: titleController,
            sectorController: sectorController,
            descController: descController,
          ),
          const SizedBox(height: 24),
          _SubmitButton(
            authController: authController,
            label: 'Kaydı Tamamla ve Onaya Gönder',
            onSubmit: onRegisterSubmit,
          ),
        ] else ...[
          _EntrepreneurLoginSection(
            authController: authController,
            emailController: loginEmailController,
            passwordController: loginPasswordController,
            onSubmit: onLoginSubmit,
          ),
        ],
      ],
    );
  }
}

class _EntrepreneurModeSwitcher extends StatelessWidget {
  final EntrepreneurAuthMode mode;
  final ValueChanged<EntrepreneurAuthMode> onModeChanged;

  const _EntrepreneurModeSwitcher({
    required this.mode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.obsidianSurface
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.obsidianBorder
              : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeTabItem(
              title: 'Yeni Kayıt Ol',
              icon: Icons.person_add_rounded,
              isSelected: mode == EntrepreneurAuthMode.register,
              onTap: () => onModeChanged(EntrepreneurAuthMode.register),
            ),
          ),
          Expanded(
            child: _ModeTabItem(
              title: 'Giriş Yap',
              icon: Icons.login_rounded,
              isSelected: mode == EntrepreneurAuthMode.login,
              onTap: () => onModeChanged(EntrepreneurAuthMode.login),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeTabItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeTabItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntrepreneurLoginSection extends StatelessWidget {
  final AuthController authController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  const _EntrepreneurLoginSection({
    required this.authController,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withAlpha(40)),
          ),
          child: const Row(
            children: [
              Icon(Icons.lock_person_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kayıtlı e-postanız ile doğrudan giriş yapabilirsiniz. Onay durumunuz otomatik olarak denetlenir.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Kayıtlı E-posta Adresi',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Şifre',
            prefixIcon: Icon(Icons.lock_outline_rounded),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            ActionChip(
              avatar: const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.emerald),
              label: const Text('Bora Aksoy (Onaylı)', style: TextStyle(fontSize: 11)),
              onPressed: () => emailController.text = 'bora@test.com',
            ),
            ActionChip(
              avatar: const Icon(Icons.hourglass_top_rounded, size: 16, color: AppColors.amber),
              label: const Text('Zeynep Kaya (Bekleyen)', style: TextStyle(fontSize: 11)),
              onPressed: () => emailController.text = 'zeynep@greenpack.io',
            ),
          ],
        ),
        const SizedBox(height: 20),
        _SubmitButton(
          authController: authController,
          label: 'Girişimci Girişi Yap',
          onSubmit: onSubmit,
        ),
      ],
    );
  }
}

class _InvestorFormSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController expertiseController;
  final VoidCallback onSubmit;

  const _InvestorFormSection({
    required this.nameController,
    required this.emailController,
    required this.expertiseController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withAlpha(40)),
          ),
          child: const Row(
            children: [
              Icon(Icons.handshake_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Yatırımcı/Mentor rolü ile girişimcilerden gelen eşleşme ve mentorluk taleplerini inceleyebilirsiniz.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Ad Soyad / Unvan',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'E-posta Adresi',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: expertiseController,
          decoration: const InputDecoration(
            labelText: 'Uzmanlık / Yatırım Alanı',
            prefixIcon: Icon(Icons.domain_rounded),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onSubmit,
            icon: const Icon(Icons.handshake_rounded),
            label: const Text(
              'Yatırımcı Portalı Girişi Yap',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminFormSection extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  const _AdminFormSection({
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.amber.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.amber.withAlpha(60)),
          ),
          child: const Row(
            children: [
              Icon(Icons.security_rounded, color: AppColors.amber),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Yönetici (Admin) girişi ile bekleyen girişimci başvurularını onaylayabilir veya reddedebilirsiniz.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'Yönetici E-posta',
            prefixIcon: Icon(Icons.admin_panel_settings_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Yönetici Şifresi',
            prefixIcon: Icon(Icons.lock_outline_rounded),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onSubmit,
            icon: const Icon(Icons.login_rounded),
            label: const Text(
              'Yönetici (Admin) Girişi Yap',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickDemoRolesSection extends StatelessWidget {
  final AuthController authController;

  const _QuickDemoRolesSection({required this.authController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hızlı Rol Testi & Demo Girişleri:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onPressed: () => authController.loginAsRole(UserRole.entrepreneur),
                icon: const Icon(Icons.person_rounded, size: 16),
                label: const Text('Girişimci', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.emerald,
                  side: const BorderSide(color: AppColors.emerald),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onPressed: () => authController.loginAsRole(UserRole.investor),
                icon: const Icon(Icons.trending_up_rounded, size: 16),
                label: const Text('Yatırımcı', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.amber,
                  side: const BorderSide(color: AppColors.amber),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                onPressed: () => authController.loginAsRole(UserRole.admin),
                icon: const Icon(Icons.security_rounded, size: 16),
                label: const Text('Admin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UserBasicInfoSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;

  const _UserBasicInfoSection({
    required this.nameController,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Ad Soyad',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'E-posta Adresi',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class _IdeaSection extends StatelessWidget {
  final AuthController authController;
  final TextEditingController titleController;
  final TextEditingController sectorController;
  final TextEditingController descController;

  const _IdeaSection({
    required this.authController,
    required this.titleController,
    required this.sectorController,
    required this.descController,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: authController.hasIdeaSelection,
      builder: (context, hasIdea, _) {
        return Column(
          children: [
            IdeaSelectionToggle(
              hasIdea: hasIdea,
              onSelectionChanged: authController.setHasIdea,
            ),
            if (hasIdea) ...[
              const SizedBox(height: 16),
              IdeaFormFields(
                titleController: titleController,
                sectorController: sectorController,
                descriptionController: descController,
              ),
            ] else ...[
              const SizedBox(height: 16),
              const NoIdeaGuidanceCard(),
            ],
          ],
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final AuthController authController;
  final String label;
  final VoidCallback onSubmit;

  const _SubmitButton({
    required this.authController,
    required this.label,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: authController.isLoading,
      builder: (context, isLoading, _) {
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: isLoading ? null : onSubmit,
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.rocket_launch_rounded),
            label: Text(
              isLoading ? 'İşleniyor...' : label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}
