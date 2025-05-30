import 'package:application/constants/app_colors.dart';
import 'package:application/screens/Main_User_Pages.dart/dashboard.dart/dashboard_page.dart';
import 'package:application/widgets/main_page/lower_bar_pages.dart';
import 'package:application/widgets/Header/header_build.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class TechnicalSupportPage extends StatefulWidget {
  const TechnicalSupportPage({super.key});

  @override
  State<TechnicalSupportPage> createState() => _TechnicalSupportPageState();
}

class _TechnicalSupportPageState extends State<TechnicalSupportPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();
  final TextEditingController _messageController = TextEditingController();

  late AnimationController _drawerHintController;
  late AnimationController _floatingController;
  late AnimationController _pulseController;
  late Animation<Offset> _drawerHintAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;

  int _currentPage = 0;
  bool _isExpanded = false;
  String _selectedCategory = '';

  List<FAQItem> _faqItems = [];

  // Remove context-dependent initialization
  List<SupportCategory> _getCategories() {
    return [
      SupportCategory(
        icon: Icons.bug_report,
        title: tr('support.categories.bug.title'),
        description: tr('support.categories.bug.description'),
        color: AppColors.supportCategoryRed(context),
        gradient: [AppColors.supportCategoryRed(context).withOpacity(0.8), AppColors.supportCategoryRed(context)],
      ),
      SupportCategory(
        icon: Icons.help_outline,
        title: tr('support.categories.help.title'),
        description: tr('support.categories.help.description'),
        color: AppColors.supportCategoryBlue(context),
        gradient: [AppColors.supportCategoryBlue(context).withOpacity(0.8), AppColors.supportCategoryBlue(context)],
      ),
      SupportCategory(
        icon: Icons.account_circle,
        title: tr('support.categories.account.title'),
        description: tr('support.categories.account.description'),
        color: AppColors.supportCategoryGreen(context),
        gradient: [AppColors.supportCategoryGreen(context).withOpacity(0.8), AppColors.supportCategoryGreen(context)],
      ),
      SupportCategory(
        icon: Icons.payment,
        title: tr('support.categories.payment.title'),
        description: tr('support.categories.payment.description'),
        color: AppColors.supportCategoryOrange(context),
        gradient: [AppColors.supportCategoryOrange(context).withOpacity(0.8), AppColors.supportCategoryOrange(context)],
      ),
    ];
  }

  @override
  void initState() {
    super.initState();

    _faqItems = [
      FAQItem(
        question: tr('support.faq.questions.q1'),
        answer: tr('support.faq.questions.a1'),
      ),
      FAQItem(
        question: tr('support.faq.questions.q2'),
        answer: tr('support.faq.questions.a2'),
      ),
      FAQItem(
        question: tr('support.faq.questions.q3'),
        answer: tr('support.faq.questions.a3'),
      ),
    ];

    _drawerHintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _drawerHintAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0),
    ).animate(
      CurvedAnimation(parent: _drawerHintController, curve: Curves.easeInOut),
    );

    _floatingAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _drawerHintController.dispose();
    _floatingController.dispose();
    _pulseController.dispose();
    _pageController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    bool isRTL = context.locale.languageCode == 'ar';

    return Scaffold(
      key: _scaffoldKey,
      drawer: AuctionDrawer(selectedItem: 'support'),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: buildHeader(context, screenSize, isTablet, tr('support.title')),
      ),
      backgroundColor: AppColors.supportPageBackground(context),
      bottomNavigationBar: LowerBar(
        currentIndex: 0,
        onTap: (index) {
          // TODO: implement navigation if needed
        },
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.supportPageGradient(context),
            ),
          ),

          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [_buildContactPage(), _buildFAQPage()],
          ),

          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                2,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: 15,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primaryLightDark(context)
                        : AppColors.primaryLightDark(context).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.supportDrawerHintGradient(context),
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(15),
                      right: Radius.circular(15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryLightDark(context).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isRTL ? Icons.arrow_forward : Icons.arrow_forward,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.faqHeaderGradient(context),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.quiz, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                tr('support.faq.title'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _faqItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final faq = _faqItems[index];
              return _buildFAQItem(faq, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(FAQItem faq, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 200 + (index * 100)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.supportCardBorder(context)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.supportCardShadow(context),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                  expansionTileTheme: ExpansionTileThemeData(
                    iconColor: AppColors.textPrimary(context),
                    collapsedIconColor: AppColors.textSecondary(context),
                  ),
                ),
                child: ExpansionTile(
                  title: Text(
                    faq.question,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        faq.answer,
                        style: TextStyle(
                          color: AppColors.supportAnswerText(context),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.contactHeaderGradient(context),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.contact_support,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                tr('support.contact.title'),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Contact methods
          _buildContactMethod(
            icon: Icons.email_outlined,
            title: tr('support.contact.methods.email.title'),
            subtitle: tr('support.contact.methods.email.value'),
            color: AppColors.contactEmailColor(context),
          ),
          const SizedBox(height: 16),
          _buildContactMethod(
            icon: Icons.phone_outlined,
            title: tr('support.contact.methods.phone.title'),
            subtitle: tr('support.contact.methods.phone.value'),
            color: AppColors.contactPhoneColor(context),
          ),
          const SizedBox(height: 16),
          _buildContactMethod(
            icon: Icons.access_time_outlined,
            title: tr('support.contact.methods.hours.title'),
            subtitle: tr('support.contact.methods.hours.value'),
            color: AppColors.contactHoursColor(context),
          ),

          const SizedBox(height: 30),

          // Quick message form
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cardBackground(context),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.supportMessageFormShadow(context),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('support.contact.message.title'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _messageController,
                  maxLines: 4,
                  style: TextStyle(color: AppColors.textPrimary(context)),
                  decoration: InputDecoration(
                    hintText: tr('support.contact.message.placeholder'),
                    hintStyle: TextStyle(color: AppColors.textSecondary(context)),
                    fillColor: AppColors.supportTextFieldBackground(context),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.supportTextFieldBorder(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.supportTextFieldBorder(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryLightDark(context)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Send message logic
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(tr('support.contact.message.success')),
                          backgroundColor: AppColors.primaryLightDark(context),
                        ),
                      );
                      _messageController.clear();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLightDark(context),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      tr('support.contact.message.button'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [
                    AppColors.primaryLightDark(context),
                    AppColors.primaryLightDark(context).withOpacity(0.8),
                  ],
                )
              : LinearGradient(
                  colors: [
                    AppColors.cardBackground(context),
                    AppColors.supportFloatingInactive(context),
                  ],
                ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? AppColors.primaryLightDark(context).withOpacity(0.3)
                  : AppColors.supportFloatingInactiveShadow(context),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : AppColors.textSecondary(context),
          size: 24,
        ),
      ),
    );
  }
}

class SupportCategory {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final List<Color> gradient;

  SupportCategory({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.gradient,
  });
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}