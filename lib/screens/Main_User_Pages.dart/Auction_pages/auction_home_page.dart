import 'dart:async';

import 'package:application/API_Service/api.dart';
import 'package:application/models/action.dart';
import 'package:application/models/bid.dart';
import 'package:application/models/post_2.dart';
import 'package:application/screens/Main_User_Pages.dart/Auction_pages/detalis_auction.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../models/AuctionInfo.dart';

class AuctionHomePage extends StatefulWidget {
  const AuctionHomePage({Key? key}) : super(key: key);

  @override
  State<AuctionHomePage> createState() => _AuctionHomePageState();
}

class _AuctionHomePageState extends State<AuctionHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer? _timer;
  Duration _timeLeft = Duration.zero;
  int selectedCategoryIndex = 0;

  // Updated data structure
  Map<String, AuctionInfo?> _auctionsByCategory = {};
  Map<String, List<Post>> _postsByCategory = {};
  Map<String, PaginationResponse<Post>?> _paginationByCategory = {};

  bool _isLoading = true;
  String? _error;

  // Updated category mapping
  late List<Map<String, String>> categoryMappings;

  @override
  void initState() {
    super.initState();
    _initializeCategoryMappings();
    _fetchData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController = TabController(
        length: categoryMappings.length,
        vsync: this,
      );

      _tabController.addListener(() {
        if (mounted) {
          setState(() {
            selectedCategoryIndex = _tabController.index;
          });
          // Load posts for the selected category if not already loaded
          _loadPostsForSelectedCategory();
        }
      });

      _initializeAuctionTimer();
    });
  }

  void _initializeCategoryMappings() {
    categoryMappings = [
      {'key': 'ELECTRONICS', 'label': 'category_electronics'.tr()},
      {'key': 'CARS', 'label': 'category_cars'.tr()},
      {'key': 'REAL_ESTATE', 'label': 'category_real_estate'.tr()},
      {'key': 'FURNITURE', 'label': 'category_furniture'.tr()},
      {'key': 'FASHION', 'label': 'category_fashion'.tr()},
      {'key': 'OTHER', 'label': 'category_other'.tr()},
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _initializeCategoryMappings(); // Re-initialize for language changes
    });
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final api = ApiService();

      // Load auction info for all categories
      for (final categoryMapping in categoryMappings) {
        final categoryKey = categoryMapping['key']!;

        try {
          final auctionInfo = await api.getAuctionByCategoryAndStatusDefulat(
            category: categoryKey,
            status: 'IN_PROGRESS',
          );

          _auctionsByCategory[categoryKey] = auctionInfo;

          // If auction exists, load first page of posts
          if (auctionInfo != null) {
            await _loadPostsForCategory(categoryKey, page: 1);
          }
        } catch (e) {
          print('Error loading category $categoryKey: $e');
          _auctionsByCategory[categoryKey] = null;
          _postsByCategory[categoryKey] = [];
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "حدث خطأ أثناء تحميل البيانات";
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPostsForCategory(String categoryKey, {int page = 1}) async {
    final auctionInfo = _auctionsByCategory[categoryKey];
    if (auctionInfo == null) return;

    try {
      final api = ApiService();
      final postsResponse = await api.getPostsForAuction(
        auctionId: auctionInfo.id,
        page: page,
        size: 10,
        category: categoryKey,
      );

      if (postsResponse != null) {
        setState(() {
          if (page == 1) {
            _postsByCategory[categoryKey] = postsResponse.content;
          } else {
            _postsByCategory[categoryKey] = [
              ...(_postsByCategory[categoryKey] ?? []),
              ...postsResponse.content,
            ];
          }
          _paginationByCategory[categoryKey] = postsResponse;
        });
      }
    } catch (e) {
      print('Error loading posts for category $categoryKey: $e');
    }
  }

  Future<void> _loadPostsForSelectedCategory() async {
    if (selectedCategoryIndex >= categoryMappings.length) return;

    final selectedCategoryKey = categoryMappings[selectedCategoryIndex]['key']!;

    // Only load if we haven't loaded posts for this category yet
    if (!_postsByCategory.containsKey(selectedCategoryKey) ||
        _postsByCategory[selectedCategoryKey]?.isEmpty == true) {
      await _loadPostsForCategory(selectedCategoryKey);
    }
  }

  Future<void> _loadMorePosts() async {
    if (selectedCategoryIndex >= categoryMappings.length) return;

    final selectedCategoryKey = categoryMappings[selectedCategoryIndex]['key']!;
    final pagination = _paginationByCategory[selectedCategoryKey];

    if (pagination != null && pagination.number < pagination.totalPages) {
      await _loadPostsForCategory(selectedCategoryKey, page: pagination.number + 1);
    }
  }

  List<Post> get filteredPosts {
    if (selectedCategoryIndex >= categoryMappings.length) return [];

    final selectedCategoryKey = categoryMappings[selectedCategoryIndex]['key']!;
    return _postsByCategory[selectedCategoryKey] ?? [];
  }

  Post? get livePost {
    final posts = filteredPosts;
    try {
      return posts.firstWhere((post) => post.status == 'IN_PROGRESS');
    } catch (e) {
      return null;
    }
  }

  AuctionInfo? get currentAuction {
    if (selectedCategoryIndex >= categoryMappings.length) return null;

    final selectedCategoryKey = categoryMappings[selectedCategoryIndex]['key']!;
    return _auctionsByCategory[selectedCategoryKey];
  }

  void _initializeAuctionTimer() {
    final now = DateTime.now();
    final isThursdayToMonday =
        now.weekday >= DateTime.thursday || now.weekday == DateTime.monday;
    final nextReset = isThursdayToMonday
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchData,
                child: Text('retry'.tr()),
              ),
            ],
          ),
        ),
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
            tabs: categoryMappings
                .map((category) => Tab(text: category['label']))
                .toList(),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildTimerBar(),
          Expanded(
            child: currentAuction == null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "لا توجد مزادات متاحة في هذه الفئة",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 12),
                  if (livePost != null) ...[
                    _buildFeaturedAuction(),
                    const SizedBox(height: 24),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "جميع المنشورات",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      if (currentAuction != null)
                        Text(
                          "${currentAuction!.postCount} منشور",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildAuctionGrid(),
                  if (_hasMorePages()) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _loadMorePosts,
                        child: Text('load_more'.tr()),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasMorePages() {
    if (selectedCategoryIndex >= categoryMappings.length) return false;

    final selectedCategoryKey = categoryMappings[selectedCategoryIndex]['key']!;
    final pagination = _paginationByCategory[selectedCategoryKey];

    return pagination != null && pagination.number < pagination.totalPages;
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
          colors: Theme.of(context).brightness == Brightness.dark
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
    final post = livePost;
    final auctionInfo = _auctionsByCategory[post?.category];
    if (post == null) return Container();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AuctionDetailPage(post: post,auctionId: auctionInfo?.id), // Pass the selected post
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
              child: Image.network(
                post.media.isNotEmpty ? post.media.first : 'assets/images/placeholder.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                    post.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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
                        "NIS ${post.currentBid?.toStringAsFixed(2) ?? post.startPrice.toStringAsFixed(2)}",
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
    final posts = filteredPosts;

    if (posts.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Text(
            "لا توجد منشورات متاحة",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        Color badgeColor;
        String badgeText;

        switch (post.status) {
          case 'WAITING':
            badgeColor = Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade300;
            badgeText = 'coming_soon'.tr();
            break;
          case 'COMPLETED':
            badgeColor = Theme.of(context).brightness == Brightness.dark
                ? Colors.green.shade400
                : Colors.green;
            badgeText = 'sold'.tr();
            break;
          default:
            badgeColor = Theme.of(context).brightness == Brightness.dark
                ? Colors.red.shade300
                : Colors.red.shade700;
            badgeText = 'live'.tr();
        }
        final auctionInfo = _auctionsByCategory[post.category];
        return GestureDetector(
          onTap: post.status == 'IN_PROGRESS'
              ? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AuctionDetailPage(post: post,auctionId:auctionInfo?.id), // Pass the selected post
              ),
            );
          }
              : null,
          child: Opacity(
            opacity: post.status == 'IN_PROGRESS' ? 1.0 : 0.5,
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
                    child: Image.network(
                      post.media.isNotEmpty ? post.media.first : 'assets/images/placeholder.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.image_not_supported, size: 50),
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
                          post.title,
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
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 12,
                          ),
                        ),
                        if (post.numberOfOnAuction != null)
                          Text(
                            'auction_rank'.tr(
                              namedArgs: {
                                'rank': post.numberOfOnAuction.toString(),
                              },
                            ),
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
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