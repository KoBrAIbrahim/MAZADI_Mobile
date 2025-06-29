import 'dart:async';
import 'package:application/API_Service/api.dart';
import 'package:application/constants/app_colors.dart';
import 'package:application/screens/Main_User_Pages.dart/Posts/details_post_page.dart';
import 'package:application/screens/Main_User_Pages.dart/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../../models/post_2.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

// Add your AppColors class

class PostCard extends StatefulWidget {
  final Post post;
  final PageType pageType;

  const PostCard({super.key, required this.post, required this.pageType});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  // State variables
  int currentImageIndex = 0;
  bool isLiked = false;
  Duration _timeRemaining = Duration.zero;
  late DateTime _targetDate;
  late Timer _timer;

  // Controllers
  late PageController _pageController;
  late TabController _tabController;

  // Animation controllers
  late AnimationController _likeAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _gradientAnimationController;

  // Animations
  late Animation<double> _pulseAnimation;
  late Animation<AlignmentGeometry> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _initializeTimer();
    initializeInterestState();
    isLiked = widget.post.isFav;
  }
Future<void> initializeInterestState() async {
  final api = ApiService();

  final userData = await api.getCurrentUser();
  
  final userId = userData?['id'];
  final tokenBox = await Hive.openBox('authBox');
  final token = tokenBox.get('access_token');

  if (userId == null || token == null) return;

  try {
    final interestedPosts = await api.getInterestedPosts(
      userId: userId,
      token: token,
    );

    final interestedPostIds = interestedPosts.map((e) => e.id).toList();
    final liked = interestedPostIds.contains(widget.post.id);

    if (mounted) {
      setState(() {
        isLiked = liked;
        widget.post.isFav = liked;
      });
    }
  } catch (e) {
    print('Error loading interest data: $e');
  }
}

  void _initializeControllers() {
    isLiked = widget.post.isFav;
    _pageController = PageController(viewportFraction: 1.0);
    _tabController = TabController(
      length: widget.post.media.length,
      vsync: this,
    );

    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _gradientAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _tabController.addListener(() {
      if (mounted) {
        setState(() {
          currentImageIndex = _tabController.index;
        });
      }
    });
  }

  void _initializeAnimations() {
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _gradientAnimation = AlignmentTween(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(
      CurvedAnimation(
        parent: _gradientAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _initializeTimer() {
    _updateTargetDate();
    _startTimer();
  }

  void _updateTargetDate() {
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    final currentTime = TimeOfDay.fromDateTime(now);
    final nowMinutes = currentTime.hour * 60 + currentTime.minute;
    const thresholdMinutes = 18 * 60; // 6:00 PM
    final isAfter6PM = nowMinutes >= thresholdMinutes;

    DateTime nextTarget;

    if ((currentWeekday == DateTime.thursday && isAfter6PM) ||
        (currentWeekday == DateTime.friday) ||
        (currentWeekday == DateTime.saturday) ||
        (currentWeekday == DateTime.sunday) ||
        (currentWeekday == DateTime.monday && !isAfter6PM)) {
      // Countdown to Monday 6:00 PM
      final daysUntilMonday = (DateTime.monday - currentWeekday + 7) % 7;
      nextTarget = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(Duration(days: daysUntilMonday)).add(const Duration(hours: 18));
    } else {
      // Countdown to Thursday 6:00 PM
      final daysUntilThursday = (DateTime.thursday - currentWeekday + 7) % 7;
      nextTarget = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(Duration(days: daysUntilThursday)).add(const Duration(hours: 18));
    }

    _targetDate = nextTarget;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (now.isAfter(_targetDate)) {
        _updateTargetDate();
      }
      if (mounted) {
        setState(() {
          _timeRemaining = _targetDate.difference(now);
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _likeAnimationController.dispose();
    _pulseAnimationController.dispose();
    _gradientAnimationController.dispose();
    _tabController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _onLike() {
    HapticFeedback.mediumImpact();
    _toggleInterest();
  }

  void _onImageTap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => FractionallySizedBox(
            heightFactor: 0.8,
            child: DetailsPostPage(pageType: widget.pageType,postId: "${widget.post.id}",),
          ),
    );
  }

  // Utility methods
  String _formatTimeRemaining() {
    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;

    final parts = <String>[];
    if (days > 0) parts.add('$days${"time.days".tr()}');
    parts.addAll([
      '$hours${"time.hours".tr()}',
      '$minutes${"time.minutes".tr()}',
      '$seconds${"time.seconds".tr()}',
    ]);

    return parts.join(' ');
  }

  double _getTimerProgress() {
    const totalDuration = Duration(days: 3);
    final elapsed = totalDuration - _timeRemaining;
    return (elapsed.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: _buildCardDecoration(),
        child: Column(children: [_buildImageSection(), _buildInfoSection()]),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: AppColors.cardBackground(context),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowColor(context),
          blurRadius: isDark ? 15 : 20,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
        if (!isDark)
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.05),
            blurRadius: 40,
            spreadRadius: -10,
            offset: const Offset(0, 20),
          ),
      ],
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
      height: 240,
      child: Stack(
        children: [
          _buildImageCarousel(),
          _buildImageIndicators(),
          if (widget.pageType != PageType.myWinners) ...[
            _buildTopBadges(),
            _buildLikeButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            currentImageIndex = index;
            _tabController.animateTo(index);
          });
        },
        itemCount: widget.post.media.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: _onImageTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(widget.post.media[index], fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                      stops: const [0.7, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageIndicators() {
    if (widget.post.media.length <= 1) return const SizedBox();

    return Positioned(
      bottom: 12,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.post.media.length,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            height: 8,
            width: currentImageIndex == index ? 24 : 8,
            decoration: BoxDecoration(
              color:
                  currentImageIndex == index
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBadges() {
    return Positioned(
      top: 16,
      left: 16,
      child: Row(
        children: [
          _buildCategoryBadge(widget.post.category),
          if (widget.pageType == PageType.interested ||
              widget.pageType == PageType.myPosts) ...[
            const SizedBox(width: 8),
            _buildStatusBadge(widget.post.isLive),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String label) {
    return AnimatedBuilder(
      animation: _gradientAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryLightDark(context),
                AppColors.secondaryLightDark(context),
              ],
              begin: _gradientAnimation.value as Alignment,
              end: Alignment(
                -(_gradientAnimation.value as Alignment).x,
                -(_gradientAnimation.value as Alignment).y,
              ),
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryLightDark(context).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.category, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String? status) {
    final statusConfig = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusConfig['color'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusConfig['icon'], size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            statusConfig['label'],
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String? status) {
    switch (status) {
      case 'WAITING':
        return {
          'color': Colors.orange.shade400,
          'icon': Icons.hourglass_empty,
          'label': 'status.waiting'.tr(),
        };
      case 'IN_PROGRASS':
        return {
          'color': Colors.blue.shade400,
          'icon': Icons.autorenew,
          'label': 'status.in_progress'.tr(),
        };
      case 'COMPLETED':
        return {
          'color': Colors.green.shade400,
          'icon': Icons.check_circle,
          'label': 'status.completed'.tr(),
        };
      default:
        return {
          'color': Colors.grey.shade400,
          'icon': Icons.info_outline,
          'label': 'status.unknown'.tr(),
        };
    }
  }

  Widget _buildLikeButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      top: 16,
      right: 16,
      child: GestureDetector(
        onTap: _onLike,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:
                isLiked
                    ? Colors.red.withOpacity(0.9)
                    : (isDark
                        ? Colors.black.withOpacity(0.6)
                        : Colors.black.withOpacity(0.4)),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:
                    isLiked
                        ? Colors.red.withOpacity(0.3)
                        : Colors.black.withOpacity(isDark ? 0.4 : 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _likeAnimationController,
            builder:
                (_, __) => Transform.scale(
                  scale: 1.0 + _likeAnimationController.value * 0.2,
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleInterest() async {
    final api = ApiService();
    final userData = await api.getCurrentUser();
    final userId = userData?['id']; // 🟡 استبدل بـ user ID الحقيقي
    final postId = widget.post.id;
    final tokenBox = await Hive.openBox('authBox');
    final token = tokenBox.get('access_token');
    if (token == null) {
      print('Access token is missing or invalid');
      return;
    }
    setState(() {
      isLiked = !isLiked;
      widget.post.isFav = isLiked;
    });

    final success =
        isLiked
            ? await api.markPostAsInterested(
              userId: userId,
              postId: postId,
              token: token,
            )
            : await api.unmarkPostAsInterested(
              userId: userId,
              postId: postId,
              token: token,
            );

    if (!success) {
      // استرجاع الحالة في حال فشل
      setState(() {
        isLiked = !isLiked;
        widget.post.isFav = isLiked;
      });
    }
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildPriceInfo(),
          const SizedBox(height: 16),
          if (widget.pageType != PageType.myWinners) ...[
            _buildStats(),
            const SizedBox(height: 16),
            _buildTimer(),
          ] else
            _buildFinalPrice(),
        ],
      ),
    );
  }

  Widget _buildPriceInfo() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            "post.on_auction".tr(),
            "${"common.number_prefix".tr()}${widget.post.numberOfOnAuction}",
            icon: Icons.confirmation_number,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            "post.starting_bid".tr(),
            "${widget.post.startPrice} ${"common.currency".tr()}",
            icon: Icons.monetization_on,
            color: AppColors.primaryLightDark(context),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String label,
    String value, {
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(isDark ? 0.3 : 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.gavel,
            "stats.bids".tr(),
            "${widget.post.bidStep}",
            Colors.amber,
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            Icons.visibility,
            "stats.views".tr(),
            "${widget.post.viewCount}",
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.15 : 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary(context),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 40, width: 1, color: AppColors.divider(context));
  }

  Widget _buildTimer() {
    final targetDayName = DateFormat(
      'EEEE',
      context.locale.languageCode,
    ).format(_targetDate);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isDark
                  ? [
                    Colors.red.shade900.withOpacity(0.3),
                    Colors.orange.shade900.withOpacity(0.3),
                  ]
                  : [Colors.red.shade50, Colors.orange.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(isDark ? 0.4 : 0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: isDark ? Colors.red.shade400 : Colors.red.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "timer.starts".tr(args: [targetDayName]),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.red.shade400 : Colors.red.shade700,
                    ),
                  ),
                ],
              ),
              Text(
                DateFormat(
                  'MMM d',
                  context.locale.languageCode,
                ).format(_targetDate),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatTimeRemaining(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.red.shade400 : Colors.red.shade700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _getTimerProgress(),
              backgroundColor: AppColors.divider(context),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Colors.red.shade400 : Colors.red.shade600,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalPrice() {
    return _buildInfoCard(
      "post.final_price".tr(),
      "${widget.post.finalPrice} ${"common.currency".tr()}",
      icon: Icons.attach_money,
      color: AppColors.primaryLightDark(context),
    );
  }
}
