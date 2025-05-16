import 'package:application/constants/app_colors.dart';
import 'package:application/widgets/auth_background.dart';
import 'package:flutter/material.dart';

class AccountSignUpPage extends StatefulWidget {
  const AccountSignUpPage({super.key});

  @override
  State<AccountSignUpPage> createState() => _AccountSignUpPageState();
}

class _AccountSignUpPageState extends State<AccountSignUpPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

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
            SizedBox(height: height * 0.04),

            // Email
            _buildInput(
              hint: 'Example@Gmail.com',
              icon: Icons.email_outlined,
            ),

            SizedBox(height: height * 0.03),

            // Password
            _buildInput(
              hint: '**********',
              icon: Icons.lock_outline,
              obscure: !_isPasswordVisible,
              isPassword: true,
              toggleVisibility: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),

            SizedBox(height: height * 0.03),

            // Confirm Password
            _buildInput(
              hint: '**********',
              icon: Icons.lock_outline,
              obscure: !_isConfirmVisible,
              isPassword: true,
              toggleVisibility: () {
                setState(() {
                  _isConfirmVisible = !_isConfirmVisible;
                });
              },
            ),

            SizedBox(height: height * 0.06),

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
                  'Submit',
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

  Widget _buildInput({
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool isPassword = false,
    VoidCallback? toggleVisibility,
  }) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
        suffixIcon: isPassword
            ? GestureDetector(
                onTap: toggleVisibility,
                child: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
              )
            : null,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}
