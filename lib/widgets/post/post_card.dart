import 'dart:async';
import 'package:application/screens/Main_User_Pages.dart/Posts/details_post_page.dart';
import 'package:application/screens/Main_User_Pages.dart/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/post.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:intl/intl.dart';

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
  }

  void _initializeControllers() {
    isLiked = widget.post.isFav;
    _pageController = PageController(viewportFraction: 1.0);
    _tabController = TabController(length: widget.post.media.length, vsync: this);
    
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
      CurvedAnimation(parent: _pulseAnimationController, curve: Curves.easeInOut),
    );

    _gradientAnimation = AlignmentTween(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(
      CurvedAnimation(parent: _gradientAnimationController, curve: Curves.easeInOut),
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
      nextTarget = DateTime(now.year, now.month, now.day)
          .add(Duration(days: daysUntilMonday))
          .add(const Duration(hours: 18));
    } else {
      // Countdown to Thursday 6:00 PM
      final daysUntilThursday = (DateTime.thursday - currentWeekday + 7) % 7;
      nextTarget = DateTime(now.year, now.month, now.day)
          .add(Duration(days: daysUntilThursday))
          .add(const Duration(hours: 18));
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
    setState(() {
      isLiked = !isLiked;
      widget.post.isFav = isLiked;
      isLiked
          ? _likeAnimationController.forward()
          : _likeAnimationController.reverse();
    });
  }

  void _onImageTap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.8,
        child: DetailsPostPage(
          post: widget.post,
          pageType: widget.pageType,
        ),
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
    if (days > 0) parts.add('${days}d');
    parts.addAll(['${hours}h', '${minutes}m', '${seconds}s']);

    return parts.join(' ');
  }

  double _getTimerProgress() {
    const totalDuration = Duration(days: 3);
    final elapsed = totalDuration - _timeRemaining;
    return (elapsed.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: _buildCardDecoration(),
        child: Column(
          children: [
            _buildImageSection(),
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
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
                Image.asset(widget.post.media[index], fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
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
              color: currentImageIndex == index
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
          if (widget.post.isFav) ...[
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
              colors: const [Color(0xFF4CAF50), Color(0xFF66BB6A)],
              begin: _gradientAnimation.value as Alignment,
              end: Alignment(
                -(_gradientAnimation.value as Alignment).x,
                -(_gradientAnimation.value as Alignment).y,
              ),
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF50).withOpacity(0.3),
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

  Widget _buildStatusBadge(String status) {
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

  Map<String, dynamic> _getStatusConfig(String status) {
    switch (status) {
      case 'WAITING':
        return {
          'color': Colors.orange.shade400,
          'icon': Icons.hourglass_empty,
          'label': 'قيد الانتظار'
        };
      case 'IN_PROGRASS':
        return {
          'color': Colors.blue.shade400,
          'icon': Icons.autorenew,
          'label': 'قيد التنفيذ'
        };
      case 'COMPLETED':
        return {
          'color': Colors.green.shade400,
          'icon': Icons.check_circle,
          'label': 'مكتمل'
        };
      default:
        return {
          'color': Colors.grey.shade400,
          'icon': Icons.info_outline,
          'label': 'غير معروف'
        };
    }
  }

  Widget _buildLikeButton() {
    return Positioned(
      top: 16,
      right: 16,
      child: GestureDetector(
        onTap: _onLike,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isLiked
                ? Colors.red.withOpacity(0.9)
                : Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isLiked
                    ? Colors.red.withOpacity(0.3)
                    : Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _likeAnimationController,
            builder: (_, __) => Transform.scale(
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

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
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
            "Post on Auction",
            "#${widget.post.numberOfOnAuction}",
            icon: Icons.confirmation_number,
            color: Colors.deepPurple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInfoCard(
            "Starting Bid",
            "${widget.post.startPrice} NIS",
            icon: Icons.monetization_on,
            color: Colors.green,
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
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
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
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
          _buildStatItem(Icons.gavel, "Bids", "${widget.post.bid_step}", Colors.amber),
          _buildVerticalDivider(),
          _buildStatItem(Icons.visibility, "Views", "32", Colors.blue),
          _buildVerticalDivider(),
          _buildStatItem(Icons.star, "Rating", "4.8", Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade300);
  }

  Widget _buildTimer() {
    final targetDayName = DateFormat('EEEE').format(_targetDate);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade50, Colors.orange.shade50],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.red.shade600),
                  const SizedBox(width: 6),
                  Text(
                    "Starts $targetDayName",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
              Text(
                DateFormat('MMM d').format(_targetDate),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _formatTimeRemaining(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _getTimerProgress(),
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red.shade600),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalPrice() {
    return _buildInfoCard(
      "Final Price",
      "${widget.post.currentBid} NIS",
      icon: Icons.attach_money,
      color: Colors.green,
    );
  }
}