import 'package:flutter/material.dart';

class LogoHeader extends StatelessWidget {
  final Color textColor;

  const LogoHeader({super.key, this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    final logoSize = width * 0.35; // جعلها أصغر قليلًا لتناسب شاشات أصغر
    final topPadding = height * 0.05; // 5% من ارتفاع الشاشة كمسافة من الأعلى
    final spacing = height * 0.02; // مسافة تحت الصورة مثلاً

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              width: logoSize,
              height: logoSize,
              fit: BoxFit.cover,
            ),
          ),          
        ],
      ),
    );
  }
}
