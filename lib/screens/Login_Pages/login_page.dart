import 'package:application/API_Service/api.dart';
import 'package:application/main.dart';
import 'package:application/widgets/backgorund/BlurredBackground.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import '../../constants/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _rememberMe = false;
  bool _obscurePassword = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;


  Future<void> loginAndRemember() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text;

  if (email.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('please_fill_all_fields'.tr())),
    );
    return;
  }

  setState(() => _isLoading = true);

  final api = ApiService();
  final success = await api.login(email, password);

  setState(() => _isLoading = false);

  if (success) {
    final box = Hive.box('authBox');
    if (_rememberMe) {
      await box.put('is_logged_in', true);
      await box.put('logged_in_email', email);
    }

    context.go('/home_page');
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('login_failed'.tr())),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: height * 0.05),

                        Image.asset(
                          'assets/images/logo.png',
                          width: width * 0.4,
                          fit: BoxFit.contain,
                        ),

                        SizedBox(height: height * 0.04),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'login_title'.tr(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryLightDark(context),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        _buildTextField(
                          context,
                          Icons.mail_outline,
                          'hint_email'.tr(),
                          false,
                          _emailController
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          context,
                          Icons.lock_outline,
                          'hint_password'.tr(),
                          true,
                          _passwordController
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _rememberMe = !_rememberMe;
                                });
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color:
                                          _rememberMe
                                              ? AppColors.secondaryLightDark(
                                                context,
                                              )
                                              : Colors.transparent,
                                      border: Border.all(
                                        color: AppColors.secondaryLightDark(
                                          context,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child:
                                        _rememberMe
                                            ? const Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                            : null,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'remember_me'.tr(),
                                    style: TextStyle(
                                      color: theme.textTheme.bodyMedium?.color,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.go('/forget_password');
                              },
                              child: Text(
                                'forgot_password'.tr(),
                                style: TextStyle(
                                  color: AppColors.primaryLightDark(context),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryLightDark(
                                context,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _isLoading ? null : loginAndRemember,
                            child: Text(
                              'login_title'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'dont_have_account'.tr(),
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                context.go('/signup');
                              },
                              child: Text(
                                'sign_up'.tr(),
                                style: TextStyle(
                                  color: AppColors.primaryLightDark(context),
                                  fontWeight: FontWeight.bold,
                                ),
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

  Widget _buildTextField(
    BuildContext context,
    IconData icon,
    String hint,
    bool isPassword,
    TextEditingController controller
  ) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppColors.primaryLightDark(context)),
        hintText: hint,
        hintStyle: TextStyle(color: theme.hintColor),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        filled: true,
        fillColor: theme.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.primaryLightDark(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.primaryLightDark(context),
            width: 2,
          ),
        ),
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: theme.iconTheme.color,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
                : null,
      ),
    );
  }
}
