import 'dart:async';

import 'package:application/screens/Main_User_Pages.dart/Posts/details_post_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/post.dart';
import 'dart:ui';
import 'dart:math' as math;
import 'package:intl/intl.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  int currentImageIndex = 0;
  bool isLiked = false;
  late PageController _pageController;
  late AnimationController _likeAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _shimmerAnimationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  // For image carousel
  late TabController _tabController;

  // For animated gradient
  late AnimationController _gradientAnimationController;
  late Animation<AlignmentGeometry> _gradientAnimation;

  // For timer
  late DateTime _targetDate;
  late Timer _timer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _gradientAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _shimmerAnimationController,
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

    // Initialize tab controller for image carousel
    _tabController = TabController(
      length: widget.post.media.length,
      vsync: this,
    );

    _tabController.addListener(() {
      setState(() {
        currentImageIndex = _tabController.index;
      });
    });

    // Initialize timer
    _updateTargetDate();
    _startTimer();
  }

  void _updateTargetDate() {
    final now = DateTime.now();
    final currentWeekday = now.weekday; // Monday is 1, Sunday is 7

    if (currentWeekday > 4) {
      // After Thursday (Friday, Saturday, Sunday)
      // Set target to next Monday
      _targetDate = now.add(Duration(days: (8 - currentWeekday) % 7));
    } else if (currentWeekday > 1) {
      // After Monday (Tuesday, Wednesday, Thursday)
      // Set target to next Thursday
      _targetDate = now.add(
        Duration(
          days: (4 - currentWeekday) % 7 + (currentWeekday == 4 ? 7 : 0),
        ),
      );
    } else {
      // Monday
      // Set target to Thursday this week
      _targetDate = now.add(const Duration(days: 3));
    }

    // Set time to end of day (23:59:59)
    _targetDate = DateTime(
      _targetDate.year,
      _targetDate.month,
      _targetDate.day,
      23,
      59,
      59,
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (now.isAfter(_targetDate)) {
        _updateTargetDate(); // Update to the next target date
      }

      setState(() {
        _timeRemaining = _targetDate.difference(now);
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _likeAnimationController.dispose();
    _pulseAnimationController.dispose();
    _shimmerAnimationController.dispose();
    _gradientAnimationController.dispose();
    _tabController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _onLike() {
    HapticFeedback.mediumImpact();
    setState(() {
      isLiked = !isLiked;
      isLiked
          ? _likeAnimationController.forward()
          : _likeAnimationController.reverse();
    });
  }

  String _formatTimeRemaining() {
    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours % 24;
    final minutes = _timeRemaining.inMinutes % 60;
    final seconds = _timeRemaining.inSeconds % 60;

    final parts = <String>[];

    if (days > 0) parts.add('${days}d');
    parts.add('${hours}h');
    parts.add('${minutes}m');
    parts.add('${seconds}s');

    return parts.join(' ');
  }

  double _getTimerProgress() {
    final targetDayName = DateFormat('EEEE').format(_targetDate);
    if (targetDayName == 'Monday') {
      // From Friday to Monday (3 days)
      final totalDuration = const Duration(days: 3);
      final elapsed = totalDuration - _timeRemaining;
      return elapsed.inSeconds / totalDuration.inSeconds;
    } else {
      // From Tuesday to Thursday (2 days)
      final totalDuration = const Duration(days: 3);
      final elapsed = totalDuration - _timeRemaining;
      return elapsed.inSeconds / totalDuration.inSeconds;
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.03),
              blurRadius: 30,
              spreadRadius: -5,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          children: [_buildImageSection(post), _buildInfoSection(post)],
        ),
      ),
    );
  }

  Widget _buildImageSection(Post post) {
  return Stack(
    children: [
      // Image carousel with click
      SizedBox(
        height: 250,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                currentImageIndex = index;
                _tabController.animateTo(index);
              });
            },
            itemCount: post.media.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => FractionallySizedBox(
                      heightFactor: 0.8, 
                     child: DetailsPostPage(post: widget.post),
                    ),
                  );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(post.media[index], fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),

      // Image indicator (dots)
      Positioned(
        bottom: 16,
        left: 0,
        right: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            post.media.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color: currentImageIndex == index
                    ? const Color.fromARGB(255, 22, 131, 122)
                    : const Color(0xFF8BD6D0).withOpacity(0.3),
                shape: BoxShape.circle,
                boxShadow: [
                  if (currentImageIndex == index)
                    BoxShadow(
                      color: const Color(0xFF8BD6D0).withOpacity(0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),

      // Category badge
      Positioned(
        top: 16,
        left: 16,
        child: _buildCategoryBadge(post.category),
      ),

      // Like button
      Positioned(
        top: 16,
        right: 16,
        child: _buildLikeButton(),
      ),
    ],
  );
}


  Widget _buildInfoSection(Post post) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _infoBlockAdvanced(
                  "Post on Auction",
                  "#${post.numberOfOnAuction}",
                  icon: Icons.confirmation_number,
                  color: Colors.deepPurple,
                  gradient: const LinearGradient(
                    colors: [Colors.deepPurple, Colors.purple],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _infoBlockAdvanced(
                  "Starting Bid",
                  "${post.startPrice} NIS",
                  icon: Icons.monetization_on,
                  color: Colors.green,
                  gradient: const LinearGradient(
                    colors: [Colors.green, Colors.lightGreen],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _iconStatAdvanced(
                  Icons.workspace_premium,
                  "Bids",
                  "${post.bidStep}",
                  iconColor: Colors.amber,
                ),
                _buildDivider(),
                _iconStatAdvanced(
                  Icons.visibility,
                  "Interested",
                  "32",
                  iconColor: Colors.blue,
                ),
                _buildDivider(),
                _iconStatAdvanced(
                  Icons.star,
                  "Rating",
                  "4.8/5",
                  iconColor: Color(0xFFFFD700),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          _buildAdvancedTimer(_formatTimeRemaining(), _getTimerProgress()),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String label) {
    return AnimatedBuilder(
      animation: _gradientAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [Color(0xFF9BDDC9), Color(0xFF61C7A7)],
              begin: _gradientAnimation.value as Alignment,
              end: Alignment(
                -(_gradientAnimation.value as Alignment).x,
                -(_gradientAnimation.value as Alignment).y,
              ),
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9BDDC9).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.category, size: 16, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
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

  Widget _buildLikeButton() {
    return GestureDetector(
      onTap: _onLike,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color:
              isLiked
                  ? Colors.red.withOpacity(0.9)
                  : Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:
                  isLiked
                      ? Colors.red.withOpacity(0.3)
                      : Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _likeAnimationController,
          builder:
              (_, __) => Transform.scale(
                scale: 1.0 + _likeAnimationController.value * 0.3,
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                  size: 20,
                ),
              ),
        ),
      ),
    );
  }

  Widget _infoBlockAdvanced(
    String label,
    String value, {
    required IconData icon,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedPercentageChange(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Transform.rotate(
            angle: -math.pi / 4,
            child: const Icon(
              Icons.arrow_upward,
              size: 14,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconStatAdvanced(
    IconData icon,
    String label,
    String value, {
    required Color iconColor,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: iconColor), // استعمل اللون هون
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 60, width: 1, color: Colors.grey.shade300);
  }

  Widget _buildAdvancedTimer(String timeLeft, double progress) {
    final targetDayName = DateFormat('EEEE').format(_targetDate);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade50, Colors.deepOrange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with day and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer, size: 16, color: Colors.red),
                  const SizedBox(width: 6),
                  Text(
                    "Start on $targetDayName",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                DateFormat('MMM d, yyyy').format(_targetDate),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Digital countdown
          Center(
            child: Text(
              timeLeft,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: Colors.redAccent,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTimeUnitDisplays(String timeRemaining) {
    // Parse the time components
    final List<String> parts = timeRemaining.split(' ');
    final Map<String, String> timeUnits = {};

    for (int i = 0; i < parts.length; i += 2) {
      if (i + 1 < parts.length) {
        timeUnits[parts[i + 1]] = parts[i];
      }
    }

    // Create digital displays for each time unit
    final List<Widget> displays = [];

    void addTimeUnit(String value, String label, Color color) {
      displays.add(
        Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      );

      if (displays.length < timeUnits.length * 2 - 1) {
        displays.add(
          const Padding(
            padding: EdgeInsets.only(bottom: 24),
            child: Text(
              ":",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black45,
              ),
            ),
          ),
        );
      }
    }

    // Add time units in order: days, hours, minutes, seconds
    if (timeUnits.containsKey('d')) {
      addTimeUnit(timeUnits['d']!, 'DAYS', Colors.deepPurple);
    }

    if (timeUnits.containsKey('h')) {
      addTimeUnit(timeUnits['h']!, 'HOURS', Colors.red.shade700);
    }

    if (timeUnits.containsKey('m')) {
      addTimeUnit(timeUnits['m']!, 'MINS', Colors.orange.shade700);
    }

    if (timeUnits.containsKey('s')) {
      addTimeUnit(timeUnits['s']!, 'SECS', Colors.amber.shade700);
    }

    return displays;
  }
}
