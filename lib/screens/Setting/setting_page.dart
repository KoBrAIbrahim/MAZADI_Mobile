import 'package:application/screens/Main_User_Pages.dart/dashboard.dart/dashboard_page.dart';
import 'package:application/widgets/main_page/lower_bar_pages.dart';
import 'package:flutter/material.dart';
import 'package:application/constants/app_colors.dart';
import 'package:application/widgets/Header/header_build.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:application/models/ThemeProvider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String selectedLanguage = 'ar';
  late AnimationController _drawerHintController;
  late Animation<Offset> _drawerHintAnimation;

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();

    _drawerHintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _drawerHintAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0),
    ).animate(
      CurvedAnimation(parent: _drawerHintController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadSavedLanguage() async {
    final box = await Hive.openBox('settings');
    String savedLang = box.get('language', defaultValue: 'ar');
    setState(() {
      selectedLanguage = savedLang;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.setLocale(Locale(savedLang));
    });
  }

  @override
  void dispose() {
    _drawerHintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    bool isRTL = context.locale.languageCode == 'ar';

    final textColor = isDark ? Colors.white : Colors.black87;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      key: _scaffoldKey,
      drawer: AuctionDrawer(selectedItem: 'settings'),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: buildHeader(context,screenSize, isTablet, 'settings.title'.tr()),
      ),
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              _buildSectionTitle('settings.appearance'.tr(), textColor),
              _buildDarkModeSwitch(isDarkMode, themeProvider),
              const SizedBox(height: 24),
              _buildSectionTitle('settings.language'.tr(), textColor),
              _buildLanguageSelector(),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 16,
            left: isRTL ? null : 0,
            right: isRTL ? 0 : null,
            child: SlideTransition(
              position: _drawerHintAnimation,
              child: GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLightDark(context).withOpacity(0.12),
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(10),
                      right: Radius.circular(10),
                    ),
                    border: Border.all(
                      color: AppColors.primaryLightDark(context).withOpacity(0.3),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryLightDark(context).withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
                  ),
                  child: Icon(
                    isRTL ? Icons.arrow_forward : Icons.arrow_forward,
                    size: 14,
                    color: AppColors.primaryLightDark(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: LowerBar(
        currentIndex: 0,
        onTap: (_) {},
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildDarkModeSwitch(bool isDarkMode, ThemeProvider provider) {
    return SwitchListTile(
      title: Text(
        'settings.dark_mode'.tr(),
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      value: isDarkMode,
      onChanged: (value) {
        provider.toggleTheme(value);
      },
      activeColor: AppColors.primaryLightDark(context),
    );
  }

  Widget _buildLanguageSelector() {
    return DropdownButtonFormField<String>(
      value: selectedLanguage,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: Theme.of(context)
            .cardColor
            .withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 1.0),
      ),
      dropdownColor: Theme.of(context).cardColor,
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      items: [
        DropdownMenuItem(value: 'ar', child: Text('settings.arabic'.tr())),
        DropdownMenuItem(value: 'en', child: Text('settings.english'.tr())),
      ],
      onChanged: (value) async {
        setState(() => selectedLanguage = value!);
        context.setLocale(Locale(value!));

        var box = await Hive.openBox('settings');
        await box.put('language', value);
      },
    );
  }
}
