import 'package:application/screens/Main_User_Pages.dart/Profile_Page/edit_profile_sheet.dart';
import 'package:application/screens/Main_User_Pages.dart/dashboard.dart/dashboard_page.dart';
import 'package:application/widgets/Header/header_build.dart';
import 'package:flutter/material.dart';
import 'package:application/constants/app_colors.dart';
import 'package:application/models/user.dart';
import 'package:application/widgets/main_page/lower_bar_pages.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  final String? userId; // Optional userId parameter for API calls

  const ProfilePage({super.key, this.userId});

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

  // API related variables
  User? user;
  bool isLoading = true;
  String? errorMessage;

  late AnimationController _animationController;
  late AnimationController _tabAnimationController;
  late AnimationController _profileCardController;
  late AnimationController _tabContentController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _profileCardAnimation;
  late Animation<double> _tabContentScaleAnimation;

  final List<String> profileTabs = ["account_info".tr(), "credit_card".tr()];

  final List<IconData> profileTabIcons = [
    Icons.person_outline,
    Icons.credit_card_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchUserData();
  }

  void _initializeAnimations() {
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

  Future<void> _fetchUserData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Replace with your actual API endpoint
      final String apiUrl = 'https://your-api-endpoint.com/api/user/${widget.userId ?? 'current'}';
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          // Add your authorization headers here
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        
        setState(() {
          user = User.fromJson(userData);
          isLoading = false;
        });

        _debugUserProperties();
        _startAnimations();
      } else {
        setState(() {
          errorMessage = 'Failed to load user data: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading user data: $e';
        isLoading = false;
      });
    }
  }

  void _startAnimations() {
    _animationController.forward();
    _tabContentController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _profileCardController.forward();
      }
    });
  }

  Future<void> _refreshUserData() async {
    await _fetchUserData();
  }

  String _getSafeStringValue(dynamic value, {String fallback = 'N/A'}) {
    if (value == null) return fallback;

    if (value is String) {
      return value.isEmpty ? fallback : value;
    } else if (value is Map<String, dynamic>) {
      // Handle common map structures
      return value['name']?.toString() ??
          value['title']?.toString() ??
          value['value']?.toString() ??
          value.toString();
    } else {
      return value.toString();
    }
  }

  void _debugUserProperties() {
    if (user == null) return;
    
    print('=== User Properties Debug ===');
    print('firstName type: ${user!.firstName.runtimeType} - value: ${user!.firstName}');
    print('lastName type: ${user!.lastName.runtimeType} - value: ${user!.lastName}');
    print('email type: ${user!.email.runtimeType} - value: ${user!.email}');
    print('city type: ${user!.city.runtimeType} - value: ${user!.city}');
    print('phoneNumber type: ${user!.phoneNumber.runtimeType} - value: ${user!.phoneNumber}');
    print('gender type: ${user!.gender.runtimeType} - value: ${user!.gender}');
    print('==============================');
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
    bool isRTL = context.locale.languageCode == 'ar';

    return Scaffold(
      key: _scaffoldKey,
      drawer: AuctionDrawer(selectedItem: 'my_account'.tr()),
      backgroundColor: AppColors.scaffoldBackground(context),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            if (isLoading)
              _buildLoadingWidget(screenSize, isTablet, isDesktop)
            else if (errorMessage != null)
              _buildErrorWidget(screenSize, isTablet, isDesktop)
            else if (user != null)
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Center(
                    child: Container(
                      width: maxWidth,
                      child: RefreshIndicator(
                        onRefresh: _refreshUserData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              buildHeader(context, screenSize, isTablet, "my_account".tr()),
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
              ),

            // Drawer hint - only show when not loading
            if (!isLoading)
              Positioned(
                top: MediaQuery.of(context).size.height / 2 - 16,
                left: isRTL ? null : 0,
                right: isRTL ? 0 : null,
                child: SlideTransition(
                  position: _drawerHintAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 8,
                    ),
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
          ],
        ),
      ),
      bottomNavigationBar: LowerBar(
        currentIndex: currentIndexLowerBar,
        onTap: onLowerBarTap,
      ),
    );
  }

  Widget _buildLoadingWidget(Size screenSize, bool isTablet, bool isDesktop) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primaryLightDark(context),
            ),
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            "loading_profile".tr(),
            style: TextStyle(
              fontSize: isDesktop ? 18 : isTablet ? 16 : 14,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(Size screenSize, bool isTablet, bool isDesktop) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 40 : isTablet ? 30 : 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isDesktop ? 80 : isTablet ? 70 : 60,
              color: AppColors.errorColor(context),
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              "error_loading_profile".tr(),
              style: TextStyle(
                fontSize: isDesktop ? 24 : isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              errorMessage ?? "unknown_error".tr(),
              style: TextStyle(
                fontSize: isDesktop ? 16 : isTablet ? 14 : 12,
                color: AppColors.textSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 32 : 24),
            ElevatedButton.icon(
              onPressed: _refreshUserData,
              icon: const Icon(Icons.refresh),
              label: Text("retry".tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLightDark(context),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32 : 24,
                  vertical: isTablet ? 16 : 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedProfileCard(
    Size screenSize,
    bool isTablet,
    bool isDesktop,
  ) {
    final horizontalPadding = isDesktop
        ? 40.0
        : isTablet
            ? 30.0
            : 20.0;
    final cardPadding = isDesktop
        ? 32.0
        : isTablet
            ? 28.0
            : 24.0;
    final avatarSize = isDesktop
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
              color: AppColors.primaryLightDark(context).withOpacity(0.1),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.profileCardGradient(context),
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
                          AppColors.primaryLightDark(context).withOpacity(0.1),
                          AppColors.secondaryLightDark(context).withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient(context),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryLightDark(context).withOpacity(0.3),
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
                  Text(
                    "${_getSafeStringValue(user!.firstName)} ${_getSafeStringValue(user!.lastName)}",
                    style: TextStyle(
                      fontSize: isDesktop
                          ? 28
                          : isTablet
                              ? 24
                              : 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: isTablet ? 8 : 6),
                  Text(
                    _getSafeStringValue(user!.email),
                    style: TextStyle(
                      fontSize: isDesktop
                          ? 16
                          : isTablet
                              ? 14
                              : 12,
                      color: AppColors.textSecondary(context),
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: isTablet ? 28 : 24),

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
        'title': 'city'.tr(),
        'value': _getSafeStringValue(user!.city),
        'color': AppColors.infoGridCity(context),
      },
      {
        'icon': Icons.phone_outlined,
        'title': 'phone'.tr(),
        'value': _getSafeStringValue(user!.phoneNumber),
        'color': AppColors.infoGridPhone(context),
      },
      {
        'icon': Icons.person_pin_outlined,
        'title': 'gender'.tr(),
        'value': _getSafeStringValue(user!.gender),
        'color': AppColors.infoGridGender(context),
      },
      {
        'icon': Icons.email_outlined,
        'title': 'email'.tr(),
        'value': _getSafeStringValue(user!.email),
        'color': AppColors.infoGridEmail(context),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop
            ? 4
            : isTablet
                ? 2
                : 2,
        crossAxisSpacing: isTablet ? 16 : 12,
        mainAxisSpacing: isTablet ? 16 : 12,
        childAspectRatio: isDesktop
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
            color: AppColors.getInfoGridBackground(
              context,
              item['color'] as Color,
            ),
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            border: Border.all(
              color: AppColors.getInfoGridBorder(
                context,
                item['color'] as Color,
              ),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 8 : 6),
                decoration: BoxDecoration(
                  color: AppColors.getInfoGridIconBackground(
                    context,
                    item['color'] as Color,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: item['color'] as Color,
                  size: isDesktop
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
                  fontSize: isDesktop
                      ? 12
                      : isTablet
                          ? 11
                          : 10,
                  color: AppColors.textSecondary(context),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 4 : 2),
              Flexible(
                child: Text(
                  item['value'] as String,
                  style: TextStyle(
                    fontSize: isDesktop
                        ? 14
                        : isTablet
                            ? 13
                            : 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
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
    final horizontalPadding = isDesktop
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
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight(context),
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
                  vertical: isDesktop
                      ? 20
                      : isTablet
                          ? 16
                          : 12,
                  horizontal: isTablet ? 12 : 8,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.primaryGradient(context) : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryLightDark(context).withOpacity(0.3),
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
                      size: isDesktop
                          ? 28
                          : isTablet
                              ? 24
                              : 20,
                      color: isSelected ? Colors.white : AppColors.textSecondary(context),
                    ),
                    SizedBox(height: isTablet ? 8 : 6),
                    Text(
                      profileTabs[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textSecondary(context),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: isDesktop
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
    final horizontalPadding = isDesktop
        ? 40.0
        : isTablet
            ? 30.0
            : 20.0;
    final contentHeight = isDesktop
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
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight(context),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.tabContentGradient(context),
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
                  AppColors.primaryLightDark(context).withOpacity(0.1),
                  AppColors.secondaryLightDark(context).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_outline,
              size: isDesktop
                  ? 80
                  : isTablet
                      ? 70
                      : 60,
              color: AppColors.primaryLightDark(context),
            ),
          ),

          Text(
            "account_info".tr(),
            style: TextStyle(
              fontSize: isDesktop
                  ? 28
                  : isTablet
                      ? 24
                      : 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryLightDark(context),
              letterSpacing: 0.5,
            ),
          ),

          Text(
            "account_info_description".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop
                  ? 16
                  : isTablet
                      ? 14
                      : 12,
              color: AppColors.textSecondary(context),
              height: 1.5,
            ),
          ),

          _buildAdvancedActionButton(
            "edit_information".tr(),
            Icons.edit_outlined,
            screenSize,
            isTablet,
            isDesktop,
            AppColors.actionButtonBlue(context),
            onPressed: () {
              // Navigate to Edit Profile Page
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground(context),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: EditProfileSheet(user: user!),
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
                      AppColors.creditCardPurple(context).withOpacity(0.1),
                      AppColors.creditCardDeepPurple(context).withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.credit_card_outlined,
                  size: isDesktop
                      ? 32
                      : isTablet
                          ? 28
                          : 24,
                  color: AppColors.creditCardPurple(context),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "my_credit_card".tr(),
                      style: TextStyle(
                        fontSize: isDesktop
                            ? 20
                            : isTablet
                                ? 18
                                : 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.creditCardPurple(context),
                      ),
                    ),
                    Text(
                      "manage_payment_method".tr(),
                      style: TextStyle(
                        fontSize: isDesktop
                            ? 14
                            : isTablet
                                ? 12
                                : 11,
                        color: AppColors.textSecondary(context),
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
                      "${user!.firstName} ${user!.lastName}",
                  expiryDate: "12/26",
                  cardType: "Visa",
                  isDefault: true,
                  color: AppColors.creditCardGradient(context),
                  screenSize: screenSize,
                  isTablet: isTablet,
                  isDesktop: isDesktop,
                ),

                const Spacer(),

                // Edit Card Button
                _buildAdvancedActionButton(
                  "edit_card_data".tr(),
                  Icons.edit_outlined,
                  screenSize,
                  isTablet,
                  isDesktop,
                  AppColors.creditCardPurple(context),
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
    final cardHeight = isDesktop
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
            color: AppColors.shadowStrong(context),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.creditCardPurple(context).withOpacity(0.3),
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
                        fontSize: isDesktop
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
                          "default".tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isDesktop
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
                      fontSize: isDesktop
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
                            "card_holder_name".tr(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: isDesktop
                                  ? 12
                                  : isTablet
                                      ? 11
                                      : 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: isTablet ? 4 : 2),
                          Text(
                            "${_getSafeStringValue(user!.firstName)} ${_getSafeStringValue(user!.lastName)}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isDesktop
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
                          "expiry_date".tr(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: isDesktop
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
                            fontSize: isDesktop
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
            left: isDesktop
                ? 24
                : isTablet
                    ? 20
                    : 16,
            top: isDesktop
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
    final buttonHeight = isDesktop
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
        onPressed: onPressed ??
            () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground(context),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: EditProfileSheet(user: user!),
                ),
              );
            },
        icon: Icon(
          icon,
          color: Colors.white,
          size: isDesktop
              ? 24
              : isTablet
                  ? 22
                  : 20,
        ),
        label: Text(
          text,
          style: TextStyle(
            fontSize: isDesktop
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
      barrierLabel: "edit_credit_card".tr(),
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
              backgroundColor: AppColors.cardBackground(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: AppColors.creditCardDialogGradient(context),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: AppColors.creditCardGradient(context),
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
                          Text(
                            "edit_credit_card_data".tr(),
                            style: const TextStyle(
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
                              gradient: AppColors.creditCardGradient(context),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.creditCardPurple(context).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          "primary".tr(),
                                          style: const TextStyle(
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
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${user!.firstName} ${user!.lastName}",
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

                          Text(
                            "redirect_secure_card_edit".tr(),
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimary(context),
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
                                        color: AppColors.creditCardPurple(context),
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    "cancel".tr(),
                                    style: TextStyle(
                                      color: AppColors.creditCardPurple(context),
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
                                    backgroundColor: AppColors.creditCardPurple(context),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    "edit".tr(),
                                    style: const TextStyle(
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
        content: Row(
          children: [
            const Icon(Icons.edit, color: Colors.white),
            const SizedBox(width: 8),
            Text("redirect_card_edit".tr()),
          ],
        ),
        backgroundColor: AppColors.creditCardPurple(context),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}