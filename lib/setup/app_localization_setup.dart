import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppLocalizationSetup {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
  }

  static Widget wrapWithLocalization(Widget app) {
    return EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/langs',
      fallbackLocale: const Locale('en'),
      child: app,
    );
  }
}
