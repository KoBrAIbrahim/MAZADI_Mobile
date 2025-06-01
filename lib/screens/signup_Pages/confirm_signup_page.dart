import 'package:application/API_Service/api.dart';
import 'package:application/main.dart';
import 'package:application/widgets/backgorund/BlurredBackground.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../constants/app_colors.dart';

class ConfirmSignUpPage extends StatefulWidget {
  const ConfirmSignUpPage({super.key});

  @override
  State<ConfirmSignUpPage> createState() => _ConfirmSignUpPageState();
}

class _ConfirmSignUpPageState extends State<ConfirmSignUpPage> {
  bool _obscurePassword = true;
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fullUserData =
          GoRouterState.of(context).extra as Map<String, dynamic>;
      fullNameController.text =
          '${fullUserData['firstName']} ${fullUserData['lastName']}';
      phoneController.text = fullUserData['phone'];
      cityController.text = fullUserData['city'];
      genderController.text = fullUserData['gender'];
      emailController.text = fullUserData['email'];
      passwordController.text = fullUserData['password'];
    });
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    genderController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Map<String, dynamic> fullUserData =
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

                        Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: width * 0.4,
                            fit: BoxFit.contain,
                          ),
                        ),

                        SizedBox(height: height * 0.04),

                        Text(
                          'signup.title'.tr(),
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

                        _buildField(
                          label: 'signup.fields.fullName'.tr(),
                          hint: 'signup.hints.fullName'.tr(),
                          icon: Icons.person,
                          colorScheme: colorScheme,
                          controller: fullNameController,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'signup.fields.phone'.tr(),
                          hint: 'signup.hints.phone'.tr(),
                          icon: Icons.phone,
                          colorScheme: colorScheme,
                          controller: phoneController,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'signup.fields.city'.tr(),
                          hint: 'signup.hints.city'.tr(),
                          icon: Icons.location_city,
                          colorScheme: colorScheme,
                          controller: cityController,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'signup.fields.gender'.tr(),
                          hint: 'signup.hints.gender'.tr(),
                          icon: Icons.person_outline,
                          colorScheme: colorScheme,
                          controller: genderController,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'signup.fields.email'.tr(),
                          hint: 'signup.hints.email'.tr(),
                          icon: Icons.email,
                          colorScheme: colorScheme,
                          controller: emailController,
                        ),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'signup.fields.password'.tr(),
                          hint: 'signup.hints.password'.tr(),
                          icon: Icons.lock,
                          obscure: _obscurePassword,
                          isPassword: true,
                          colorScheme: colorScheme,
                          controller: passwordController,
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              final firstName =
                                  fullUserData['firstName']?.trim();
                              final lastName = fullUserData['lastName']?.trim();
                              final phone = phoneController.text.trim();
                              final city = cityController.text.trim();
                              final gender = genderController.text.trim();
                              final email = emailController.text.trim();
                              final password = passwordController.text.trim();

                              if (firstName == null ||
                                  firstName.isEmpty ||
                                  lastName == null ||
                                  lastName.isEmpty ||
                                  phone.isEmpty ||
                                  city.isEmpty ||
                                  gender.isEmpty ||
                                  email.isEmpty ||
                                  password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      "يرجى تعبئة جميع الحقول",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    margin: const EdgeInsets.all(16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                                return;
                              }

                              final user = {
                                "firstName": firstName,
                                "lastName": lastName,
                                "phone": phone,
                                "city": city,
                                "gender": gender,
                                "email": email,
                                "password": password,
                              };

                              final api = ApiService();
                              final response = await api.registerUser(user);

                              if (response != null) {
                                context.go('/home_page');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      "فشل في إنشاء الحساب. حاول مرة أخرى.",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    margin: const EdgeInsets.all(16),
                                  ),
                                );
                              }
                            },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'signup.button'.tr(),
                              style: TextStyle(
                                color: colorScheme.onSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required ColorScheme colorScheme,
    bool obscure = false,
    bool isPassword = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 110,
          child: Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorScheme.primary),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              suffixIcon:
                  isPassword
                      ? IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility_off : Icons.visibility,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      )
                      : null,
            ),
          ),
        ),
      ],
    );
  }
}
