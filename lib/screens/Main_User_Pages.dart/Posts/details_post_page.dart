import 'dart:async';

import 'package:application/API_Service/api.dart';
import 'package:application/constants/app_colors.dart';
import 'package:application/screens/Main_User_Pages.dart/home_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:application/models/post_2.dart';

class DetailsPostPage extends StatefulWidget {
  final String? postId; // Changed to optional postId instead of required Post
  final PageType pageType;

  const DetailsPostPage({super.key, this.postId, required this.pageType});

  @override
  State<DetailsPostPage> createState() => _DetailsPostPageState();
}

class _DetailsPostPageState extends State<DetailsPostPage>
    with TickerProviderStateMixin {
  late final PageController _pageController = PageController();
  late final ScrollController _scrollController = ScrollController();

  bool _autoBidEnabled = false;
  TextEditingController _limitController = TextEditingController();

  // API related variables
  Post? _post;
  bool _isLoading = true;
  String? _error;
  late final ApiService _apiService = ApiService();

  // Animation controllers
  late final AnimationController _fadeAnimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  late final AnimationController _slideAnimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  late final AnimationController _pulseAnimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);

  // Animations
  late final Animation<double> _fadeAnimation = Tween<double>(
    begin: 0.0,
    end: 1.0,
  ).animate(
    CurvedAnimation(parent: _fadeAnimController, curve: Curves.easeOut),
  );

  late final Animation<Offset> _slideAnimation = Tween<Offset>(
    begin: const Offset(0, 0.3),
    end: Offset.zero,
  ).animate(
    CurvedAnimation(parent: _slideAnimController, curve: Curves.easeOutCubic),
  );

  late final Animation<double> _pulseAnimation = Tween<double>(
    begin: 1.0,
    end: 1.1,
  ).animate(
    CurvedAnimation(parent: _pulseAnimController, curve: Curves.easeInOut),
  );

  int _currentImageIndex = 0;
  bool _isFullScreenImage = false;
  bool _showBidForm = false;
  String _currentBid = '';
  bool _isFavorite = false;
  bool _showFloatingAction = true;
  late Future<List<Post>> _futurePosts;
  // Timer-related variables for auction
  Duration _timeLeft = Duration(hours: 5, minutes: 23);
  late DateTime _auctionTargetDate;
  Timer? _countdownTimer;

  late final AnimationController _timerAnimController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void initState() {
    super.initState();
    _loadPostData();
    _scrollController.addListener(_scrollListener);
    _auctionTargetDate = _getNextAuctionTarget();
    _updateTimeLeft();
    _startCountdownTimer();
  }

  Future<void> _loadPostData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      if (widget.postId != null) {
        // Fetch specific post by ID
        _post = await _apiService.getPostById(int.parse(widget.postId!));
      } else {
        // Handle case where no postId is provided
        throw Exception('No post ID provided');
      }

      if (_post != null) {
        _currentBid = (_post!.startPrice + 50.0).toStringAsFixed(1);
        _fadeAnimController.forward();
        _slideAnimController.forward();
        _futurePosts = _apiService.getSimilarPosts(_post!.category);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _refreshPostData() async {
    await _loadPostData();
  }

  Future<void> _updatePost() async {
    if (_post == null) return;

    try {
      final updatedPost = await _apiService.updatePost(_post!);
      setState(() {
        _post = updatedPost;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('changes_saved_successfully'.tr()),
          backgroundColor: AppColors.success(context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving changes: ${e.toString()}'),
          backgroundColor: AppColors.error(context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );
    }
  }

  Future<void> _placeBid(double bidAmount) async {
    if (_post == null) return;

    try {
      await _apiService.placeBid(_post!.id, bidAmount);
      setState(() {
        _currentBid = bidAmount.toStringAsFixed(1);
        _showBidForm = false;
      });

      // Refresh post data to get updated bid information
      await _refreshPostData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'bid_placed_success'.tr(
              namedArgs: {
                'amount': bidAmount.toStringAsFixed(1),
                'currency': 'currency_nis'.tr(),
              },
            ),
          ),
          backgroundColor: AppColors.primaryLightDark(context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error placing bid: ${e.toString()}'),
          backgroundColor: AppColors.error(context),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      );
    }
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (now.isAfter(_auctionTargetDate)) {
        _auctionTargetDate = _getNextAuctionTarget();
      }
      setState(() {
        _updateTimeLeft();
      });
    });
  }

  void _updateTimeLeft() {
    final now = DateTime.now();
    _timeLeft = _auctionTargetDate.difference(now);
  }

  DateTime _getNextAuctionTarget() {
    final now = DateTime.now();
    final weekday = now.weekday; // Monday = 1, ..., Sunday = 7
    final currentMinutes = now.hour * 60 + now.minute;
    const targetHour = 18 * 60; // 6:00 PM

    bool after6PM = currentMinutes >= targetHour;

    if ((weekday == DateTime.thursday && after6PM) ||
        (weekday == DateTime.friday) ||
        (weekday == DateTime.saturday) ||
        (weekday == DateTime.sunday) ||
        (weekday == DateTime.monday && !after6PM)) {
      // Count to Monday 6 PM
      int daysUntilMonday = (DateTime.monday - weekday + 7) % 7;
      return DateTime(
        now.year,
        now.month,
        now.day,
      ).add(Duration(days: daysUntilMonday)).add(Duration(hours: 18));
    } else {
      // Count to Thursday 6 PM
      int daysUntilThursday = (DateTime.thursday - weekday + 7) % 7;
      return DateTime(
        now.year,
        now.month,
        now.day,
      ).add(Duration(days: daysUntilThursday)).add(Duration(hours: 18));
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels > 100 && _showFloatingAction) {
      setState(() => _showFloatingAction = false);
    } else if (_scrollController.position.pixels <= 100 &&
        !_showFloatingAction) {
      setState(() => _showFloatingAction = true);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _fadeAnimController.dispose();
    _slideAnimController.dispose();
    _pulseAnimController.dispose();
    _timerAnimController.dispose();
    _limitController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Theme.of(context).brightness == Brightness.dark
                ? Brightness.light
                : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground(context),
        extendBodyBehindAppBar: true,
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_post == null) {
      return _buildEmptyState();
    }

    return _buildContent(context);
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.detailsPageGradient(context),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primaryLightDark(context),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'loading_post_data'.tr(),
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.detailsPageGradient(context),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error(context),
            ),
            SizedBox(height: 16),
            Text(
              'error_loading_post'.tr(),
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPostData,
              icon: Icon(Icons.refresh),
              label: Text('retry_button'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLightDark(context),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.detailsPageGradient(context),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.textSecondary(context),
            ),
            SizedBox(height: 16),
            Text(
              'post_not_found'.tr(),
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
              label: Text('go_back_button'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLightDark(context),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final isMyWinner = widget.pageType == PageType.myWinners;
    final isMyPost = widget.pageType == PageType.myPosts;

    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.detailsPageGradient(context),
          ),
        ),

        // Main content
        SafeArea(
          bottom: false,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: RefreshIndicator(
                onRefresh: _refreshPostData,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildSliverAppBar(context),
                    SliverToBoxAdapter(child: _buildMainContent(context)),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Bid dialog (don't show in myPosts or myWinners)
        if (_showBidForm && !isMyWinner && !isMyPost) _buildBidDialog(context),

        // Full screen image viewer
        if (_isFullScreenImage) _buildFullScreenImage(),

        // Save button for myPosts only
        if (isMyPost)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: _updatePost,
              icon: const Icon(Icons.save_alt_rounded),
              label: Text('save_changes'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryLightDark(context),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

        // Floating action button for bidding
        if (!isMyWinner && !isMyPost && _showFloatingAction)
          Positioned(
            bottom: 20,
            right: 20,
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: FloatingActionButton.extended(
                onPressed: () => setState(() => _showBidForm = true),
                backgroundColor: AppColors.primaryLightDark(context),
                icon: Icon(Icons.gavel, color: Colors.white),
                label: Text(
                  'place_bid_button'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Continue with the rest of your existing widget methods...
  // (I'll keep the existing methods as they were, just replacing widget.post with _post!)

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 70,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.getAppBarBackground(context),
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: FlexibleSpaceBar(
            title: Text(
              'auction_details_title'.tr(),
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.getBlurredButtonBackground(context),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary(context),
            size: 16,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageCarousel(),
        if (widget.pageType != PageType.myWinners &&
            widget.pageType != PageType.myPosts)
          _buildAuctionTimer(),

        Transform.translate(
          offset: const Offset(0, 0),
          child: _buildPostDetails(context),
        ),
        _buildSimilarItems(),
        SizedBox(height: 100),
      ],
    );
  }

  // Replace all instances of widget.post with _post! in the remaining methods
  Widget _buildImageCarousel() {
    return Container(
      height: 300,
      margin: EdgeInsets.only(top: 16),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _post!.media.length,
            onPageChanged:
                (index) => setState(() => _currentImageIndex = index),
            itemBuilder:
                (context, index) => GestureDetector(
                  onTap: () => setState(() => _isFullScreenImage = true),
                  child: Hero(
                    tag: 'post-image-${_post!.media[index]}',
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowStrong(context),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              _post!.media[index],
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: AppColors.surfaceVariant(context),
                                  child: Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 48,
                                      color: AppColors.textSecondary(context),
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Gradient overlay for better readability
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.7),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          ),

          // Image indicator dots
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _post!.media.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color:
                        _currentImageIndex == index
                            ? AppColors.primaryLightDark(context)
                            : AppColors.textSecondary(context).withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),

          // Featured tag
          Positioned(
            top: 20,
            left: 28,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.featuredBadgeBackground(context),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowColor(context),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'featured_label'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Continue with remaining methods but replace widget.post with _post!
  // I'll include a few key methods here to show the pattern:

  Widget _buildPostDetails(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isMyWinner = widget.pageType == PageType.myWinners;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.getGlassCardBackground(context),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight(context),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.glassMorphismGradient(context),
              border: Border.all(
                color: AppColors.glassBorder(context),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(textTheme),
                const SizedBox(height: 16),
                _buildAnimatedDivider(context),
                const SizedBox(height: 20),

                if (widget.pageType == PageType.myWinners) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: AppColors.primaryLightDark(context),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${'seller_label'.tr()}: ${_post!.sellerName}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_android,
                        color: AppColors.primaryLightDark(context),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${'whatsapp_label'.tr()}: ${_post!.sellerId}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  _buildDescription(),
                  const SizedBox(height: 20),
                  _buildPricingGlass(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBidDialog(BuildContext context) {
    final currentBid = double.parse(_currentBid);
    final bidStep = _post!.bidStep;

    return GestureDetector(
      onTap: () => setState(() => _showBidForm = false),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        width: double.infinity,
        height: double.infinity,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              builder:
                  (context, value, child) => Transform.scale(
                    scale: value,
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground(context),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowStrong(context),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'place_bid_title'.tr(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: AppColors.textSecondary(context),
                                  ),
                                  onPressed:
                                      () =>
                                          setState(() => _showBidForm = false),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant(context),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'current_bid_label'.tr(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.textSecondary(
                                            context,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '$_currentBid ${'currency_nis'.tr()}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'minimum_bid_label'.tr(),
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.textSecondary(
                                            context,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '${(currentBid + bidStep).toStringAsFixed(1)} ${'currency_nis'.tr()}',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryLightDark(
                                            context,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'select_bid_amount'.tr(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary(context),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      _buildBidOption(currentBid + bidStep),
                                      SizedBox(width: 8),
                                      _buildBidOption(
                                        currentBid + (bidStep * 2),
                                      ),
                                      SizedBox(width: 8),
                                      _buildBidOption(
                                        currentBid + (bidStep * 3),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  TextField(
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      color: AppColors.textPrimary(context),
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'custom_bid_amount_hint'.tr(),
                                      labelStyle: TextStyle(
                                        color: AppColors.primaryLightDark(
                                          context,
                                        ),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.attach_money_rounded,
                                        color: AppColors.primaryLightDark(
                                          context,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: AppColors.inputFieldBackground(
                                        context,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: AppColors.primaryLightDark(
                                            context,
                                          ).withOpacity(0.3),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: AppColors.primaryLightDark(
                                            context,
                                          ),
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    onSubmitted: (value) {
                                      final bidAmount = double.tryParse(value);
                                      if (bidAmount != null &&
                                          bidAmount > currentBid) {
                                        _placeBid(bidAmount);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed:
                                        () => setState(
                                          () => _showBidForm = false,
                                        ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: AppColors.primaryLightDark(
                                          context,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'cancel_button'.tr(),
                                      style: TextStyle(
                                        color: AppColors.primaryLightDark(
                                          context,
                                        ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        () => _placeBid(currentBid + bidStep),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppColors.primaryLightDark(context),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'place_bid_button'.tr(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBidOption(double amount) {
    return Expanded(
      child: InkWell(
        onTap: () => _placeBid(amount),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.primaryLightDark(context).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryLightDark(context).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              '$amount ${'currency_nis'.tr()}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryLightDark(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuctionTimer() {
    final hours = _timeLeft.inHours;
    final minutes = _timeLeft.inMinutes % 60;
    final seconds = _timeLeft.inSeconds % 60;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimerUnit(hours.toString().padLeft(2, '0'), 'timer_hours'.tr()),
          _buildTimerSeparator(),
          _buildTimerUnit(
            minutes.toString().padLeft(2, '0'),
            'timer_minutes'.tr(),
          ),
          _buildTimerSeparator(),
          _buildTimerUnit(
            seconds.toString().padLeft(2, '0'),
            'timer_seconds'.tr(),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimerUnit(String value, String label, {bool isLast = false}) {
    return Container(
      width: 60,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        gradient: AppColors.timerUnitGradient(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight(context),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.timerUnitBorder(context), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color:
                  isLast && _timeLeft.inHours < 1
                      ? AppColors.error(context)
                      : AppColors.textPrimary(context),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSeparator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary(context),
        ),
      ),
    );
  }

  Widget _buildTitleSection(TextTheme textTheme) {
    final isMyPost = widget.pageType == PageType.myPosts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLightDark(context).withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 14,
                    color: AppColors.primaryLightDark(context),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _post!.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryLightDark(context),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.subtleBadgeBackground(context),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isMyPost)
          TextFormField(
            initialValue: _post!.title,
            onChanged: (value) => setState(() => _post!.title = value),
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'enter_title_hint'.tr(),
              hintStyle: TextStyle(color: AppColors.textSecondary(context)),
            ),
          )
        else
          ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [
                    AppColors.primaryLightDark(context),
                    AppColors.secondaryLightDark(context),
                  ],
                ).createShader(bounds),
            child: Text(
              _post!.title,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAnimatedDivider(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOutCubic,
      builder:
          (context, value, child) => Container(
            height: 2,
            width: MediaQuery.of(context).size.width * value,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryLightDark(context),
                  AppColors.secondaryLightDark(context),
                  AppColors.secondaryLightDark(context).withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
    );
  }

  Widget _buildDescription() {
    final isMyPost = widget.pageType == PageType.myPosts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.description_outlined,
              size: 18,
              color: AppColors.primaryLightDark(context),
            ),
            const SizedBox(width: 8),
            Text(
              'description_label'.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (isMyPost)
          TextFormField(
            initialValue: _post!.description,
            onChanged: (value) => setState(() => _post!.description = value),
            maxLines: null,
            minLines: 5,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontSize: 15,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: 'enter_description_hint'.tr(),
              hintStyle: TextStyle(color: AppColors.textSecondary(context)),
              filled: true,
              fillColor: AppColors.inputFieldBackground(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.divider(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.divider(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primaryLightDark(context),
                ),
              ),
            ),
          )
        else
          ..._post!.description
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList()
              .asMap()
              .entries
              .map(
                (entry) => TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 400 + entry.key * 100),
                  builder:
                      (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(20 * (1 - value), 0),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLightDark(
                                      context,
                                    ).withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: 12,
                                    color: AppColors.primaryLightDark(context),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.4,
                                      color: AppColors.textSecondary(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                ),
              ),
      ],
    );
  }

  Widget _buildPricingGlass() {
    final isMyPost = widget.pageType == PageType.myPosts;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.pricingGlassGradient(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.glassBorder(context),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row: Start Price + Bid Step
              Row(
                children: [
                  Expanded(
                    child:
                        isMyPost
                            ? _editablePriceField(
                              label: "start_price_label".tr(),
                              initialValue: _post!.startPrice.toString(),
                              icon: Icons.monetization_on_outlined,
                              onChanged: (value) {
                                setState(
                                  () =>
                                      _post!.startPrice =
                                          double.tryParse(value) ??
                                          _post!.startPrice,
                                );
                              },
                            )
                            : _priceTile(
                              Icons.monetization_on_outlined,
                              'start_price_label'.tr(),
                              '${_post!.startPrice} ${'currency_nis'.tr()}',
                            ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: AppColors.glassDivider(context),
                  ),
                  Expanded(
                    child:
                        isMyPost
                            ? _editablePriceField(
                              label: "bid_step_label".tr(),
                              initialValue: _post!.bidStep.toString(),
                              icon: Icons.trending_up_rounded,
                              onChanged: (value) {
                                setState(
                                  () =>
                                      _post!.bidStep =
                                          double.tryParse(value) ??
                                          _post!.bidStep,
                                );
                              },
                            )
                            : _priceTile(
                              Icons.trending_up_rounded,
                              'bid_step_label'.tr(),
                              '${_post!.bidStep} ${'currency_nis'.tr()}',
                            ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Show post count as usual
              _priceTile(
                Icons.gavel_rounded,
                'post_number_auction'.tr(),
                '#${_post!.numberOfOnAuction}',
                centerAlign: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _editablePriceField({
    required String label,
    required String initialValue,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: AppColors.textPrimary(context),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.primaryLightDark(context)),
        prefixIcon: Icon(icon, color: AppColors.primaryLightDark(context)),
        filled: true,
        fillColor: AppColors.inputFieldBackground(context),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primaryLightDark(context).withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryLightDark(context)),
        ),
      ),
    );
  }

  Widget _priceTile(
    IconData icon,
    String label,
    String value, {
    bool centerAlign = false,
  }) {
    return Column(
      crossAxisAlignment:
          centerAlign ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              centerAlign ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.primaryLightDark(context).withOpacity(0.8),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarItems() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight(context),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.grid_view_rounded,
                    size: 18,
                    color: AppColors.primaryLightDark(context),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'similar_items_title'.tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
            
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: FutureBuilder<List<Post>>(
              future: _futurePosts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return _buildFallbackSimilarItems();
                }
                final similarPosts =
                    snapshot.data!
                        .where(
                          (post) => post.id != _post!.id,
                        ) // ← استثني البوست الحالي
                        .toList();

                if (similarPosts.isEmpty) {
                  return _buildFallbackSimilarItems();
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  itemCount: _post!.media.isNotEmpty ? _post!.media.length : 1,

                  itemBuilder:
                      (context, index) =>
                          _buildSimilarItemFromPost(similarPosts[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackSimilarItems() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: BouncingScrollPhysics(),
      itemCount: _post!.media.isNotEmpty ? _post!.media.length : 1,

      itemBuilder: (context, index) => _buildSimilarItem(index),
    );
  }

  Widget _buildSimilarItem(int index) {
    final price = (_post!.startPrice + (index * 50.0)).toStringAsFixed(1);
    return Container(
      width: 140,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              image: DecorationImage(
                image: NetworkImage(_post!.media[index % _post!.media.length]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'similar_item_label'.tr()} ${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '$price ${'currency_nis'.tr()}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLightDark(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarItemFromPost(Post post) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => DetailsPostPage(
                  postId: post.id.toString(),
                  pageType: widget.pageType,
                ),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider(context), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Container(
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                image: DecorationImage(
                  image: NetworkImage(
                    post.media.isNotEmpty ? post.media[0] : '',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${post.startPrice.toStringAsFixed(1)} ${'currency_nis'.tr()}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryLightDark(context),
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

  Widget _buildFullScreenImage() {
    return GestureDetector(
      onTap: () => setState(() => _isFullScreenImage = false),
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Image Viewer
            Center(
              child: Hero(
                tag: 'post-image-${_post!.media[_currentImageIndex]}',
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Image.network(
                    _post!.media[_currentImageIndex],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.white54,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Close button
            Positioned(
              top: 40,
              right: 16,
              child: GestureDetector(
                onTap: () => setState(() => _isFullScreenImage = false),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),

            // Image Counter
            Positioned(
              top: 40,
              left: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${_post!.media.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
