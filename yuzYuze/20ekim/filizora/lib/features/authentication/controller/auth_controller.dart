import 'package:flutter/foundation.dart';
import '../models/user_account.dart';

/// Kimlik Doğrulama, Çoklu Rol ve Yönetici Onayı Durum Yöneticisi
class AuthController {
  final ValueNotifier<UserAccount?> currentUser;
  final ValueNotifier<UserRole> selectedRole;
  final ValueNotifier<bool> hasIdeaSelection;
  final ValueNotifier<bool> isLoading;
  final ValueNotifier<String?> errorMessage;
  final ValueNotifier<List<UserAccount>> allUsers;

  static final List<UserAccount> _defaultUsers = [
    UserAccount(
      id: 'admin_1',
      fullName: 'Filizora Sistem Yöneticisi',
      email: 'admin@filizora.com',
      role: UserRole.admin,
      approvalStatus: ApprovalStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    UserAccount(
      id: 'investor_1',
      fullName: 'Dr. Ahmet Yılmaz (Yatırımcı & Mentor)',
      email: 'ahmet@techventures.com',
      role: UserRole.investor,
      approvalStatus: ApprovalStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    UserAccount(
      id: 'ent_approved_1',
      fullName: 'Bora Aksoy',
      email: 'bora@test.com',
      role: UserRole.entrepreneur,
      hasIdea: true,
      idea: const BusinessIdea(
        title: 'Akıllı Sulama ve IoT Tarım Çözümleri',
        sector: 'AgriTech',
        description: 'Tarımsal araziler için yapay zekâ destekli su tasarruflu sulama kontrolcüsü.',
      ),
      approvalStatus: ApprovalStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    UserAccount(
      id: 'ent_pending_1',
      fullName: 'Zeynep Kaya',
      email: 'zeynep@greenpack.io',
      role: UserRole.entrepreneur,
      hasIdea: true,
      idea: const BusinessIdea(
        title: 'Biyo-Çözünür Ambalaj Materyalleri',
        sector: 'CleanTech & Sürdürülebilirlik',
        description: 'Tarım atıklarından üretilen %100 biyolojik olarak parçalanabilir gıda ambalajı.',
      ),
      approvalStatus: ApprovalStatus.pendingApproval,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    UserAccount(
      id: 'ent_pending_2',
      fullName: 'Mert Demir',
      email: 'mert@greentech.org',
      role: UserRole.entrepreneur,
      hasIdea: false,
      approvalStatus: ApprovalStatus.pendingApproval,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
  ];

  AuthController({UserAccount? initialUser, List<UserAccount>? initialUsers})
      : currentUser = ValueNotifier<UserAccount?>(initialUser),
        selectedRole = ValueNotifier<UserRole>(UserRole.entrepreneur),
        hasIdeaSelection = ValueNotifier<bool>(true),
        isLoading = ValueNotifier<bool>(false),
        errorMessage = ValueNotifier<String?>(null),
        allUsers = ValueNotifier<List<UserAccount>>(initialUsers ?? _defaultUsers);

  bool get isAuthenticated => currentUser.value != null;
  bool get isApproved => currentUser.value?.isApproved ?? false;
  bool get isPending => currentUser.value?.isPending ?? false;
  bool get isAdmin => currentUser.value?.isAdmin ?? false;
  bool get isInvestor => currentUser.value?.isInvestor ?? false;
  bool get isEntrepreneur => currentUser.value?.isEntrepreneur ?? false;

  List<UserAccount> get pendingUsers =>
      allUsers.value.where((u) => u.role == UserRole.entrepreneur && u.isPending).toList();

  List<UserAccount> get approvedUsers =>
      allUsers.value.where((u) => u.role == UserRole.entrepreneur && u.isApproved).toList();

  void setRole(UserRole role) {
    selectedRole.value = role;
  }

  void setHasIdea(bool value) {
    hasIdeaSelection.value = value;
  }

  /// Kullanıcı Kaydı Gerçekleştirme
  Future<bool> register({
    required String fullName,
    required String email,
    UserRole? role,
    String? ideaTitle,
    String? ideaSector,
    String? ideaDescription,
  }) async {
    if (fullName.trim().isEmpty || email.trim().isEmpty) {
      errorMessage.value = 'Lütfen ad, soyad ve e-posta alanlarını doldurunuz.';
      return false;
    }

    final targetRole = role ?? selectedRole.value;

    if (targetRole == UserRole.entrepreneur && hasIdeaSelection.value) {
      if ((ideaTitle == null || ideaTitle.trim().isEmpty) ||
          (ideaSector == null || ideaSector.trim().isEmpty) ||
          (ideaDescription == null || ideaDescription.trim().isEmpty)) {
        errorMessage.value = 'İş fikrinizle ilgili alanları eksiksiz doldurunuz.';
        return false;
      }
    }

    isLoading.value = true;
    errorMessage.value = null;

    // Simülasyon gecikmesi
    await Future.delayed(const Duration(milliseconds: 300));

    final BusinessIdea? idea = (targetRole == UserRole.entrepreneur && hasIdeaSelection.value)
        ? BusinessIdea(
            title: ideaTitle!.trim(),
            sector: ideaSector!.trim(),
            description: ideaDescription!.trim(),
          )
        : null;

    // Girişimci ise yönetici onayı bekler; Admin veya Yatırımcı ise onaylı başlar
    final status = targetRole == UserRole.entrepreneur
        ? ApprovalStatus.pendingApproval
        : ApprovalStatus.approved;

    final newUser = UserAccount(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      fullName: fullName.trim(),
      email: email.trim(),
      role: targetRole,
      hasIdea: targetRole == UserRole.entrepreneur ? hasIdeaSelection.value : false,
      idea: idea,
      approvalStatus: status,
      createdAt: DateTime.now(),
    );

    allUsers.value = [newUser, ...allUsers.value];
    currentUser.value = newUser;
    isLoading.value = false;
    return true;
  }

  /// E-posta ile Girişimci veya Kullanıcı Girişi Yapma
  Future<bool> loginWithEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) {
      errorMessage.value = 'Lütfen e-posta adresinizi giriniz.';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = null;
    await Future.delayed(const Duration(milliseconds: 250));

    final matchedIndex = allUsers.value.indexWhere(
      (u) => u.email.trim().toLowerCase() == cleanEmail,
    );

    if (matchedIndex == -1) {
      isLoading.value = false;
      errorMessage.value = 'Bu e-posta adresine ait bir hesap bulunamadı. Lütfen "Yeni Kayıt" sekmesinden kayıt olunuz.';
      return false;
    }

    final user = allUsers.value[matchedIndex];
    currentUser.value = user;
    isLoading.value = false;
    return true;
  }

  /// Doğrudan belirli bir kullanıcı ile oturum açma
  void loginAsUser(UserAccount user) {
    currentUser.value = user;
    errorMessage.value = null;
  }

  /// Belirli bir rol ile hızlı giriş (Demo & Rol testi)
  void loginAsRole(UserRole role) {
    final user = allUsers.value.firstWhere(
      (u) => u.role == role,
      orElse: () => UserAccount(
        id: 'usr_${role.name}',
        fullName: '${role.displayName} Kullanıcısı',
        email: '${role.name}@filizora.com',
        role: role,
        approvalStatus: ApprovalStatus.approved,
        createdAt: DateTime.now(),
      ),
    );
    loginAsUser(user);
  }

  /// Yönetici: Kullanıcı başvurusunu onaylama
  void approveUser(String userId) {
    allUsers.value = allUsers.value.map((u) {
      if (u.id == userId) {
        return u.copyWith(approvalStatus: ApprovalStatus.approved);
      }
      return u;
    }).toList();

    if (currentUser.value?.id == userId) {
      currentUser.value = currentUser.value!.copyWith(
        approvalStatus: ApprovalStatus.approved,
      );
    }
  }

  /// Yönetici: Kullanıcı başvurusunu reddetme
  void rejectUser(String userId) {
    allUsers.value = allUsers.value.map((u) {
      if (u.id == userId) {
        return u.copyWith(approvalStatus: ApprovalStatus.rejected);
      }
      return u;
    }).toList();

    if (currentUser.value?.id == userId) {
      currentUser.value = currentUser.value!.copyWith(
        approvalStatus: ApprovalStatus.rejected,
      );
    }
  }

  /// Yerel Simülasyon: Yönetici Onayı Verme (Girişimci bekleme ekranı için)
  void simulateAdminApproval() {
    if (currentUser.value != null) {
      approveUser(currentUser.value!.id);
    }
  }

  /// Yerel Simülasyon: Yönetici Reddi
  void simulateAdminReject() {
    if (currentUser.value != null) {
      rejectUser(currentUser.value!.id);
    }
  }

  /// Oturumu Kapat
  void logout() {
    currentUser.value = null;
    errorMessage.value = null;
    hasIdeaSelection.value = true;
  }

  void dispose() {
    currentUser.dispose();
    selectedRole.dispose();
    hasIdeaSelection.dispose();
    isLoading.dispose();
    errorMessage.dispose();
    allUsers.dispose();
  }
}
