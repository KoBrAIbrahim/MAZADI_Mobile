import 'package:application/widgets/backgorund/BlurredBackground.dart';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class ConfirmSignUpPage extends StatefulWidget {
  const ConfirmSignUpPage({super.key});

  @override
  State<ConfirmSignUpPage> createState() => _ConfirmSignUpPageState();
}

class _ConfirmSignUpPageState extends State<ConfirmSignUpPage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
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

                        // اللوجو
                        Center(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: width * 0.4,
                            fit: BoxFit.contain,
                          ),
                        ),

                        SizedBox(height: height * 0.04),

                        const Text(
                          'إنشاء حساب',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: width * 0.3,
                          height: 2,
                          color: AppColors.primary,
                        ),

                        SizedBox(height: height * 0.04),

                        _buildField(label: 'Full Name', hint: 'AAA BBB', icon: Icons.person),
                        const SizedBox(height: 16),
                        _buildField(label: 'Phone', hint: '+00 000-0000-000', icon: Icons.phone),
                        const SizedBox(height: 16),
                        _buildField(label: 'City', hint: 'رام الله', icon: Icons.location_city),
                        const SizedBox(height: 16),
                        _buildField(label: 'Gender', hint: 'Female', icon: Icons.person_outline),
                        const SizedBox(height: 16),
                        _buildField(label: 'Email', hint: 'Example@Gmail.com', icon: Icons.email),
                        const SizedBox(height: 16),
                        _buildField(
                          label: 'Password',
                          hint: '**********',
                          icon: Icons.lock,
                          obscure: _obscurePassword,
                          isPassword: true,
                        ),

                        const SizedBox(height: 30),

                        // زر التسجيل
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              // تنفيذ التسجيل
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Sign up',
                              style: TextStyle(
                                color: Colors.white,
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
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
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
