import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomDropdownItem extends StatelessWidget {
  final String text;

  const CustomDropdownItem({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
