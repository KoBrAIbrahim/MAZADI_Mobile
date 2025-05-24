import 'package:flutter/material.dart';
import 'package:application/constants/app_colors.dart';
import 'package:application/screens/Main_User_Pages.dart/dashboard.dart/dashboard_page.dart';
import 'package:application/widgets/main_page/lower_bar_pages.dart';
import 'package:application/widgets/Header/header_build.dart';
import 'package:easy_localization/easy_localization.dart';

class AboutAppPage extends StatefulWidget {
  const AboutAppPage({super.key});

  @override
  State<AboutAppPage> createState() => _AboutAppPageState();
}

class _AboutAppPageState extends State<AboutAppPage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _drawerHintController;
  late AnimationController _heroController;
  late AnimationController _cardController;
  late AnimationController _statsController;

  late Animation<Offset> _drawerHintAnimation;
  late Animation<double> _heroAnimation;
  late Animation<double> _cardFadeAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _statsAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = false;

  @override
  void initState() {
    super.initState();

    // Drawer hint animation
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

    // Hero animation
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _heroAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.elasticOut),
    );

    // Card animations
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _cardFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _cardController, curve: Curves.easeOut));

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.easeOutCubic),
    );

    // Stats animation
    _statsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _statsAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _statsController, curve: Curves.bounceOut),
    );

    // Scroll listener
    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showFloatingButton) {
        setState(() => _showFloatingButton = true);
      } else if (_scrollController.offset <= 200 && _showFloatingButton) {
        setState(() => _showFloatingButton = false);
      }
    });

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _heroController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _cardController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _statsController.forward();
  }

  @override
  void dispose() {
    _drawerHintController.dispose();
    _heroController.dispose();
    _cardController.dispose();
    _statsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
     bool isRTL = context.locale.languageCode == 'ar';

    return Scaffold(
      key: _scaffoldKey,
      drawer: AuctionDrawer(selectedItem: 'about'),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: buildHeader(screenSize, isTablet, 'about_app'.tr()),
      ),
      bottomNavigationBar: LowerBar(
        currentIndex: 0,
        onTap: (index) {
          // TODO: ربط التنقل حسب البنية
        },
      ),
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: AnimatedScale(
        scale: _showFloatingButton ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton(
          onPressed: () {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.keyboard_arrow_up),
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, AppColors.primary.withOpacity(0.02)],
              ),
            ),
          ),

          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Hero Section
                _buildHeroSection(screenSize),

                const SizedBox(height: 20),

                // Feature Cards
                _buildFeatureCards(),

                const SizedBox(height: 30),

                // Stats Section
                _buildStatsSection(),

                const SizedBox(height: 30),

                // App Info Card
                _buildAppInfoCard(),

                const SizedBox(height: 30),

                // Team Section
                _buildTeamSection(),

                const SizedBox(height: 30),

                // Contact Section
                _buildContactSection(),

                const SizedBox(height: 100),
              ],
            ),
          ),

          // Drawer Hint
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
                    isRTL
                        ? Icons.arrow_forward
                        : Icons.arrow_forward,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(Size screenSize) {
    return AnimatedBuilder(
      animation: _heroAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _heroAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.apps, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  'app_name'.tr(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'app_tagline'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureCards() {
    final features = [
      {
        'icon': Icons.gavel,
        'title': 'advanced_auctions'.tr(),
        'description': 'smart_auction_system'.tr(),
        'color': const Color(0xFF6366F1),
      },
      {
        'icon': Icons.security,
        'title': 'high_security'.tr(),
        'description': 'data_protection'.tr(),
        'color': const Color(0xFF10B981),
      },
      {
        'icon': Icons.speed,
        'title': 'ultra_speed'.tr(),
        'description': 'fast_experience'.tr(),
        'color': const Color(0xFFF59E0B),
      },
    ];

    return FadeTransition(
      opacity: _cardFadeAnimation,
      child: SlideTransition(
        position: _cardSlideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'key_features'.tr(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 15),
              ...features.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> feature = entry.value;

                return AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  margin: const EdgeInsets.only(bottom: 15),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: (feature['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            feature['icon'] as IconData,
                            color: feature['color'] as Color,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                feature['title'] as String,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                feature['description'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    final stats = [
      {'number': '1000+', 'label': 'active_users'.tr()},
      {'number': '500+', 'label': 'completed_auctions'.tr()},
      {'number': '24/7', 'label': 'technical_support'.tr()},
    ];

    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF667EEA).withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'app_statistics'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:
                    stats.map((stat) {
                      return Transform.scale(
                        scale: _statsAnimation.value,
                        child: Column(
                          children: [
                            Text(
                              stat['number']!,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              stat['label']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppInfoCard() {
    return FadeTransition(
      opacity: _cardFadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.info_outline,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  'app_information'.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'app_description'.tr(),
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Color(0xFF4B5563),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'app_version'.tr(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.group,
                  color: Color(0xFF8B5CF6),
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Text(
                'development_team'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'team_description'.tr(),
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                  const Color(0xFF06B6D4).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'best_app_award'.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F2937), Color(0xFF374151)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.support_agent, color: Colors.white, size: 24),
              const SizedBox(width: 15),
              Text(
                'contact_us'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'contact_description'.tr(),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildContactButton(Icons.email, 'email_contact'.tr()),
              _buildContactButton(Icons.phone, 'phone_contact'.tr()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(IconData icon, String label) {
    return InkWell(
      onTap: () {
        // Handle contact action
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
