import 'dart:async';

import 'package:application/models/action.dart';
import 'package:application/models/bid.dart';
import 'package:application/models/post.dart';
import 'package:application/screens/Main_User_Pages.dart/Auction_pages/bid_button_sheet.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// Import your AppColors class
import 'package:application/constants/app_colors.dart';

class AuctionDetailPage extends StatefulWidget {
  final Auction auction;
  final List<Post> posts;
  final List<Bid> bids;

  const AuctionDetailPage({
    super.key,
    required this.auction,
    required this.posts,
    required this.bids,
  });

  @override
  State<AuctionDetailPage> createState() => _AuctionDetailPageState();
}

class _AuctionDetailPageState extends State<AuctionDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _timer;
  Duration _timeLeft = Duration.zero;
  late Post selectedPost;
  int _selectedPostIndex = 0;
  final PageController _pageController = PageController();
  late DateTime _endTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.posts.isNotEmpty) {
      selectedPost = widget.posts.first;
    }

    _endTime = DateTime.now().add(const Duration(minutes: 1));
    _initializeAuctionTimer();
  }

  void _initializeAuctionTimer() {
    final now = DateTime.now();
    final difference = _endTime.difference(now);

    if (mounted) {
      setState(() => _timeLeft = difference);
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final diff = _endTime.difference(DateTime.now());
      if (diff.isNegative) {
        timer.cancel();
      } else {
        if (mounted) {
          setState(() => _timeLeft = diff);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      appBar: AppBar(
        title: Text(
          widget.auction.title,
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
        backgroundColor: AppColors.cardBackground(context),
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTimerBar(),
          Expanded(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageCarousel(),
                          const SizedBox(height: 16),
                          _buildCategoryBadge(),
                          const SizedBox(height: 12),
                          _buildTitle(),
                          const SizedBox(height: 12),
                          _buildStats(),
                          const SizedBox(height: 8),
                          _buildBidInfo(),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: AppColors.primaryLightDark(context),
                        unselectedLabelColor: AppColors.textSecondary(context),
                        indicatorColor: AppColors.primaryLightDark(context),
                        dividerColor: AppColors.divider(context),
                        tabs: [
                          Tab(text: "bids".tr()),
                          Tab(text: "details".tr()),
                          Tab(text: "rules".tr()),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildBidsTab(),
                  _buildDetailsTab(),
                  _buildRulesTab(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildTimerBar() {
    final totalDuration = const Duration(minutes: 1);
    final progress =
        1 - (_timeLeft.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0);
    final Color barColor = Color.lerp(
      AppColors.timerGreen(context),
      AppColors.timerRed(context),
      progress,
    )!;

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = twoDigits(_timeLeft.inHours % 24);
    final m = twoDigits(_timeLeft.inMinutes % 60);
    final s = twoDigits(_timeLeft.inSeconds % 60);

    return Container(
      color: AppColors.cardBackground(context),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "time_left".tr(namedArgs: {'count': "$h:$m:$s"}),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: barColor,
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.progressBackground(context),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor(context),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: selectedPost.media.length,
            onPageChanged: (index) {
              setState(() {
                _selectedPostIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final image = selectedPost.media[index];
              return GestureDetector(
                onTap: () {},
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.surfaceVariant(context),
                      child: Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          _buildImageIndicators(),
          _buildLiveBadge(),
        ],
      ),
    );
  }

  Widget _buildImageIndicators() {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          selectedPost.media.length,
          (index) => Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _selectedPostIndex == index
                  ? AppColors.primaryLightDark(context)
                  : Colors.white.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveBadge() {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.liveBadgeBackground(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "live".tr(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.lightBackground(context),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.auction.category,
            style: TextStyle(
              color: AppColors.primaryLightDark(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      selectedPost.title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary(context),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Icon(
          Icons.gavel,
          size: 16,
          color: AppColors.textSecondary(context),
        ),
        const SizedBox(width: 4),
        Text(
          'bidders'.tr(
            namedArgs: {
              'count': widget.auction.participantCount.toString(),
            },
          ),
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.remove_red_eye,
          size: 16,
          color: AppColors.textSecondary(context),
        ),
        const SizedBox(width: 4),
        Text(
          "views".tr(
            namedArgs: {
              'count': widget.auction.viewCount.toString(),
            },
          ),
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
      ],
    );
  }

  Widget _buildBidInfo() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight(context),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                "highest_bid".tr(),
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "NIS ${widget.auction.currentHighestBid.toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primaryLightDark(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient(context),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryLightDark(context).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                const Text(
                  "place_bid",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "NIS ${(widget.auction.currentHighestBid + 50).toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight(context),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "current_bid".tr(),
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "NIS ${widget.auction.currentHighestBid.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => BidBottomSheet(
                      onBidPlaced: () {
                        setState(() {
                          _timer?.cancel();
                          _timeLeft = const Duration(minutes: 1);
                          _initializeAuctionTimer();
                        });
                      },
                      post: selectedPost,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLightDark(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "place_bid".tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBidsTab() {
    final allBids = selectedPost.bids;
    allBids.sort((a, b) => b.time.compareTo(a.time));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allBids.length,
      itemBuilder: (context, index) {
        final bid = allBids[index];
        final isFirst = index == 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(12),
            border: isFirst
                ? Border.all(
                    color: AppColors.primaryLightDark(context),
                    width: 2,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight(context),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          bid.userName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        if (isFirst) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLightDark(context),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "highest_bid".tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _getTimeAgo(bid.time),
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "NIS ${selectedPost.currentBid.toStringAsFixed(2)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isFirst
                      ? AppColors.primaryLightDark(context)
                      : AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return "ago_days".tr(namedArgs: {'count': difference.inDays.toString()});
    } else if (difference.inHours > 0) {
      return "ago_hours".tr(
        namedArgs: {'count': difference.inHours.toString()},
      );
    } else if (difference.inMinutes > 0) {
      return "ago_minutes".tr(
        namedArgs: {'count': difference.inMinutes.toString()},
      );
    } else {
      return "ago_seconds".tr(
        namedArgs: {'count': difference.inSeconds.toString()},
      );
    }
  }

  Widget _buildDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight(context),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "auction_info".tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                icon: Icons.category,
                title: "category".tr(),
                value: widget.auction.category,
              ),
              Divider(color: AppColors.divider(context)),
              _buildInfoRow(
                icon: Icons.gavel,
                title: "bidders_count".tr(),
                value: "bidders".tr(
                  namedArgs: {
                    'count': widget.auction.participantCount.toString(),
                  },
                ),
              ),
              Divider(color: AppColors.divider(context)),
              _buildInfoRow(
                icon: Icons.remove_red_eye,
                title: "views".tr(),
                value: "views".tr(
                  namedArgs: {'count': widget.auction.viewCount.toString()},
                ),
              ),
              Divider(color: AppColors.divider(context)),
              _buildInfoRow(
                icon: Icons.price_change,
                title: "min_bid".tr(),
                value: "NIS ${selectedPost.bid_step.toStringAsFixed(2)}",
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight(context),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "description".tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                selectedPost.description,
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRulesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight(context),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "auction_rules".tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 16),
              _buildRuleItem(
                number: 1,
                title: "rule_min_bid".tr(),
                description: "الحد الأدنى للمزايدة هو 50 شيكل فوق آخر مزايدة.",
              ),
              _buildRuleItem(
                number: 2,
                title: "rule_duration".tr(),
                description:
                    "يستمر المزاد حتى الموعد المحدد، ويتم تمديده 5 دقائق إضافية في حال وجود مزايدة في آخر دقيقتين.",
              ),
              _buildRuleItem(
                number: 3,
                title: "rule_commitment".tr(),
                description:
                    "المزايد الفائز ملزم بإتمام عملية الشراء خلال 48 ساعة من انتهاء المزاد.",
              ),
              _buildRuleItem(
                number: 4,
                title: "rule_payment".tr(),
                description:
                    "يتم الدفع عبر التطبيق باستخدام البطاقات الائتمانية أو الحوالات البنكية.",
              ),
              _buildRuleItem(
                number: 5,
                title: "rule_delivery".tr(),
                description:
                    "سيتم توصيل المنتج خلال 3-5 أيام عمل من تاريخ الدفع.",
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight(context),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "extra_info".tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                color: AppColors.warning(context),
                icon: Icons.info_outline,
                text:
                    "المنصة غير مسؤولة عن أي تعاملات تتم خارج التطبيق. يرجى إتمام جميع المعاملات عبر المنصة لضمان حقوقك.",
              ),
              const SizedBox(height: 16),
              _buildSupportCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required Color color,
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.getInfoCardBackground(context, color),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.getInfoCardBorder(context, color),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.getInfoCardBackground(context, AppColors.info(context)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.getInfoCardBorder(context, AppColors.info(context)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.support_agent,
                color: AppColors.info(context),
              ),
              const SizedBox(width: 12),
              Text(
                "support.title".tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.info(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "للمساعدة والاستفسارات، يرجى التواصل مع فريق الدعم على الرقم 123-456-789 أو عبر البريد الإلكتروني support@mazadi.ps",
            style: TextStyle(color: AppColors.info(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem({
    required int number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primaryLightDark(context),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "$number",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.cardBackground(context),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}