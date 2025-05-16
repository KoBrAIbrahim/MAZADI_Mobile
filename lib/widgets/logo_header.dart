import 'package:flutter/material.dart';

class LogoHeader extends StatelessWidget {
  final Color textColor;

  const LogoHeader({super.key, this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final logoSize = width * 0.5;

    return Column(
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
    );
  }
}
