import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:application/constants/app_colors.dart';
import 'package:application/models/user.dart';

class ChangePasswordPage extends StatefulWidget {
  final User user;

  const ChangePasswordPage({super.key, required this.user});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage>
    with TickerProviderStateMixin {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isCurrentVisible = false;
  bool isNewVisible = false;
  bool isConfirmVisible = false;
  bool isLoading = false;
  double passwordStrength = 0.0;
  String passwordStrengthText = "";

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _slideController.forward();

    newPasswordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength() {
    final password = newPasswordController.text;
    double strength = 0.0;
    String strengthText = "";

    if (password.isEmpty) {
      strength = 0.0;
      strengthText = "";
    } else if (password.length < 6) {
      strength = 0.2;
      strengthText = "password_strength_very_weak".tr();
    } else if (password.length < 8) {
      strength = 0.4;
      strengthText = "password_strength_weak".tr();
    } else {
      strength = 0.6;
      strengthText = "password_strength_medium".tr();

      if (RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
        strength = 0.8;
        strengthText = "password_strength_strong".tr();
      }

      if (RegExp(
            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])',
          ).hasMatch(password) &&
          password.length >= 10) {
        strength = 1.0;
        strengthText = "password_strength_very_strong".tr();
      }
    }

    setState(() {
      passwordStrength = strength;
      passwordStrengthText = strengthText;
    });
  }

  Color _getStrengthColor() {
    if (passwordStrength <= 0.4) return AppColors.error(context);
    if (passwordStrength <= 0.6) return AppColors.warning(context);
    if (passwordStrength <= 0.8) return AppColors.passwordMedium(context);
    return AppColors.success(context);
  }

  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'validation_current_password_required'.tr();
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'validation_new_password_required'.tr();
    }
    if (value.length < 8) {
      return 'validation_password_min_length'.tr();
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'validation_confirm_password_required'.tr();
    }
    if (value != newPasswordController.text) {
      return 'validation_passwords_not_match'.tr();
    }
    return null;
  }

  void _showAdvancedHelpDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Help Dialog",
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          ),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              backgroundColor: AppColors.cardBackground(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(
                  maxWidth: 400,
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: AppColors.helpDialogGradient(context),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient(context),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.help_center,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "help_dialog_title".tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "help_dialog_subtitle".tr(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHelpStep(
                              step: "1",
                              title: "help_step_1_title".tr(),
                              description: "help_step_1_description".tr(),
                              icon: Icons.login,
                            ),
                            _buildHelpStep(
                              step: "2",
                              title: "help_step_2_title".tr(),
                              description: "help_step_2_description".tr(),
                              icon: Icons.security,
                            ),
                            _buildHelpStep(
                              step: "3",
                              title: "help_step_3_title".tr(),
                              description: "help_step_3_description".tr(),
                              icon: Icons.speed,
                            ),
                            _buildHelpStep(
                              step: "4",
                              title: "help_step_4_title".tr(),
                              description: "help_step_4_description".tr(),
                              icon: Icons.verified,
                            ),
                            _buildHelpStep(
                              step: "5",
                              title: "help_step_5_title".tr(),
                              description: "help_step_5_description".tr(),
                              icon: Icons.save,
                              isLast: true,
                            ),

                            const SizedBox(height: 16),

                            // Security Tips
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.getSecurityTipsBackground(context),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.getSecurityTipsBorder(context),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.lightbulb,
                                        color: AppColors.getSecurityTipsIcon(context),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "security_tips_title".tr(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.getSecurityTipsText(context),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "security_tips_content".tr(),
                                    style: TextStyle(
                                      color: AppColors.getSecurityTipsText(context),
                                      fontSize: 12,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Footer
                    Container(
                      color: AppColors.cardBackground(context),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: AppColors.primaryLightDark(context),
                                  ),
                                ),
                              ),
                              child: Text(
                                "close".tr(),
                                style: TextStyle(
                                  color: AppColors.primaryLightDark(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                FocusScope.of(context).requestFocus(FocusNode());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryLightDark(context),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "start_now".tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpStep({
    required String step,
    required String title,
    required String description,
    required IconData icon,
    bool isLast = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryLightDark(context),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    step,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: AppColors.primaryLightDark(context).withOpacity(0.3),
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      color: AppColors.primaryLightDark(context),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _saveNewPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => isLoading = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text("password_updated_successfully".tr()),
            ],
          ),
          backgroundColor: AppColors.success(context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    required String? Function(String?) validator,
    bool showStrengthIndicator = false,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 1200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 16 : 14,
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight(context),
                blurRadius: isTablet ? 15 : 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            obscureText: !isVisible,
            validator: validator,
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              color: AppColors.textPrimary(context),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.cardBackground(context),
              prefixIcon: Icon(
                Icons.lock_outline,
                color: AppColors.primaryLightDark(context).withOpacity(0.7),
                size: isTablet ? 28 : 24,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.primaryLightDark(context).withOpacity(0.7),
                  size: isTablet ? 28 : 24,
                ),
                onPressed: onVisibilityToggle,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                borderSide: BorderSide(color: AppColors.divider(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                borderSide: BorderSide(
                  color: AppColors.primaryLightDark(context),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                borderSide: BorderSide(color: AppColors.error(context)),
              ),
              errorStyle: TextStyle(color: AppColors.error(context)),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 16,
                vertical: isTablet ? 24 : 20,
              ),
            ),
          ),
        ),
        if (showStrengthIndicator && newPasswordController.text.isNotEmpty) ...[
          SizedBox(height: isTablet ? 12 : 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: passwordStrength,
                  backgroundColor: AppColors.progressBackground(context),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getStrengthColor(),
                  ),
                  minHeight: isTablet ? 6 : 4,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Text(
                passwordStrengthText,
                style: TextStyle(
                  color: _getStrengthColor(),
                  fontWeight: FontWeight.w600,
                  fontSize: isTablet ? 14 : 12,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 1200;
    final horizontalPadding = isDesktop
        ? 40.0
        : isTablet
            ? 30.0
            : 20.0;
    final maxWidth = isDesktop ? 800.0 : double.infinity;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(isTablet ? 100 : 80),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient(context),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryLightDark(context).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isTablet ? 12 : 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(isTablet ? 14 : 10),
                  ),
                  child: Icon(
                    Icons.security,
                    color: Colors.white,
                    size: isTablet ? 28 : 20,
                  ),
                ),
                SizedBox(width: isTablet ? 16 : 12),
                Text(
                  "change_password_title".tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: isTablet ? 22 : 18,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: Container(
              margin: EdgeInsets.all(isTablet ? 12 : 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.white,
                  size: isTablet ? 22 : 18,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(isTablet ? 12 : 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.help_outline,
                    color: Colors.white,
                    size: isTablet ? 24 : 20,
                  ),
                  onPressed: _showAdvancedHelpDialog,
                ),
              ),
            ],
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Center(
            child: Container(
              width: maxWidth,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(horizontalPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Header Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isTablet ? 32 : 24),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient(context),
                          borderRadius: BorderRadius.circular(
                            isTablet ? 24 : 20,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryLightDark(context)
                                  .withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(isTablet ? 20 : 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.security,
                                size: isTablet ? 50 : 40,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: isTablet ? 20 : 16),
                            Text(
                              "protect_account_title".tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isTablet ? 30 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: isTablet ? 12 : 8),
                            Text(
                              "protect_account_subtitle".tr(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: isTablet ? 16 : 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isTablet ? 40 : 30),

                      // Current User Info
                      Container(
                        padding: EdgeInsets.all(isTablet ? 24 : 20),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground(context),
                          borderRadius: BorderRadius.circular(
                            isTablet ? 20 : 16,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowLight(context),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(isTablet ? 16 : 12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLightDark(context)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(
                                  isTablet ? 16 : 12,
                                ),
                              ),
                              child: Icon(
                                Icons.email_outlined,
                                color: AppColors.primaryLightDark(context),
                                size: isTablet ? 28 : 24,
                              ),
                            ),
                            SizedBox(width: isTablet ? 20 : 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "email_label".tr(),
                                    style: TextStyle(
                                      color: AppColors.textSecondary(context),
                                      fontSize: isTablet ? 14 : 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: isTablet ? 6 : 4),
                                  Text(
                                    widget.user.email,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isTablet ? 18 : 16,
                                      color: AppColors.textPrimary(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isTablet ? 40 : 30),

                      // Form Fields
                      _buildPasswordField(
                        controller: currentPasswordController,
                        label: "current_password_label".tr(),
                        isVisible: isCurrentVisible,
                        onVisibilityToggle: () =>
                            setState(() => isCurrentVisible = !isCurrentVisible),
                        validator: _validateCurrentPassword,
                      ),

                      SizedBox(height: isTablet ? 32 : 24),

                      _buildPasswordField(
                        controller: newPasswordController,
                        label: "new_password_label".tr(),
                        isVisible: isNewVisible,
                        onVisibilityToggle: () =>
                            setState(() => isNewVisible = !isNewVisible),
                        validator: _validateNewPassword,
                        showStrengthIndicator: true,
                      ),

                      SizedBox(height: isTablet ? 32 : 24),

                      _buildPasswordField(
                        controller: confirmPasswordController,
                        label: "confirm_new_password_label".tr(),
                        isVisible: isConfirmVisible,
                        onVisibilityToggle: () =>
                            setState(() => isConfirmVisible = !isConfirmVisible),
                        validator: _validateConfirmPassword,
                      ),

                      SizedBox(height: isTablet ? 30 : 20),

                      // Password Tips
                      Container(
                        padding: EdgeInsets.all(isTablet ? 20 : 16),
                        decoration: BoxDecoration(
                          color: AppColors.getPasswordTipsBackground(context),
                          borderRadius: BorderRadius.circular(
                            isTablet ? 16 : 12,
                          ),
                          border: Border.all(
                            color: AppColors.getPasswordTipsBorder(context),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.tips_and_updates,
                                  color: AppColors.getPasswordTipsIcon(context),
                                  size: isTablet ? 24 : 20,
                                ),
                                SizedBox(width: isTablet ? 12 : 8),
                                Text(
                                  "password_tips_title".tr(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.getPasswordTipsText(context),
                                    fontSize: isTablet ? 16 : 14,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isTablet ? 12 : 8),
                            Text(
                              "password_tips_content".tr(),
                              style: TextStyle(
                                color: AppColors.getPasswordTipsText(context),
                                fontSize: isTablet ? 14 : 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isTablet ? 50 : 40),

                      // Save Button
                      Container(
                        width: double.infinity,
                        height: isTablet ? 64 : 56,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient(context),
                          borderRadius: BorderRadius.circular(
                            isTablet ? 20 : 16,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryLightDark(context)
                                  .withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _saveNewPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                isTablet ? 20 : 16,
                              ),
                            ),
                          ),
                          child: isLoading
                              ? SizedBox(
                                  width: isTablet ? 28 : 24,
                                  height: isTablet ? 28 : 24,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.security,
                                      color: Colors.white,
                                      size: isTablet ? 28 : 24,
                                    ),
                                    SizedBox(width: isTablet ? 16 : 12),
                                    Text(
                                      "save_changes".tr(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isTablet ? 18 : 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      SizedBox(height: isTablet ? 30 : 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}