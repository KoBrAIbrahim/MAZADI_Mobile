import 'package:application/AdvancedStartupPage.dart';
import 'package:application/Router/app_route.dart';
import 'package:application/constants/app_colors.dart';
import 'package:application/models/ThemeProvider.dart';
import 'package:application/models/action.dart';
import 'package:application/models/bid.dart';
import 'package:application/models/post_2.dart';
import 'package:application/models/user.dart';
import 'package:application/setup/app_localization_setup.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

ThemeMode themeModeFromString(String mode) {
  switch (mode) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

String themeModeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    default:
      return 'system';
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/langs',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'), // مؤقتًا
      useOnlyLangCode: true,
      child: MaterialApp(
        home: const AdvancedStartupPage(), // ← إضافة MaterialApp لحل المشكلة
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}

class MazadiApp extends StatelessWidget {
  final String startRoute;

  const MazadiApp({super.key, this.startRoute = '/'});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: tr('app.title'),

      // الوضع العادي
      theme: ThemeData(
        fontFamily: 'Cairo',
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
      ),

      // الوضع الليلي
      darkTheme: ThemeData(
        fontFamily: 'Cairo',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF141414),
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryDark,
          secondary: AppColors.secondaryDark,
        ),
      ),

      themeMode: themeProvider.themeMode,

      // اللغات
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,

      // الراوتر مع startRoute
      routerConfig: appRouter(startRoute),
    );
  }
}

