import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:application/constants/app_colors.dart';
import 'package:application/main.dart';
import 'package:application/models/ThemeProvider.dart';
import 'package:application/widgets/backgorund/logo_header.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

class AdvancedStartupPage extends StatefulWidget {
  const AdvancedStartupPage({super.key});

  @override
  State<AdvancedStartupPage> createState() => _AdvancedStartupPageState();
}

class _AdvancedStartupPageState extends State<AdvancedStartupPage>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late AnimationController _logoController;
  late AnimationController _loadingController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _loadingRotation;

  @override
  void initState() {
    super.initState();

    // Main animation controller
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Background animation controller
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    // Particle animation controller
    _particleController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    );

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Loading animation controller
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
    ));

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(_backgroundController);

    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _logoRotationAnimation = Tween<double>(
      begin: -0.2,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));

    _loadingRotation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _loadingController,
      curve: Curves.linear,
    ));
  }

Future<void> _startAnimations() async {
  // شغل الأنيميشن
  _logoController.forward();
  await Future.delayed(const Duration(milliseconds: 500));
  _mainController.forward();
  _loadingController.repeat();
  _backgroundController.repeat();
  _particleController.repeat();

  // تحميل التهيئة
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();
  final settingsBox = await Hive.openBox('settings');

  // إعداد اللغة
  final savedLangCode = settingsBox.get('language', defaultValue: 'ar');
  context.setLocale(Locale(savedLangCode));

  // تحميل الثيم وغيره (مثلاً من Hive أو أي شيء مخصص)

  // انتظار بسيط لأجل الانيميشن
  await Future.delayed(const Duration(seconds: 2));

  // تأكد إن الصفحة لسا شغالة
  if (!mounted) return;

  // الانتقال للتطبيق الرئيسي
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MazadiApp(),
      ),
    ),
  );
}


  @override
  void dispose() {
    _mainController.dispose();
    _backgroundController.dispose();
    _particleController.dispose();
    _logoController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Animated gradient background
          _buildAnimatedBackground(),

          // Floating particles
          _buildParticleLayer(),

          // Geometric shapes
          _buildGeometricShapes(width, height),

          // Centered logo with loading animation
          Center(
            child: _buildCenteredLogoWithLoading(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
                const Color(0xFF1A237E),
                const Color(0xFF283593),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                0.0,
                0.3 + 0.2 * math.sin(_backgroundAnimation.value),
                0.7 + 0.2 * math.cos(_backgroundAnimation.value),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildParticleLayer() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        return Stack(
          children: List.generate(15, (index) {
            final offset =
                _particleController.value * 2 * math.pi + index * 0.4;
            final size = 2.0 + index % 4;
            final opacity = 0.1 + (index % 3) * 0.1;

            return Positioned(
              left: MediaQuery.of(context).size.width * 0.1 +
                  (MediaQuery.of(context).size.width * 0.8) *
                      (0.5 + 0.4 * math.sin(offset)),
              top: MediaQuery.of(context).size.height * 0.1 +
                  (MediaQuery.of(context).size.height * 0.8) *
                      (0.5 + 0.3 * math.cos(offset + index)),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(opacity),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: size * 2,
                      spreadRadius: size * 0.5,
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildGeometricShapes(double width, double height) {
    return Stack(
      children: [
        Positioned(
          top: height * 0.15,
          right: -width * 0.2,
          child: AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _backgroundAnimation.value * 0.5,
                child: Container(
                  width: width * 0.6,
                  height: width * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: height * 0.2,
          left: -width * 0.15,
          child: AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Transform.rotate(
                angle: -_backgroundAnimation.value * 0.3,
                child: Container(
                  width: width * 0.4,
                  height: width * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCenteredLogoWithLoading() {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Loading ring animation
              AnimatedBuilder(
                animation: _loadingRotation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _loadingRotation.value,
                    child: CustomPaint(
                      size: const Size(180, 180),
                      painter: LoadingRingPainter(),
                    ),
                  );
                },
              ),
              
              // Secondary loading ring (counter-rotation)
              AnimatedBuilder(
                animation: _loadingRotation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: -_loadingRotation.value * 0.7,
                    child: CustomPaint(
                      size: const Size(160, 160),
                      painter: LoadingRingPainter(
                        strokeWidth: 2.0,
                        opacity: 0.3,
                      ),
                    ),
                  );
                },
              ),

              // Animated logo in the center
              AnimatedBuilder(
                animation: Listenable.merge([_logoScaleAnimation, _logoRotationAnimation]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Transform.rotate(
                      angle: _logoRotationAnimation.value,
                      child: const LogoHeader(textColor: Colors.white),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for the loading ring
class LoadingRingPainter extends CustomPainter {
  final double strokeWidth;
  final double opacity;

  LoadingRingPainter({
    this.strokeWidth = 3.0,
    this.opacity = 0.6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;

    // Create gradient colors
    final colors = [
      Colors.white.withOpacity(opacity),
      Colors.white.withOpacity(opacity * 0.8),
      Colors.white.withOpacity(opacity * 0.4),
      Colors.white.withOpacity(opacity * 0.1),
      Colors.transparent,
    ];

    final stops = [0.0, 0.3, 0.6, 0.8, 1.0];

    // Create gradient shader
    final gradient = SweepGradient(
      colors: colors,
      stops: stops,
      startAngle: 0,
      endAngle: math.pi * 2,
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw the loading ring
    canvas.drawCircle(center, radius, paint);

    // Add small dots at specific positions for extra visual appeal
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.8)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final angle = (i * math.pi * 2 / 3);
      final dotX = center.dx + (radius + strokeWidth / 2) * math.cos(angle);
      final dotY = center.dy + (radius + strokeWidth / 2) * math.sin(angle);
      canvas.drawCircle(Offset(dotX, dotY), strokeWidth / 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}