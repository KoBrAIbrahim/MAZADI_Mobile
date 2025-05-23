import 'dart:async';

import 'package:application/constants/app_colors.dart';
import 'package:application/screens/Main_User_Pages.dart/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:application/models/post.dart';
import 'package:intl/intl.dart';

class DetailsPostPage extends StatefulWidget {
  final Post post;
  final PageType pageType;

  const DetailsPostPage({
    super.key,
    required this.post,
    required this.pageType, // القيمة الافتراضية
  });

  @override
  State<DetailsPostPage> createState() => _DetailsPostPageState();
}

class _DetailsPostPageState extends State<DetailsPostPage>
    with TickerProviderStateMixin {
  late final PageController _pageController = PageController();
  late final ScrollController _scrollController = ScrollController();

  bool _autoBidEnabled = false;
  TextEditingController _limitController = TextEditingController();

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

  // Timer-related variables for auction
  Duration _timeLeft = Duration(hours: 5, minutes: 23);
  late DateTime _auctionTargetDate;

  late final AnimationController _timerAnimController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void initState() {
    super.initState();
    _fadeAnimController.forward();
    _slideAnimController.forward();
    _currentBid = (widget.post.startPrice + 50.0).toStringAsFixed(1);
    _scrollController.addListener(_scrollListener);

    _auctionTargetDate = _getNextAuctionTarget();
    _updateTimeLeft();

    // Set up countdown update every second
    Timer.periodic(Duration(seconds: 1), (timer) {
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

  void _setupTimerUpdates() {
    _timerAnimController.addListener(() {
      if (_timerAnimController.isCompleted) {
        setState(() {
          if (_timeLeft.inSeconds > 0) {
            _timeLeft = Duration(seconds: _timeLeft.inSeconds - 1);
          }
        });
        _timerAnimController.reset();
        _timerAnimController.forward();
      }
    });
    _timerAnimController.forward();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? Colors.tealAccent : Colors.teal;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final subtleColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;

    final isMyWinner = widget.pageType == PageType.myWinners;
    final isMyPost = widget.pageType == PageType.myPosts;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.grey.shade100,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // خلفية متدرجة
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDark
                          ? [Colors.black, const Color(0xFF0D1F20)]
                          : [Colors.white, const Color(0xFFE0F2F1)],
                ),
              ),
            ),

            // المحتوى الرئيسي
            SafeArea(
              bottom: false,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      _buildSliverAppBar(context, accentColor, isDark),
                      SliverToBoxAdapter(
                        child: _buildContent(
                          context,
                          accentColor,
                          cardColor,
                          subtleColor,
                          isDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // نافذة المزايدة (لا تظهر في myPosts أو myWinners)
            if (_showBidForm && !isMyWinner && !isMyPost)
              _buildBidDialog(context, accentColor, isDark),

            // عرض الصورة بالحجم الكامل
            if (_isFullScreenImage) _buildFullScreenImage(),

            // زر الحفظ في حالة myPosts فقط
            if (isMyPost)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('تم حفظ التعديلات بنجاح!'),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    );
                    // يمكنك هنا إرسال التعديلات إلى الخادم
                  },
                  icon: const Icon(Icons.save_alt_rounded),
                  label: const Text('حفظ التعديلات'),
                  style: ElevatedButton.styleFrom(
                   backgroundColor: AppColors.primary,
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
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    Color accentColor,
    bool isDark,
  ) {
    return SliverAppBar(
      expandedHeight: 70,
      floating: true,
      pinned: true,
      backgroundColor:
          isDark
              ? Colors.black.withOpacity(0.7)
              : Colors.white.withOpacity(0.85),
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: FlexibleSpaceBar(
            title: Text(
              'Auction Details',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
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
            color:
                isDark
                    ? Colors.grey.shade800.withOpacity(0.5)
                    : Colors.white.withOpacity(0.7),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : Colors.black87,
            size: 16,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Color accentColor,
    Color cardColor,
    Color subtleColor,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageCarousel(accentColor, isDark),
        if (widget.pageType != PageType.myWinners &&
            widget.pageType != PageType.myPosts)
          _buildAuctionTimer(accentColor, isDark),

        Transform.translate(
          offset: const Offset(0, 0),
          child: _buildPostDetails(
            context,
            accentColor,
            cardColor,
            subtleColor,
            isDark,
          ),
        ),
        _buildSimilarItems(accentColor, isDark),
        SizedBox(height: 100),
      ],
    );
  }

  Widget _buildImageCarousel(Color accentColor, bool isDark) {
    return Container(
      height: 300,
      margin: EdgeInsets.only(top: 16),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.post.media.length,
            onPageChanged:
                (index) => setState(() => _currentImageIndex = index),
            itemBuilder:
                (context, index) => GestureDetector(
                  onTap: () => setState(() => _isFullScreenImage = true),
                  child: Hero(
                    tag: 'post-image-${widget.post.media[index]}',
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
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
                            Image.asset(
                              widget.post.media[index],
                              fit: BoxFit.cover,
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
                widget.post.media.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color:
                        _currentImageIndex == index
                            ? accentColor
                            : Colors.grey.withOpacity(0.5),
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
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
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
                    'Featured',
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

  Widget _buildAuctionTimer(Color accentColor, bool isDark) {
    final hours = _timeLeft.inHours;
    final minutes = _timeLeft.inMinutes % 60;
    final seconds = _timeLeft.inSeconds % 60;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimerUnit(
            hours.toString().padLeft(2, '0'),
            'HRS',
            accentColor,
            isDark,
          ),
          _buildTimerSeparator(isDark),
          _buildTimerUnit(
            minutes.toString().padLeft(2, '0'),
            'MIN',
            accentColor,
            isDark,
          ),
          _buildTimerSeparator(isDark),
          _buildTimerUnit(
            seconds.toString().padLeft(2, '0'),
            'SEC',
            accentColor,
            isDark,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimerUnit(
    String value,
    String label,
    Color accentColor,
    bool isDark, {
    bool isLast = false,
  }) {
    return Container(
      width: 60,
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? Colors.grey.shade900 : Colors.white,
            isDark ? Colors.grey.shade800 : Colors.grey.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          width: 1,
        ),
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
                      ? Colors.red
                      : (isDark ? Colors.white : Colors.black87),
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerSeparator(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildPostDetails(
    BuildContext context,
    Color accentColor,
    Color cardColor,
    Color subtleColor,
    bool isDark,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final isMyWinner = widget.pageType == PageType.myWinners;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900.withOpacity(0.9) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              gradient: LinearGradient(
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
              ),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(accentColor, subtleColor, textTheme, isDark),
                const SizedBox(height: 16),
                _buildAnimatedDivider(context, accentColor),
                const SizedBox(height: 20),

                if (widget.pageType == PageType.myWinners) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.person, color: accentColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Seller: ${widget.post.sellerName}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.phone_android, color: accentColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "WhatsApp: ${widget.post.sellerId}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  _buildDescription(accentColor, isDark),
                  const SizedBox(height: 20),
                  _buildPricingGlass(accentColor, isDark),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection(
    Color accentColor,
    Color subtleColor,
    TextTheme textTheme,
    bool isDark,
  ) {
    final isMyPost = widget.pageType == PageType.myPosts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.category_outlined, size: 14, color: accentColor),
                  const SizedBox(width: 6),
                  Text(
                    widget.post.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isMyPost)
          TextFormField(
            initialValue: widget.post.title,
            onChanged: (value) => setState(() => widget.post.title = value),
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter title...',
            ),
          )
        else
          ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [Theme.of(context).colorScheme.primary, accentColor],
                ).createShader(bounds),
            child: Text(
              widget.post.title,
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

  Widget _buildAnimatedDivider(BuildContext context, Color accentColor) {
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
                  Theme.of(context).colorScheme.primary,
                  accentColor,
                  accentColor.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
    );
  }

  Widget _buildDescription(Color accentColor, bool isDark) {
    final isMyPost = widget.pageType == PageType.myPosts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description_outlined, size: 18, color: accentColor),
            const SizedBox(width: 8),
            Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (isMyPost)
          TextFormField(
            initialValue: widget.post.description,
            onChanged:
                (value) => setState(() => widget.post.description = value),
            maxLines: null,
            minLines: 5,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 15,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: 'Enter description...',
              hintStyle: TextStyle(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
              ),
              filled: true,
              fillColor:
                  isDark
                      ? Colors.grey.shade800.withOpacity(0.3)
                      : Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accentColor),
              ),
            ),
          )
        else
          ...widget.post.description
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
                                    color: accentColor.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: 12,
                                    color: accentColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.4,
                                      color:
                                          isDark
                                              ? Colors.grey[300]
                                              : Colors.grey[800],
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

  Widget _buildPricingGlass(Color accentColor, bool isDark) {
    final isMyPost = widget.pageType == PageType.myPosts;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  isDark
                      ? [
                        Colors.white.withOpacity(0.05),
                        Colors.white.withOpacity(0.08),
                      ]
                      : [
                        Colors.white.withOpacity(0.8),
                        Colors.white.withOpacity(0.95),
                      ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  isDark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
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
                              label: "Start Price",
                              initialValue: widget.post.startPrice.toString(),
                              icon: Icons.monetization_on_outlined,
                              onChanged: (value) {
                                setState(
                                  () =>
                                      widget.post.startPrice =
                                          double.tryParse(value) ??
                                          widget.post.startPrice,
                                );
                              },
                              accentColor: accentColor,
                              isDark: isDark,
                            )
                            : _priceTile(
                              Icons.monetization_on_outlined,
                              'Start Price',
                              '${widget.post.startPrice} NIS',
                              isDark,
                              accentColor,
                            ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                  Expanded(
                    child:
                        isMyPost
                            ? _editablePriceField(
                              label: "Bid Step",
                              initialValue: widget.post.bid_step.toString(),
                              icon: Icons.trending_up_rounded,
                              onChanged: (value) {
                                setState(
                                  () =>
                                      widget.post.bid_step =
                                          double.tryParse(value) ??
                                          widget.post.bid_step,
                                );
                              },
                              accentColor: accentColor,
                              isDark: isDark,
                            )
                            : _priceTile(
                              Icons.trending_up_rounded,
                              'Bid Step',
                              '${widget.post.bid_step} NIS',
                              isDark,
                              accentColor,
                            ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Show post count as usual
              _priceTile(
                Icons.gavel_rounded,
                'Post # on Auction',
                '#${widget.post.numberOfOnAuction}',
                isDark,
                accentColor,
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
    required Color accentColor,
    required bool isDark,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: accentColor),
        prefixIcon: Icon(icon, color: accentColor),
        filled: true,
        fillColor:
            isDark
                ? Colors.grey.shade800.withOpacity(0.3)
                : Colors.grey.shade100,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor),
        ),
      ),
    );
  }

  Widget _priceTile(
    IconData icon,
    String label,
    String value,
    bool isDark,
    Color accentColor, {
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
            Icon(icon, size: 16, color: accentColor.withOpacity(0.8)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
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
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBidItem(
    Map<String, String> bid,
    Color accentColor,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withOpacity(0.1),
            ),
            child: Center(
              child: Text(
                bid['user']?.substring(0, 1) ?? 'U',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bid['user'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  bid['time'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            bid['amount'] ?? '',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarItems(Color accentColor, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  Icon(Icons.grid_view_rounded, size: 18, color: accentColor),
                  SizedBox(width: 8),
                  Text(
                    'Similar Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              itemCount: 5,
              itemBuilder:
                  (context, index) =>
                      _buildSimilarItem(index, accentColor, isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarItem(int index, Color accentColor, bool isDark) {
    final price = (widget.post.startPrice + (index * 50.0)).toStringAsFixed(1);
    return Container(
      width: 140,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          width: 1,
        ),
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
                image: AssetImage(
                  widget.post.media[index % widget.post.media.length],
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
                  'Similar Item ${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '$price NIS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidDialog(BuildContext context, Color accentColor, bool isDark) {
    final currentBid = double.parse(_currentBid);
    final bidStep = widget.post.bid_step;

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
                          color: isDark ? Colors.grey.shade900 : Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
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
                                  'Place Your Bid',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color:
                                        isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade700,
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
                                color:
                                    isDark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Current Bid:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              isDark
                                                  ? Colors.grey.shade300
                                                  : Colors.grey.shade700,
                                        ),
                                      ),
                                      Text(
                                        '$_currentBid NIS',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isDark
                                                  ? Colors.white
                                                  : Colors.black87,
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
                                        'Minimum Bid:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color:
                                              isDark
                                                  ? Colors.grey.shade300
                                                  : Colors.grey.shade700,
                                        ),
                                      ),
                                      Text(
                                        '${(currentBid + bidStep).toStringAsFixed(1)} NIS',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: accentColor,
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
                                    'Select Bid Amount',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isDark
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    children: [
                                      _buildBidOption(
                                        currentBid + bidStep,
                                        accentColor,
                                        isDark,
                                      ),
                                      SizedBox(width: 8),
                                      _buildBidOption(
                                        currentBid + (bidStep * 2),
                                        accentColor,
                                        isDark,
                                      ),
                                      SizedBox(width: 8),
                                      _buildBidOption(
                                        currentBid + (bidStep * 3),
                                        accentColor,
                                        isDark,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  TextField(
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                      color:
                                          isDark
                                              ? Colors.white
                                              : Colors.black87,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Custom Bid Amount (NIS)',
                                      labelStyle: TextStyle(color: accentColor),
                                      prefixIcon: Icon(
                                        Icons.attach_money_rounded,
                                        color: accentColor,
                                      ),
                                      filled: true,
                                      fillColor:
                                          isDark
                                              ? Colors.grey.shade800
                                              : Colors.grey.shade100,
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: accentColor.withOpacity(0.3),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: accentColor,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
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
                                      side: BorderSide(color: accentColor),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: accentColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _currentBid = (currentBid + bidStep)
                                            .toStringAsFixed(1);
                                        _showBidForm = false;
                                      });
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Your bid of $_currentBid NIS has been placed!',
                                          ),
                                          backgroundColor: accentColor,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          margin: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentColor,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Place Bid',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
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

  Widget _buildBidOption(double amount, Color accentColor, bool isDark) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _showBidForm = false;
            _currentBid = amount.toString();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Your bid of $amount NIS has been placed!'),
              backgroundColor: accentColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentColor.withOpacity(0.3), width: 1),
          ),
          child: Center(
            child: Text(
              '$amount NIS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ),
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
                tag: 'post-image-${widget.post.media[_currentImageIndex]}',
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Image.asset(
                    widget.post.media[_currentImageIndex],
                    fit: BoxFit.contain,
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
                  '${_currentImageIndex + 1}/${widget.post.media.length}',
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

class FullImagePage extends StatelessWidget {
  final String imagePath;

  const FullImagePage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.share, color: Colors.white),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.download, color: Colors.white),
            ),
            onPressed: () {},
          ),
          SizedBox(width: 8),
        ],
      ),
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: imagePath,
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}
