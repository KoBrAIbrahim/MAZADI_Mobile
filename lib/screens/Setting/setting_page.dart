import 'package:application/screens/Main_User_Pages.dart/dashboard.dart/dashboard_page.dart';
import 'package:application/widgets/main_page/lower_bar_pages.dart';
import 'package:flutter/material.dart';
import 'package:application/constants/app_colors.dart';
import 'package:application/widgets/Header/header_build.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isDarkMode = false;
  String selectedLanguage = 'ar';

  late AnimationController _drawerHintController;
  late Animation<Offset> _drawerHintAnimation;

  @override
  void initState() {
    super.initState();

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

  @override
  void dispose() {
    _drawerHintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
      int currentIndexLowerBar = 0;

    return Scaffold(
      key: _scaffoldKey,
      drawer: AuctionDrawer(selectedItem: 'settings'),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: buildHeader(screenSize, isTablet, 'الإعدادات'),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              _buildSectionTitle('المظهر'),
              _buildDarkModeSwitch(),
              const SizedBox(height: 24),
              _buildSectionTitle('اللغة'),
              _buildLanguageSelector(),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 16,
            left: Directionality.of(context) == TextDirection.rtl ? null : 0,
            right: Directionality.of(context) == TextDirection.rtl ? 0 : null,
            child: SlideTransition(
              position: _drawerHintAnimation,
              child: GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(10),
                      right: Radius.circular(10),
                    ),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_back_ios_new_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: LowerBar(
        currentIndex: currentIndexLowerBar,
        onTap: (index) {
          setState(() => currentIndexLowerBar = index);
          // هنا تقدر تضيف التنقل بين الصفحات حسب index
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDarkModeSwitch() {
    return SwitchListTile(
      title: const Text('الوضع الليلي'),
      value: isDarkMode,
      onChanged: (value) {
        setState(() => isDarkMode = value);
        // TODO: ربطه مع ThemeProvider أو AppState لتطبيق الوضع الليلي فعلياً
      },
      activeColor: AppColors.primary,
    );
  }

  Widget _buildLanguageSelector() {
    return DropdownButtonFormField<String>(
      value: selectedLanguage,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: const [
        DropdownMenuItem(value: 'ar', child: Text('العربية')),
        DropdownMenuItem(value: 'en', child: Text('English')),
      ],
      onChanged: (value) {
        setState(() => selectedLanguage = value!);
        // TODO: تطبيق تغيير اللغة على مستوى التطبيق
      },
    );
  }
}
