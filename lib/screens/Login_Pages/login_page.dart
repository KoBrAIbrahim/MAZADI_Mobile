import 'package:flutter/material.dart';
import '../../widgets/auth_background.dart';
import '../../constants/app_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: Stack(
        children: [
          AuthScaffold(
            showBottomBackground: true,
            child: Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: height * 0.35,
                  left: width * 0.07,
                  right: width * 0.07,
                  bottom: height * 0.1,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // العنوان على اليسار
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              fontSize: width * 0.06,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: width * 0.4, 
                            height: 2,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: height * 0.04),

                    _buildTextField(
                      Icons.mail_outline,
                      'Email',
                      false,
                    ),
                    SizedBox(height: height * 0.02),
                    _buildTextField(
                      Icons.lock_outline,
                      'Password',
                      true,
                    ),

                    const SizedBox(height: 8),

                    // تذكّرني ونسيت كلمة السر على نفس السطر
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remember Me',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ],
                    ),

                    SizedBox(height: height * 0.03),

                    Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6BC17B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: height * 0.02),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an Account?",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Sign up',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildTextField(IconData icon, String hint, bool isPassword) {
  return TextField(
    obscureText: isPassword,
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: Colors.grey),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      suffixIcon: isPassword
          ? const Icon(Icons.visibility_off_outlined, color: Colors.grey)
          : null,
    ),
  );
}

}
