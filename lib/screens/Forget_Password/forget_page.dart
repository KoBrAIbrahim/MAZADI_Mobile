import 'package:application/constants/app_colors.dart';
import 'package:application/widgets/backgorund/BlurredBackground.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

class ForgetPasswordPage extends StatelessWidget {
  const ForgetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

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
                        SizedBox(height: height * 0.1),

                        // اللوجو
                        Image.asset(
                          'assets/images/logo.png',
                          width: width * 0.4,
                          fit: BoxFit.contain,
                        ),

                        SizedBox(height: height * 0.04),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'enter_email'.tr(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryLightDark(context),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // حقل البريد الإلكتروني
                        TextField(
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          decoration: InputDecoration(
                            hintText: 'example@gmail.com',
                            hintStyle: TextStyle(
                              color: theme.hintColor,
                            ),
                            prefixIcon: Icon(
                              Icons.mail_outline,
                              color: AppColors.primaryLightDark(context),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            filled: true,
                            fillColor: theme.cardColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primaryLightDark(context),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.primaryLightDark(context),
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // زر الإرسال
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              // تنفيذ عملية الإرسال
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondaryLightDark(context),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'send'.tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // زر الرجوع لتسجيل الدخول
                        TextButton(
                          onPressed: () {
                            context.go('/login');
                          },
                          child: Text(
                            'back_to_login'.tr(),
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                              fontWeight: FontWeight.w500,
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
}
