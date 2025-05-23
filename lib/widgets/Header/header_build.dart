import 'package:application/constants/app_colors.dart';
import 'package:flutter/material.dart';

Widget buildHeader(Size screenSize, bool isTablet, String title) {
  final headerPadding = screenSize.width * 0.05;
  final logoSize = isTablet ? 40.0 : screenSize.width * 0.08;
  final titleSize = isTablet ? 28.0 : screenSize.width * 0.06;

  return Container(
    padding: EdgeInsets.all(headerPadding),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(screenSize.width * 0.02),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset('assets/images/logo.png', height: logoSize),
            ),
            SizedBox(width: screenSize.width * 0.04),
            Text(
              title, // ✅ تم التعديل هنا
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: screenSize.height * 0.02),
        Container(
          height: 3,
          width: screenSize.width * 0.15,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.secondary,
                AppColors.secondary.withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    ),
  );
}
