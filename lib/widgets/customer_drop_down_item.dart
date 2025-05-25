import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomDropdownItem extends StatelessWidget {
  final String text;

  const CustomDropdownItem({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            width: 0.5,
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          color: AppColors.primaryLightDark(context), // ✅ ديناميكي
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
