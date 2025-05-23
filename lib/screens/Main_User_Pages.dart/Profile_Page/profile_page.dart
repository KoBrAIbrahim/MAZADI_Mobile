import 'package:application/screens/Main_User_Pages.dart/Profile_Page/edit_profile_sheet.dart';
import 'package:application/screens/Main_User_Pages.dart/dashboard.dart/dashboard_page.dart';
import 'package:application/widgets/Header/header_build.dart';
import 'package:flutter/material.dart';
import 'package:application/constants/app_colors.dart';
import 'package:application/models/user.dart';
import 'package:application/widgets/main_page/lower_bar_pages.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  int currentIndexLowerBar = 4;
  int currentProfileTabIndex = 0;
  late AnimationController _drawerHintController;
  late Animation<Offset> _drawerHintAnimation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late AnimationController _animationController;
  late AnimationController _tabAnimationController;
  late AnimationController _profileCardController;
  late AnimationController _tabContentController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _profileCardAnimation;
  late Animation<double> _tabContentScaleAnimation;

  final List<String> profileTabs = ["معلومات حسابي", "بطاقة إئتمان"];

  final List<IconData> profileTabIcons = [
    Icons.person_outline,
    Icons.credit_card_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _tabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _profileCardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _tabContentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _tabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _profileCardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _profileCardController,
        curve: Curves.easeOutBack,
      ),
    );

    _tabContentScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _tabContentController, curve: Curves.elasticOut),
    );

    _animationController.forward();
    _tabContentController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _profileCardController.forward();
    });

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
    _animationController.dispose();
    _tabAnimationController.dispose();
    _profileCardController.dispose();
    _tabContentController.dispose();
    _drawerHintController.dispose();
    super.dispose();
  }

  void onLowerBarTap(int index) {
    setState(() {
      currentIndexLowerBar = index;
    });
  }

  void onProfileTabTap(int index) {
    setState(() {
      currentProfileTabIndex = index;
    });

    // Animate tab content with scale effect
    _tabContentController.reset();
    _tabContentController.forward();

    // Original tab animation
    _tabAnimationController.forward().then((_) {
      _tabAnimationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isDesktop = screenSize.width > 1200;
    final maxWidth = isDesktop ? 1000.0 : double.infinity;

    return Scaffold(
      key: _scaffoldKey,
      drawer: AuctionDrawer(selectedItem: 'profile'),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: Container(
                    width: maxWidth,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          buildHeader(screenSize, isTablet, "حسابي"),
                          _buildAdvancedProfileCard(
                            screenSize,
                            isTablet,
                            isDesktop,
                          ),
                          _buildAdvancedTabSelector(
                            screenSize,
                            isTablet,
                            isDesktop,
                          ),
                          SizedBox(height: isTablet ? 24 : 16),
                          _buildAdvancedTabContent(
                            screenSize,
                            isTablet,
                            isDesktop,
                          ),
                          SizedBox(height: isTablet ? 32 : 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).size.height / 2 - 16, // أصغر شوي
              left: Directionality.of(context) == TextDirection.rtl ? null : 0,
              right: Directionality.of(context) == TextDirection.rtl ? 0 : null,
              child: SlideTransition(
                position: _drawerHintAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 8,
                  ), // أصغر
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
                    size: 14, // أصغر حجم
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: LowerBar(
        currentIndex: currentIndexLowerBar,
        onTap: onLowerBarTap,
      ),
    );
  }

  Widget _buildAdvancedProfileCard(
    Size screenSize,
    bool isTablet,
    bool isDesktop,
  ) {
    final horizontalPadding =
        isDesktop
            ? 40.0
            : isTablet
            ? 30.0
            : 20.0;
    final cardPadding =
        isDesktop
            ? 32.0
            : isTablet
            ? 28.0
            : 24.0;
    final avatarSize =
        isDesktop
            ? 120.0
            : isTablet
            ? 100.0
            : 80.0;

    return ScaleTransition(
      scale: _profileCardAnimation,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: isTablet ? 16 : 12,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, AppColors.primary.withOpacity(0.02)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(cardPadding),
              child: Column(
                children: [
                  // Enhanced Avatar Section
                  Container(
                    padding: EdgeInsets.all(isTablet ? 8 : 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.1),
                          AppColors.secondary.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        size: avatarSize * 0.5,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(height: isTablet ? 24 : 20),

                  // User Name
                  Text(
                    "${widget.user.firstName} ${widget.user.lastName}",
                    style: TextStyle(
                      fontSize:
                          isDesktop
                              ? 28
                              : isTablet
                              ? 24
                              : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: isTablet ? 8 : 6),

                  // User Email
                  Text(
                    widget.user.email,
                    style: TextStyle(
                      fontSize:
                          isDesktop
                              ? 16
                              : isTablet
                              ? 14
                              : 12,
                      color: Colors.grey[600],
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: isTablet ? 28 : 24),

                  // Enhanced Info Grid
                  _buildInfoGrid(screenSize, isTablet, isDesktop),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoGrid(Size screenSize, bool isTablet, bool isDesktop) {
    final items = [
      {
        'icon': Icons.location_city_outlined,
        'title': 'المدينة',
        'value': widget.user.city,
        'color': Colors.blue,
      },
      {
        'icon': Icons.phone_outlined,
        'title': 'الهاتف',
        'value': widget.user.phoneNumber,
        'color': Colors.green,
      },
      {
        'icon': Icons.person_pin_outlined,
        'title': 'الجنس',
        'value': widget.user.gender,
        'color': Colors.purple,
      },
      {
        'icon': Icons.email_outlined,
        'title': 'الايميل',
        'value': widget.user.email,
        'color': Colors.orange,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount:
            isDesktop
                ? 4
                : isTablet
                ? 2
                : 2,
        crossAxisSpacing: isTablet ? 16 : 12,
        mainAxisSpacing: isTablet ? 16 : 12,
        childAspectRatio:
            isDesktop
                ? 1.2
                : isTablet
                ? 1.5
                : 1.3,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: EdgeInsets.all(isTablet ? 16 : 12),
          decoration: BoxDecoration(
            color: (item['color'] as Color).withOpacity(0.05),
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            border: Border.all(
              color: (item['color'] as Color).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 8 : 6),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: item['color'] as Color,
                  size:
                      isDesktop
                          ? 24
                          : isTablet
                          ? 20
                          : 18,
                ),
              ),
              SizedBox(height: isTablet ? 8 : 6),
              Text(
                item['title'] as String,
                style: TextStyle(
                  fontSize:
                      isDesktop
                          ? 12
                          : isTablet
                          ? 11
                          : 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 4 : 2),
              Flexible(
                child: Text(
                  item['value'] as String,
                  style: TextStyle(
                    fontSize:
                        isDesktop
                            ? 14
                            : isTablet
                            ? 13
                            : 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdvancedTabSelector(
    Size screenSize,
    bool isTablet,
    bool isDesktop,
  ) {
    final horizontalPadding =
        isDesktop
            ? 40.0
            : isTablet
            ? 30.0
            : 20.0;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isTablet ? 16 : 12,
      ),
      padding: EdgeInsets.all(isTablet ? 8 : 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: List.generate(profileTabs.length, (index) {
          final isSelected = currentProfileTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onProfileTabTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.symmetric(horizontal: isTablet ? 4 : 2),
                padding: EdgeInsets.symmetric(
                  vertical:
                      isDesktop
                          ? 20
                          : isTablet
                          ? 16
                          : 12,
                  horizontal: isTablet ? 12 : 8,
                ),
                decoration: BoxDecoration(
                  gradient:
                      isSelected
                          ? LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                          : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                          : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      profileTabIcons[index],
                      size:
                          isDesktop
                              ? 28
                              : isTablet
                              ? 24
                              : 20,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                    SizedBox(height: isTablet ? 8 : 6),
                    Text(
                      profileTabs[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize:
                            isDesktop
                                ? 14
                                : isTablet
                                ? 13
                                : 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAdvancedTabContent(
    Size screenSize,
    bool isTablet,
    bool isDesktop,
  ) {
    final horizontalPadding =
        isDesktop
            ? 40.0
            : isTablet
            ? 30.0
            : 20.0;
    final contentHeight =
        isDesktop
            ? 450.0
            : isTablet
            ? 400.0
            : 350.0;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        height: contentHeight,
        margin: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, AppColors.secondary.withOpacity(0.02)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ScaleTransition(
              scale: _tabContentScaleAnimation,
              child: _buildTabContentWidget(screenSize, isTablet, isDesktop),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContentWidget(
    Size screenSize,
    bool isTablet,
    bool isDesktop,
  ) {
    switch (currentProfileTabIndex) {
      case 0:
        return _buildAccountInfoContent(screenSize, isTablet, isDesktop);
      case 1:
        return _buildCreditCardContent(screenSize, isTablet, isDesktop);
      default:
        return _buildAccountInfoContent(screenSize, isTablet, isDesktop);
    }
  }

  Widget _buildAccountInfoContent(
    Size screenSize,
    bool isTablet,
    bool isDesktop,
  ) {
    return Container(
      key: const ValueKey("account_info"),
      padding: EdgeInsets.all(
        isDesktop
            ? 40
            : isTablet
            ? 32
            : 24,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            padding: EdgeInsets.all(
              isDesktop
                  ? 24
                  : isTablet
                  ? 20
                  : 16,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.secondary.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              size:
                  isDesktop
                      ? 80
                      : isTablet
                      ? 70
                      : 60,
              color: AppColors.primary,
            ),
          ),

          Text(
            "معلومات حسابي",
            style: TextStyle(
              fontSize:
                  isDesktop
                      ? 28
                      : isTablet
                      ? 24
                      : 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),

          Text(
            "هنا يمكنك عرض وتعديل معلومات حسابك الشخصي وإدارة إعدادات الأمان",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize:
                  isDesktop
                      ? 16
                      : isTablet
                      ? 14
                      : 12,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),

          _buildAdvancedActionButton(
            "تعديل المعلومات",
            Icons.edit_outlined,
            screenSize,
            isTablet,
            isDesktop,
            Colors.blue,
            onPressed: () {
              // Navigate to Edit Profile Page
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder:
                    (_) => Container(
                      height: MediaQuery.of(context).size.height * 0.9,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: EditProfileSheet(user: widget.user),
                    ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCardContent(
    Size screenSize,
    bool isTablet,
    bool isDesktop,
  ) {
    return Container(
      key: const ValueKey("credit_card"),
      padding: EdgeInsets.all(
        isDesktop
            ? 40
            : isTablet
            ? 32
            : 24,
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(
                  isDesktop
                      ? 16
                      : isTablet
                      ? 14
                      : 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withOpacity(0.1),
                      Colors.deepPurple.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.credit_card_outlined,
                  size:
                      isDesktop
                          ? 32
                          : isTablet
                          ? 28
                          : 24,
                  color: Colors.purple,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "بطاقتي الائتمانية",
                      style: TextStyle(
                        fontSize:
                            isDesktop
                                ? 20
                                : isTablet
                                ? 18
                                : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                    Text(
                      "إدارة وسيلة الدفع الخاصة بك",
                      style: TextStyle(
                        fontSize:
                            isDesktop
                                ? 14
                                : isTablet
                                ? 12
                                : 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: isTablet ? 24 : 20),

          // Single Credit Card
          Expanded(
            child: Column(
              children: [
                _buildCreditCard(
                  cardNumber: "**** **** **** 1234",
                  cardHolder:
                      "${widget.user.firstName} ${widget.user.lastName}",
                  expiryDate: "12/26",
                  cardType: "Visa",
                  isDefault: true,
                  color: LinearGradient(
                    colors: [Colors.purple.shade600, Colors.purple.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  screenSize: screenSize,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                ),

                const Spacer(),

                // Edit Card Button
                _buildAdvancedActionButton(
                  "تعديل بيانات البطاقة",
                  Icons.edit_outlined,
                  screenSize,
                  isTablet,
                  isDesktop,
                  Colors.purple,
                  onPressed: () {
                    // Navigate to Edit Credit Card Page
                    _showEditCreditCardDialog();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCard({
    required String cardNumber,
    required String cardHolder,
    required String expiryDate,
    required String cardType,
    required bool isDefault,
    required LinearGradient color,
    required Size screenSize,
    required bool isTablet,
    required bool isDesktop,
  }) {
    final cardHeight =
        isDesktop
            ? 180.0
            : isTablet
            ? 160.0
            : 140.0;
    final cardWidth = double.infinity;

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 4),
      decoration: BoxDecoration(
        gradient: color,
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Pattern
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: isTablet ? 140 : 120,
              height: isTablet ? 140 : 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: isTablet ? 100 : 80,
              height: isTablet ? 100 : 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // Card Content
          Padding(
            padding: EdgeInsets.all(
              isDesktop
                  ? 24
                  : isTablet
                  ? 20
                  : 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row - Card Type and Default Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cardType,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:
                            isDesktop
                                ? 20
                                : isTablet
                                ? 18
                                : 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    if (isDefault)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 12 : 10,
                          vertical: isTablet ? 6 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            isTablet ? 12 : 10,
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "افتراضي",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                isDesktop
                                    ? 14
                                    : isTablet
                                    ? 12
                                    : 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),

                // Middle - Card Number
                Padding(
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 8 : 4),
                  child: Text(
                    cardNumber,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize:
                          isDesktop
                              ? 24
                              : isTablet
                              ? 22
                              : 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: isTablet ? 3 : 2,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),

                // Bottom Row - Cardholder and Expiry
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "اسم حامل البطاقة",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize:
                                  isDesktop
                                      ? 12
                                      : isTablet
                                      ? 11
                                      : 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: isTablet ? 4 : 2),
                          Text(
                            cardHolder,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  isDesktop
                                      ? 16
                                      : isTablet
                                      ? 14
                                      : 12,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "تاريخ الانتهاء",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize:
                                isDesktop
                                    ? 12
                                    : isTablet
                                    ? 11
                                    : 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: isTablet ? 4 : 2),
                        Text(
                          expiryDate,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                isDesktop
                                    ? 16
                                    : isTablet
                                    ? 14
                                    : 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Card Chip (Optional visual element)
          Positioned(
            left:
                isDesktop
                    ? 24
                    : isTablet
                    ? 20
                    : 16,
            top:
                isDesktop
                    ? 60
                    : isTablet
                    ? 50
                    : 40,
            child: Container(
              width: isTablet ? 32 : 28,
              height: isTablet ? 24 : 20,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedActionButton(
    String text,
    IconData icon,
    Size screenSize,
    bool isTablet,
    bool isDesktop,
    Color color, {
    VoidCallback? onPressed,
  }) {
    final buttonHeight =
        isDesktop
            ? 60.0
            : isTablet
            ? 56.0
            : 50.0;

    return Container(
      width: double.infinity,
      height: buttonHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed:
            onPressed ??
            () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder:
                    (_) => Container(
                      height: MediaQuery.of(context).size.height * 0.9,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(24),
                        ),
                      ),
                      child: EditProfileSheet(user: widget.user),
                    ),
              );
            },
        icon: Icon(
          icon,
          color: Colors.white,
          size:
              isDesktop
                  ? 24
                  : isTablet
                  ? 22
                  : 20,
        ),
        label: Text(
          text,
          style: TextStyle(
            fontSize:
                isDesktop
                    ? 18
                    : isTablet
                    ? 16
                    : 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
          ),
        ),
      ),
    );
  }

  void _showEditCreditCardDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Edit Credit Card",
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          ),
          child: FadeTransition(
            opacity: animation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.purple.withOpacity(0.05)],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade600,
                            Colors.purple.shade800,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "تعديل بيانات البطاقة الائتمانية",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Card Preview
                          Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.purple.shade600,
                                  Colors.purple.shade800,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Visa",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Text(
                                          "رئيسية",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Text(
                                    "**** **** **** 1234",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${widget.user.firstName} ${widget.user.lastName}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const Text(
                                        "12/26",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "ستتم إعادة توجيهك إلى صفحة تعديل بيانات البطاقة الآمنة",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: Colors.purple.shade600,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    "إلغاء",
                                    style: TextStyle(
                                      color: Colors.purple.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    // Navigate to actual edit credit card page
                                    _navigateToEditCreditCardPage();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple.shade600,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "تعديل",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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

  void _navigateToEditCreditCardPage() {
    // This is where you would navigate to your actual edit credit card page
    // For now, showing a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.edit, color: Colors.white),
            SizedBox(width: 8),
            Text("سيتم توجيهك إلى صفحة تعديل البطاقة"),
          ],
        ),
        backgroundColor: Colors.purple.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
