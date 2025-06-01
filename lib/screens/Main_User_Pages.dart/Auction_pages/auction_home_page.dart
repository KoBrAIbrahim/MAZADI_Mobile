import 'dart:async';

import 'package:application/API_Service/api.dart';
import 'package:application/models/action.dart';
import 'package:application/models/bid.dart';
import 'package:application/models/post_2.dart';
import 'package:application/screens/Main_User_Pages.dart/Auction_pages/detalis_auction.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AuctionHomePage extends StatefulWidget {
  const AuctionHomePage({Key? key}) : super(key: key);

  @override
  State<AuctionHomePage> createState() => _AuctionHomePageState();
}

class _AuctionHomePageState extends State<AuctionHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Auction> auctions;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _timer;
  Duration _timeLeft = Duration.zero;
  int selectedCategoryIndex = 0;
  List<Auction> _auctions = [];
  List<Post> _posts = [];
  List<Bid> _bids = [];
  List<String> _categories = [];
  bool _isLoading = true;
  String? _error;

  final Map<int, String> indexToArabicCategory = {
    0: 'إلكترونيات', // electronics
    1: 'سيارات', // cars
    2: 'عقارات', // real estate
    3: 'أثاث', // furniture
    4: 'ملابس', // clothing
    5: 'أخرى', // other
  };

  @override
  void initState() {
    super.initState();
    _fetchData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController = TabController(
        length: _categories.length,
        vsync: this,
      );

      _tabController.addListener(() {
        if (mounted) {
          setState(() {
            selectedCategoryIndex = _tabController.index;
          });
        }
      });

      _initializeAuctionTimer();
      auctions = _auctions;
    });
  }

  Future<void> _fetchData() async {
    try {
      final api = ApiService();
      final auctions = await api.getAllAuctions(); // حسب API
      final posts = await api.getAllPosts();
      final bids = await api.getAllBids();
      final categories = await api.getCategories();

      setState(() {
        _auctions = auctions ?? [];
        _posts = posts ?? [];
        _bids = bids ?? [];
        _categories = categories ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "حدث خطأ أثناء تحميل البيانات";
        _isLoading = false;
      });
    }
  }

  List<Auction> get filteredAuctions {
    final arabicCategory =
        indexToArabicCategory[selectedCategoryIndex]?.trim().toLowerCase() ??
        '';

    return auctions.where((auction) {
      final auctionCategory = auction.category.trim().toLowerCase();
      return auctionCategory == arabicCategory;
    }).toList();
  }

  void _initializeAuctionTimer() {
    final now = DateTime.now();
    final isThursdayToMonday =
        now.weekday >= DateTime.thursday || now.weekday == DateTime.monday;
    final nextReset =
        isThursdayToMonday
            ? DateTime(
              now.year,
              now.month,
              now.weekday == 1 ? now.day : now.day + (8 - now.weekday),
              18,
            )
            : DateTime(
              now.year,
              now.month,
              now.day + (DateTime.thursday - now.weekday),
              18,
            );

    setState(() => _timeLeft = nextReset.difference(now));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final diff = nextReset.difference(DateTime.now());
      if (diff.isNegative) {
        timer.cancel();
      } else {
        setState(() => _timeLeft = diff);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!, style: TextStyle(color: Colors.red))),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text(
          'auctions'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),

        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            child: Image.asset('assets/icons/mazadi_logo.png'),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).unselectedWidgetColor,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            tabs:
                _categories
                    .map((category) => Tab(text: category))
                    .toList(),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildTimerBar(),
          Expanded(
            child:
                filteredAuctions.isEmpty
                    ? const Center(
                      child: Text(
                        "لا توجد مزادات متاحة",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                    : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const SizedBox(height: 12),
                        _buildFeaturedAuction(),
                        const SizedBox(height: 24),
                        Text(
                          "جميع المنشورات",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAuctionGrid(),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerBar() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final days = _timeLeft.inDays;
    final h = twoDigits(_timeLeft.inHours % 24);
    final m = twoDigits(_timeLeft.inMinutes % 60);
    final s = twoDigits(_timeLeft.inSeconds % 60);

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              Theme.of(context).brightness == Brightness.dark
                  ? [Colors.deepOrange.shade400, Colors.deepOrange.shade200]
                  : [Colors.red.shade200, Colors.orange.shade200],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.timer_outlined, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Text(
            "ends_in".tr(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(width: 8),
          _buildTimeBlock(days.toString(), 'day'.tr()),
          _buildTimeBlock(h, 'hour'.tr()),
          _buildTimeBlock(m, 'minute'.tr()),
          _buildTimeBlock(s, 'second'.tr()),
        ],
      ),
    );
  }

  Widget _buildTimeBlock(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.red.shade700,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedAuction() {
    final arabicCategory =
        indexToArabicCategory[selectedCategoryIndex]?.trim().toLowerCase() ??
        '';

    // Find a live post that matches our category
    final livePosts =
        _auctions
            .expand((auction) => auction.posts)
            .where(
              (post) =>
                  post.isLive == 'IN_PROGRASS' &&
                  post.category.trim().toLowerCase() == arabicCategory,
            )
            .toList();

    if (livePosts.isEmpty)
      return Container(); // Return empty container if no live posts
    final livePost = livePosts.first;
    final auction = _auctions.firstWhere(
      (a) => a.posts.contains(livePost),
      orElse: () => _auctions.first,
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => AuctionDetailPage(
                 
                ),
          ),
        );
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                livePost.media.first,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Theme.of(context).cardColor,
                      child: const Icon(Icons.image_not_supported, size: 50),
                    ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
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
                      'live'.tr(),
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
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auction.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.gavel,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'bidders'.tr(
                                namedArgs: {
                                  'count': auction.participantCount.toString(),
                                },
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.remove_red_eye,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'views'.tr(
                                namedArgs: {
                                  'count': auction.viewCount.toString(),
                                },
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'current_price'.tr(),
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "NIS ${livePost.currentBid?.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
    );
  }

  Widget _buildAuctionGrid() {
    final arabicCategory =
        indexToArabicCategory[selectedCategoryIndex]?.trim().toLowerCase() ??
        '';

    final filteredPosts =
        _auctions
            .expand((auction) => auction.posts)
            .where(
              (post) => post.category.trim().toLowerCase() == arabicCategory,
            )
            .toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredPosts.length,
      itemBuilder: (context, index) {
        final post = filteredPosts[index];
        Color badgeColor;
        String badgeText;

        switch (post.isLive) {
          case 'WAITING':
            badgeColor =
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300;
            badgeText = 'coming_soon'.tr();
            break;
          case 'COMPLETED':
            badgeColor =
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.green.shade400
                    : Colors.green;
            badgeText = 'sold'.tr();
            break;
          default:
            badgeColor =
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.red.shade300
                    : Colors.red.shade700;
            badgeText = 'live'.tr();
        }

        return GestureDetector(
          onTap:
              post.isLive == 'IN_PROGRASS'
                  ? () {
                    final parentAuction = _auctions.firstWhere(
                      (a) => a.posts.contains(post),
                      orElse: () => _auctions.first,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AuctionDetailPage(
                             
                            ),
                      ),
                    );
                  }
                  : null,
          child: Opacity(
            opacity: post.isLive == 'IN_PROGRASS' ? 1.0 : 0.5,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      post.media.first,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                            ),
                          ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title ?? "بدون عنوان",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'starting_price'.tr(
                            namedArgs: {
                              'price': post.startPrice.toStringAsFixed(2),
                            },
                          ),
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'auction_rank'.tr(
                            namedArgs: {
                              'rank': post.numberOfOnAuction.toString(),
                            },
                          ),
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
