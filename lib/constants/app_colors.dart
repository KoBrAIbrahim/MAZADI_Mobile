import 'package:flutter/material.dart';

class AppColors {
  // Light mode colors
  static const Color primary = Color(0xFF328E6E);
  static const Color secondary = Color(0xFF67AE6E);

  // Dark mode colors
  static const Color primaryDark = Color(0xFF5DBEA3); // Seafoam green
  static const Color secondaryDark = Color(0xFF8ED1B8); // Light sage mint

  // Dynamic color getters based on theme mode
  static Color primaryLightDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? primaryDark : primary;

  static Color secondaryLightDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? secondaryDark
          : secondary;

  // Additional theme-aware colors
  static Color cardBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : Colors.white;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.black;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade300
          : Colors.grey.shade600;

  static Color divider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade700
          : Colors.grey.shade300;

  static Color shadowColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.black.withOpacity(0.3)
          : Colors.black.withOpacity(0.08);

  static Color lightBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? primaryDark.withOpacity(0.15)
          : primary.withOpacity(0.1);

  static Color inactiveIcon(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade400
          : Colors.grey.shade700;

  static Color drawerBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : Colors.white;

  static Color handleColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade600
          : Colors.grey.shade400;

  static Color chipBorder(BuildContext context, bool isSelected) {
    if (isSelected) {
      return primaryLightDark(context);
    }
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade400;
  }

  static Color chipText(BuildContext context, bool isSelected) {
    if (isSelected) {
      return primaryLightDark(context);
    }
    return textSecondary(context);
  }

  static Color chipBackground(BuildContext context, bool isSelected) {
    if (isSelected) {
      return primaryLightDark(context).withOpacity(0.15);
    }
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade200;
  }

  static Color timerGreen(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.green.shade300
          : Colors.green.shade400;

  /// Timer red color (end of countdown)
  static Color timerRed(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.red.shade400
          : Colors.red.shade600;

  /// Progress bar background color
  static Color progressBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade700
          : Colors.grey.shade300;

  /// Live badge background color
  static Color liveBadgeBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.red.shade600
          : Colors.red.shade700;

  /// Info card background color (for warnings, info, etc.)
  static Color getInfoCardBackground(BuildContext context, Color baseColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return baseColor.withOpacity(0.15);
    } else {
      // For light mode, create a very light tint of the base color
      return Color.lerp(Colors.white, baseColor, 0.1) ??
          baseColor.withOpacity(0.1);
    }
  }

  /// Info card border color (for warnings, info, etc.)
  static Color getInfoCardBorder(BuildContext context, Color baseColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? baseColor.withOpacity(0.4) : baseColor.withOpacity(0.3);
  }

  static Color scaffoldBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF121212)
          : Colors.grey.shade50;

  /// Surface variant for slightly different surfaces
  static Color surfaceVariant(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2C2C2C)
          : Colors.grey.shade100;

  // ========== GRADIENT HELPERS ==========

  /// Primary gradient (used for buttons, cards, etc.)
  static LinearGradient primaryGradient(BuildContext context) {
    return LinearGradient(
      colors: [primaryLightDark(context), secondaryLightDark(context)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // ========== SHADOW COLORS ==========

  /// Light shadow color
  static Color shadowLight(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.black.withOpacity(0.2)
          : Colors.black.withOpacity(0.05);

  // ========== STATUS COLORS ==========

  /// Warning color (orange/amber)
  static Color warning(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.orange.shade400
          : Colors.orange.shade600;

  /// Info color (blue)
  static Color info(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.blue.shade400
          : Colors.blue.shade600;

  static Color success(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.green.shade400
          : Colors.green.shade600;

  /// Error color (red)
  static Color error(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.red.shade400
          : Colors.red.shade600;

  /// Input field background color
  static Color inputFieldBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade900
          : Colors.grey.shade50;

  /// Image upload container background
  static Color imageUploadBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800
          : Colors.grey.shade100;

  /// Category chip background for unselected state
  static Color getCategoryChipBackground(
    BuildContext context,
    Color categoryColor,
  ) =>
      Theme.of(context).brightness == Brightness.dark
          ? categoryColor.withOpacity(0.15)
          : categoryColor.withOpacity(0.1);

  /// Subtle gradient for backgrounds
  static LinearGradient subtleGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors:
          isDark
              ? [const Color(0xFF121212), const Color(0xFF262626)]
              : [const Color(0xFFF5F5F5), const Color(0xFFE8E8E8)],
    );
  }

  static LinearGradient detailsPageGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors:
          isDark
              ? [Colors.black, const Color(0xFF0D1F20)]
              : [Colors.white, const Color(0xFFE0F2F1)],
    );
  }

  /// App bar background with transparency
  static Color getAppBarBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.black.withOpacity(0.7)
          : Colors.white.withOpacity(0.85);

  /// Blurred button background (for back button, etc.)
  static Color getBlurredButtonBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800.withOpacity(0.5)
          : Colors.white.withOpacity(0.7);

  /// Featured badge background color
  static Color featuredBadgeBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.red.shade600
          : Colors.red.shade600;

  /// Timer unit gradient background
  static LinearGradient timerUnitGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors:
          isDark
              ? [Colors.grey.shade900, Colors.grey.shade800]
              : [Colors.white, Colors.grey.shade100],
    );
  }

  /// Timer unit border color
  static Color timerUnitBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800
          : Colors.grey.shade300;

  /// Glass card background with transparency
  static Color getGlassCardBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade900.withOpacity(0.9)
          : Colors.white;

  /// Glassmorphism gradient for cards
  static LinearGradient glassMorphismGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors:
          isDark
              ? [
                Colors.grey.shade900.withOpacity(0.8),
                Colors.grey.shade800.withOpacity(0.8),
              ]
              : [
                Colors.white.withOpacity(0.9),
                Colors.grey.shade50.withOpacity(0.9),
              ],
    );
  }

  /// Glass border color
  static Color glassBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800
          : Colors.grey.shade200;

  /// Subtle badge background color
  static Color subtleBadgeBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800
          : Colors.grey.shade200;

  /// Pricing glass section gradient
  static LinearGradient pricingGlassGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors:
          isDark
              ? [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.08)]
              : [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.95)],
    );
  }

  /// Glass divider color for pricing section
  static Color glassDivider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withOpacity(0.1)
          : Colors.black.withOpacity(0.12);

  /// Strong shadow color (already exists but mentioned for completeness)
  static Color shadowStrong(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.black.withOpacity(0.5)
          : Colors.black.withOpacity(0.15);

  static Color passwordMedium(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.yellow.shade600
          : Colors.yellow.shade700;

  /// Help dialog background gradient
  static LinearGradient helpDialogGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors:
          isDark
              ? [cardBackground(context), primaryDark.withOpacity(0.05)]
              : [Colors.white, primary.withOpacity(0.05)],
    );
  }

  /// Security tips container background
  static Color getSecurityTipsBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.amber.shade900.withOpacity(0.2)
          : Colors.amber.shade50;

  /// Security tips container border
  static Color getSecurityTipsBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.amber.shade700.withOpacity(0.5)
          : Colors.amber.shade200;

  /// Security tips icon color
  static Color getSecurityTipsIcon(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.amber.shade400
          : Colors.amber.shade700;

  /// Security tips text color
  static Color getSecurityTipsText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.amber.shade300
          : Colors.amber.shade700;

  /// Password tips container background
  static Color getPasswordTipsBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.blue.shade900.withOpacity(0.2)
          : Colors.blue.shade50;

  /// Password tips container border
  static Color getPasswordTipsBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.blue.shade700.withOpacity(0.5)
          : Colors.blue.shade200;

  /// Password tips icon color
  static Color getPasswordTipsIcon(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.blue.shade400
          : Colors.blue.shade700;

  static Color getPasswordTipsText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.blue.shade300
          : Colors.blue.shade600;

  static Color passwordButtonBackground(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark 
        ? Colors.orange.shade500 
        : Colors.orange.shade600;

/// Password change button shadow color
static Color passwordButtonShadow(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark 
        ? Colors.orange.shade800.withOpacity(0.4) 
        : Colors.orange.withOpacity(0.3);

/// Info icon background in info cards
static Color getInfoIconBackground(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark 
        ? Colors.blue.shade800.withOpacity(0.3) 
        : Colors.blue.shade100;

        static Color creditCardPurple(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF9C27B0)
          : const Color(0xFF7B1FA2);

  /// Credit card deep purple color
  static Color creditCardDeepPurple(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF673AB7)
          : const Color(0xFF512DA8);

  /// Credit card gradient
  static LinearGradient creditCardGradient(BuildContext context) {
    return LinearGradient(
      colors: [creditCardPurple(context), creditCardDeepPurple(context)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Credit card dialog gradient
  static LinearGradient creditCardDialogGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [cardBackground(context), creditCardPurple(context).withOpacity(0.1)]
          : [Colors.white, creditCardPurple(context).withOpacity(0.05)],
    );
  }

  // ========== ACTION BUTTON COLORS ==========
  
  /// Action button blue color
  static Color actionButtonBlue(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2196F3)
          : const Color(0xFF1976D2);

  // ========== PROFILE CARD COLORS ==========
  
  /// Profile card gradient
  static LinearGradient profileCardGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [cardBackground(context), primaryDark.withOpacity(0.1)]
          : [Colors.white, primary.withOpacity(0.05)],
    );
  }

  /// Tab content gradient
  static LinearGradient tabContentGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [cardBackground(context), Colors.grey.shade900.withOpacity(0.5)]
          : [Colors.white, Colors.grey.shade50],
    );
  }

  // ========== INFO GRID COLORS ==========
  
  /// Info grid city color
  static Color infoGridCity(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF4CAF50)
          : const Color(0xFF388E3C);

  /// Info grid phone color
  static Color infoGridPhone(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2196F3)
          : const Color(0xFF1976D2);

  /// Info grid gender color
  static Color infoGridGender(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFFF9800)
          : const Color(0xFFF57C00);

  /// Info grid email color
  static Color infoGridEmail(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF9C27B0)
          : const Color(0xFF7B1FA2);

  /// Info grid background color
  static Color getInfoGridBackground(BuildContext context, Color baseColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? baseColor.withOpacity(0.15)
        : baseColor.withOpacity(0.1);
  }

  /// Info grid border color
  static Color getInfoGridBorder(BuildContext context, Color baseColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? baseColor.withOpacity(0.4)
        : baseColor.withOpacity(0.3);
  }

  /// Info grid icon background color
  static Color getInfoGridIconBackground(BuildContext context, Color baseColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? baseColor.withOpacity(0.2)
        : baseColor.withOpacity(0.15);
  }

  // ========== ABOUT PAGE COLORS ==========
  
  /// About page main background color
  static Color aboutPageBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF0F172A)
          : const Color(0xFFF8FAFC);

  /// About page background gradient
  static LinearGradient aboutPageGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [const Color(0xFF0F172A), primaryDark.withOpacity(0.05)]
          : [Colors.white, primary.withOpacity(0.02)],
    );
  }

  /// Hero section gradient
  static LinearGradient heroSectionGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: isDark
          ? [primaryDark, primaryDark.withOpacity(0.8)]
          : [primary, primary.withOpacity(0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // ========== FEATURE CARD COLORS ==========
  
  /// Feature card blue color
  static Color featureCardBlue(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF818CF8)
          : const Color(0xFF6366F1);

  /// Feature card green color
  static Color featureCardGreen(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF34D399)
          : const Color(0xFF10B981);

  /// Feature card orange color
  static Color featureCardOrange(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFFBBF24)
          : const Color(0xFFF59E0B);

  // ========== TEXT COLORS FOR ABOUT PAGE ==========
  
  /// About page section titles
  static Color aboutSectionTitle(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : const Color(0xFF1F2937);

  /// About page body text
  static Color aboutBodyText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade300
          : const Color(0xFF4B5563);

  /// About page sub text
  static Color aboutSubText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade400
          : const Color(0xFF374151);

  /// About page info container background
  static Color aboutInfoContainer(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800
          : const Color(0xFFF3F4F6);

  // ========== CARD COLORS ==========
  
  /// Card shadow color for about page
  static Color cardShadow(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.black.withOpacity(0.3)
          : Colors.black.withOpacity(0.05);

  // ========== STATS SECTION COLORS ==========
  
  /// Stats section gradient
  static LinearGradient statsGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: isDark
          ? [const Color(0xFF4C1D95), const Color(0xFF7C3AED)]
          : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Stats gradient shadow color
  static Color statsGradientShadow(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF4C1D95).withOpacity(0.4)
          : const Color(0xFF667EEA).withOpacity(0.3);

  // ========== TEAM SECTION COLORS ==========
  
  /// Team icon color
  static Color teamIconColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFA78BFA)
          : const Color(0xFF8B5CF6);

  /// Team award gradient
  static LinearGradient teamAwardGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: isDark
          ? [
              const Color(0xFF7C3AED).withOpacity(0.2),
              const Color(0xFF0EA5E9).withOpacity(0.2),
            ]
          : [
              const Color(0xFF8B5CF6).withOpacity(0.1),
              const Color(0xFF06B6D4).withOpacity(0.1),
            ],
    );
  }

  // ========== CONTACT SECTION COLORS ==========
  
  /// Contact section gradient
  static LinearGradient contactSectionGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: isDark
          ? [const Color(0xFF1E293B), const Color(0xFF334155)]
          : [const Color(0xFF1F2937), const Color(0xFF374151)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

   static Color supportPageBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF121212)
          : Colors.grey.shade50;

  /// Support page background gradient
  static LinearGradient supportPageGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [
              const Color(0xFF121212),
              primaryDark.withOpacity(0.1),
              secondaryDark.withOpacity(0.05),
            ]
          : [
              Colors.white,
              Colors.blue.shade50.withOpacity(0.3),
              Colors.purple.shade50.withOpacity(0.2),
            ],
    );
  }

  /// Support drawer hint gradient
  static LinearGradient supportDrawerHintGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: isDark
          ? [primaryDark.withOpacity(0.8), primaryDark]
          : [primary.withOpacity(0.8), primary],
    );
  }

  // ========== FAQ PAGE COLORS ==========
  
  /// FAQ header gradient
  static LinearGradient faqHeaderGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: isDark
          ? [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)]
          : [Colors.blue.shade400, Colors.blue.shade600],
    );
  }

  /// Support card border color
  static Color supportCardBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade700
          : Colors.grey.shade200;

  /// Support card shadow color
  static Color supportCardShadow(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.black.withOpacity(0.3)
          : Colors.grey.withOpacity(0.1);

  /// Support FAQ answer text color
  static Color supportAnswerText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade300
          : Colors.grey.shade700;

  // ========== CONTACT PAGE COLORS ==========
  
  /// Contact header gradient
  static LinearGradient contactHeaderGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: isDark
          ? [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)]
          : [Colors.purple.shade400, Colors.purple.shade600],
    );
  }

  /// Contact email color
  static Color contactEmailColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFEF4444)
          : Colors.red;

  /// Contact phone color
  static Color contactPhoneColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF10B981)
          : Colors.green;

  /// Contact hours color
  static Color contactHoursColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFF59E0B)
          : Colors.orange;

  /// Support message form shadow
  static Color supportMessageFormShadow(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.black.withOpacity(0.4)
          : Colors.grey.withOpacity(0.1);

  /// Support text field background
  static Color supportTextFieldBackground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800
          : Colors.grey.shade50;

  /// Support text field border
  static Color supportTextFieldBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade600
          : Colors.grey.shade300;

  // ========== FLOATING BUTTON COLORS ==========
  
  /// Support floating button inactive background
  static Color supportFloatingInactive(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.grey.shade800
          : Colors.grey.shade50;

  /// Support floating button inactive shadow
  static Color supportFloatingInactiveShadow(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.black.withOpacity(0.3)
          : Colors.grey.withOpacity(0.2);

  // ========== SUPPORT CATEGORY COLORS ==========
  
  /// Support category red color
  static Color supportCategoryRed(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFEF4444)
          : Colors.red.shade600;

  /// Support category blue color
  static Color supportCategoryBlue(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF3B82F6)
          : Colors.blue.shade600;

  /// Support category green color
  static Color supportCategoryGreen(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF10B981)
          : Colors.green.shade600;

  /// Support category orange color
  static Color supportCategoryOrange(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFF59E0B)
          : Colors.orange.shade600;
}
