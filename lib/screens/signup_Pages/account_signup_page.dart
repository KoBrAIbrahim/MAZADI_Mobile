import 'package:application/widgets/backgorund/BlurredBackground.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class AccountSignUpPage extends StatefulWidget {
  const AccountSignUpPage({super.key});

  @override
  State<AccountSignUpPage> createState() => _AccountSignUpPageState();
}

class _AccountSignUpPageState extends State<AccountSignUpPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Map<String, dynamic> userData =
        GoRouterState.of(context).extra as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: BlurredBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height * 0.05),

                        // Logo
                        Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: width * 0.4,
                            fit: BoxFit.contain,
                          ),
                        ),

                        SizedBox(height: height * 0.04),

                        // Title
                        Text(
                          'create_account'.tr(),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: width * 0.3,
                          height: 2,
                          color: colorScheme.primary,
                        ),

                        SizedBox(height: height * 0.04),

                        // Email
                        _buildInput(
                          controller: emailController,
                          hint: 'email_hint'.tr(),
                          icon: Icons.email_outlined,
                          colorScheme: colorScheme,
                        ),
                        SizedBox(height: height * 0.03),

                        // Password
                        _buildInput(
                          controller: passwordController,
                          hint: 'password_hint'.tr(),
                          icon: Icons.lock_outline,
                          obscure: !_isPasswordVisible,
                          isPassword: true,
                          toggleVisibility: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                          colorScheme: colorScheme,
                        ),
                        SizedBox(height: height * 0.03),

                        // Confirm Password
                        _buildInput(
                          controller: confirmPasswordController,
                          hint: 'confirm_password_hint'.tr(),
                          icon: Icons.lock_outline,
                          obscure: !_isConfirmVisible,
                          isPassword: true,
                          toggleVisibility: () {
                            setState(() {
                              _isConfirmVisible = !_isConfirmVisible;
                            });
                          },
                          colorScheme: colorScheme,
                        ),
                        SizedBox(height: height * 0.06),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              final email = emailController.text;
                              final password = passwordController.text;
                              final confirmPassword =
                                  confirmPasswordController.text;

                              if ([
                                email,
                                password,
                                confirmPassword,
                              ].any((v) => v.trim().isEmpty)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'يرجى تعبئة جميع الحقول',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    margin: EdgeInsets.all(16),
                                  ),
                                );
                                return;
                              }

                              // Trim values after validation
                              final trimmedEmail = email.trim();
                              final trimmedPassword = password.trim();
                              final trimmedConfirmPassword =
                                  confirmPassword.trim();

                              if (trimmedPassword != trimmedConfirmPassword) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'كلمات السر غير متطابقة',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    margin: EdgeInsets.all(16),
                                  ),
                                );
                                return;
                              }

                              final fullData = {
                                ...userData,
                                'email': trimmedEmail,
                                'password': trimmedPassword,
                              };

                              context.go(
                                '/confirm_signup_page',
                                extra: fullData,
                              );
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'submit'.tr(),
                              style: TextStyle(
                                color: colorScheme.onSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                context.go('/signup');
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: colorScheme.secondary,
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: colorScheme.onSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'back'.tr(),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool isPassword = false,
    VoidCallback? toggleVisibility,
    required ColorScheme colorScheme,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: colorScheme.primary),
        suffixIcon:
            isPassword
                ? GestureDetector(
                  onTap: toggleVisibility,
                  child: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                )
                : null,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}
