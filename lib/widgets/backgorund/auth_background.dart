import 'package:application/widgets/backgorund/logo_header.dart';
import 'package:flutter/material.dart';

class AuthScaffold extends StatelessWidget {
  final Widget child;
  final bool showBottomBackground;

  const AuthScaffold({
    Key? key,
    required this.child,
    this.showBottomBackground = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/top_background.png',
              width: width * 50,
              fit: BoxFit.contain,
            ),
          ),

          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: height * 0.03),
              child: const LogoHeader(),
            ),
          ),

          if (showBottomBackground)
            Positioned(
              bottom: 0,
              left: 0,
              child: Image.asset(
                'assets/images/down_background.png',
                width: width * 0.6,
                fit: BoxFit.contain,
              ),
            ),

          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
