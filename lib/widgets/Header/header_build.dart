import 'package:application/constants/app_colors.dart';
import 'package:flutter/material.dart';

Widget buildHeader(BuildContext context, Size screenSize, bool isTablet, String title) {
  final headerPadding = screenSize.width * 0.05;
  final logoSize = isTablet ? 40.0 : screenSize.width * 0.08;
  final titleSize = isTablet ? 28.0 : screenSize.width * 0.06;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Container(
    padding: EdgeInsets.all(headerPadding),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      boxShadow: [
        BoxShadow(
          color: isDark ? Colors.black26 : Colors.black12,
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
                color: AppColors.secondaryLightDark(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset('assets/images/logo.png', height: logoSize),
            ),
            SizedBox(width: screenSize.width * 0.04),
            Text(
              title,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
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
                AppColors.secondaryLightDark(context),
                AppColors.secondaryLightDark(context).withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    ),
  );
}
