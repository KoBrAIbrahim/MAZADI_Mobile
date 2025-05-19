import 'package:application/constants/app_colors.dart';
import 'package:application/widgets/backgorund/auth_background.dart';
import 'package:flutter/material.dart';

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

    return AuthScaffold(
      showBottomBackground: true,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          top: height * 0.33,
          left: width * 0.07,
          right: width * 0.07,
          bottom: 30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إنشاء حساب',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(width: width * 0.3, height: 2, color: AppColors.primary),
            SizedBox(height: height * 0.03),

            _buildField(
              label: 'Full Name',
              hint: 'AAA BBB',
              icon: Icons.person,
            ),
            SizedBox(height: height * 0.015),

            _buildField(
              label: 'Phone',
              hint: '+00 000-0000-000',
              icon: Icons.phone,
            ),
            SizedBox(height: height * 0.015),

            _buildField(
              label: 'City',
              hint: 'رام الله',
              icon: Icons.location_city,
            ),
            SizedBox(height: height * 0.015),

            _buildField(
              label: 'Gender',
              hint: 'Female',
              icon: Icons.person_outline,
            ),
            SizedBox(height: height * 0.015),

            _buildField(
              label: 'Email',
              hint: 'Example@Gmail.com',
              icon: Icons.email,
            ),
            SizedBox(height: height * 0.015),

            _buildField(
              label: 'Password',
              hint: '**********',
              obscure: _obscurePassword,
              icon: Icons.lock,
              isPassword: true,
            ),
            SizedBox(height: height * 0.04),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
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
          ],
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
              suffixIcon:
                  isPassword
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
