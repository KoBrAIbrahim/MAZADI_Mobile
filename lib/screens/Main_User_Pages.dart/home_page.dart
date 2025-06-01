import 'package:application/API_Service/api.dart';
import 'package:application/constants/app_colors.dart';
import 'package:application/models/post_2.dart';
import 'package:application/screens/Main_User_Pages.dart/Auction_pages/main_page_auction.dart';
import 'package:application/screens/Main_User_Pages.dart/dashboard.dart/dashboard_page.dart';
import 'package:application/widgets/Header/header_build.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:application/widgets/main_page/add_post_bar.dart';
import 'package:application/widgets/main_page/category_carousel.dart';
import 'package:application/widgets/main_page/lower_bar_pages.dart';
import 'package:application/widgets/main_page/search_bar.dart';
import 'package:application/widgets/post/post_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive/hive.dart';

enum PageType { main, interested, myPosts, myWinners, posts }

class HomePage extends StatefulWidget {
  final List<Post>? initialPosts;
  final PageType pageType;
  final ScrollController? scrollController;
  HomePage({
    super.key,
    this.pageType = PageType.main,
    this.scrollController,
    this.initialPosts,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _drawerHintController;
  late Animation<Offset> _drawerHintAnimation;
  bool _showScrollToTopButton = false;
  int currentIndex = 0;
  late ScrollController _scrollController;
  bool _isAddBarVisible = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentPage = 1;
  final int _pageSize = 2;
  List<Post> _posts = [];
  String? _selectedSortKey;
  String? _selectedCategoryKey;
  String? _searchQuery;

  bool _isLoading = true;
  String? _error;
  void onTap(int index) {
    setState(() => currentIndex = index);
  }

  Future<void> fetchPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ApiService();

      if (widget.pageType == PageType.interested) {
        // 📌 جلب بيانات المستخدم
        final user = await api.getCurrentUser();
        if (user == null || user['id'] == null) {
          throw Exception('فشل في جلب بيانات المستخدم');
        }

        final authBox = await Hive.openBox('authBox');
        final token = authBox.get('access_token');
        final userId = user['id'];

        final posts = await api.getInterestedPosts(
          userId: userId,
          token: token,
          category: _selectedCategoryKey,
          page: _currentPage,
          size: _pageSize,
        );

        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      } else if (widget.pageType == PageType.main) {
        // 📌 الحالة العادية
        final posts = await api.getAllPosts(
          sortKey: _selectedSortKey,
          category: _selectedCategoryKey,
          searchQuery: _searchQuery,
        );

        setState(() {
          _posts = posts ?? [];
          _isLoading = false;
        });
      } else if (widget.pageType == PageType.myPosts) {
        final user = await api.getCurrentUser();
        if (user == null || user['id'] == null) {
          throw Exception('فشل في جلب بيانات المستخدم');
        }
        final userId = user['id'];

        final posts = await api.getUserPosts(
          userId: userId,
          category: _selectedCategoryKey,
          page: _currentPage,
          size: _pageSize,
        );

        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      } else if (widget.pageType == PageType.myWinners) {
        final user = await api.getCurrentUser();
        if (user == null || user['id'] == null) {
          throw Exception('فشل في جلب بيانات المستخدم');
        }
        final userId = user['id'];
        final authBox = await Hive.openBox('authBox');
        final token = authBox.get('access_token');
        final posts = await api.getUserWonPosts(
          userId: userId,
          token: token,
          category: _selectedCategoryKey,
          page: _currentPage,
          size: _pageSize,
        );

        setState(() {
          _posts = posts;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ fetchPosts error: $e');
      setState(() {
        _error = 'حدث خطأ أثناء تحميل البيانات';
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialPosts != null) {
      _posts = widget.initialPosts!;
      _isLoading = false;
    } else {
      fetchPosts();
    }
    switch (widget.pageType) {
      case PageType.main:
        currentIndex = 0;
        break;
      case PageType.interested:
        currentIndex = 2;
        break;
      case PageType.myPosts:
        currentIndex = 3;
        break;
      case PageType.myWinners:
        break;
      case PageType.posts:
        // TODO: Handle this case.
        throw UnimplementedError();
    }

    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(() {
      if (mounted) {
        _handleScroll();
      }
    });

    _drawerHintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _drawerHintAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.12, 0),
    ).animate(
      CurvedAnimation(parent: _drawerHintController, curve: Curves.easeInOut),
    );
  }

  void _handleScroll() {
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _isAddBarVisible) {
      setState(() => _isAddBarVisible = false);
    } else if (direction == ScrollDirection.forward && !_isAddBarVisible) {
      setState(() => _isAddBarVisible = true);
    }
    if (_scrollController.offset > 300 && !_showScrollToTopButton) {
      setState(() => _showScrollToTopButton = true);
    } else if (_scrollController.offset <= 300 && _showScrollToTopButton) {
      setState(() => _showScrollToTopButton = false);
    }
  }

  @override
  void dispose() {
    _drawerHintController.dispose();
    _scrollController.removeListener(_handleScroll);
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  String _getPageTitle(PageType type) {
    switch (type) {
      case PageType.interested:
        return tr('home.title.interested');
      case PageType.myPosts:
        return tr('home.title.myPosts');
      case PageType.myWinners:
        return tr('home.title.myWinners');
      default:
        return tr('home.title.main');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    bool isRTL = context.locale.languageCode == 'ar';

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_posts == null) {
      return const Center(child: Text("No data loaded."));
    }

    List<Post> displayedPosts = _posts;
    if (widget.pageType != PageType.main) {
      final totalPages = (displayedPosts.length / _pageSize).ceil();
      final startIndex = (_currentPage - 1) * _pageSize;
      final endIndex = (_currentPage * _pageSize).clamp(
        0,
        displayedPosts.length,
      );
      displayedPosts = displayedPosts.sublist(startIndex, endIndex);
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: AuctionDrawer(selectedItem: _getPageTitle(widget.pageType)),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                widget.pageType == PageType.main
                    ? SearchBarWidget(
                      onSearchChanged: (query) {
                        setState(() {
                          _searchQuery = query;
                          fetchPosts(); // ⬅️ تأكد إنها تستدعي الفنكشن
                        });
                      },
                      onSortChanged: (sortKey) {
                        setState(() {
                          _selectedSortKey = sortKey;
                          fetchPosts(); // ⬅️ مهم إنها تتحدث عند الفلترة
                        });
                      },
                    )
                    : buildHeader(
                      context,
                      MediaQuery.of(context).size,
                      MediaQuery.of(context).size.width > 600,
                      _getPageTitle(widget.pageType),
                    ),
                CategoryCarousel(
                  onCategoryChanged: (selectedKey) {
                    setState(() => _selectedCategoryKey = selectedKey);
                    fetchPosts();
                  },
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      axisAlignment: -1.0,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child:
                      (widget.pageType == PageType.main && _isAddBarVisible)
                          ? const AddNewPostBar(key: ValueKey('addBar'))
                          : const SizedBox.shrink(key: ValueKey('empty')),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: displayedPosts.length + 1,
                    itemBuilder: (context, index) {
                      if (index < displayedPosts.length) {
                        return PostCard(
                          post: displayedPosts[index],
                          pageType: widget.pageType,
                        );
                      } else if (widget.pageType != PageType.main &&
                          _posts.length > _pageSize) {
                        final totalPages = (_posts.length / _pageSize).ceil();
                        List<Widget> pageButtons = [];

                        void addButton(int page) {
                          pageButtons.add(
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: GestureDetector(
                                onTap:
                                    () => setState(() => _currentPage = page),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _currentPage == page
                                            ? colorScheme.secondary
                                            : colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "$page",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          _currentPage == page
                                              ? colorScheme.onSecondary
                                              : colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        if (totalPages <= 7) {
                          for (int i = 1; i <= totalPages; i++) addButton(i);
                        } else {
                          addButton(1);
                          if (_currentPage > 4) {
                            pageButtons.add(
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Text(tr('home.pagination.ellipsis')),
                              ),
                            );
                          }
                          int start = (_currentPage - 1).clamp(
                            2,
                            totalPages - 4,
                          );
                          int end = (_currentPage + 1).clamp(3, totalPages - 1);
                          for (int i = start; i <= end; i++) addButton(i);
                          if (_currentPage < totalPages - 3) {
                            pageButtons.add(
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Text(tr('home.pagination.ellipsis')),
                              ),
                            );
                          }
                          addButton(totalPages);
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap:
                                    _currentPage > 1
                                        ? () => setState(() => _currentPage--)
                                        : null,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _currentPage > 1
                                            ? colorScheme.secondary
                                            : colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_ios_new,
                                    size: 16,
                                    color: colorScheme.onSecondary,
                                  ),
                                ),
                              ),
                              ...pageButtons,
                              GestureDetector(
                                onTap:
                                    _currentPage < totalPages
                                        ? () => setState(() => _currentPage++)
                                        : null,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _currentPage < totalPages
                                            ? colorScheme.secondary
                                            : colorScheme.surfaceVariant,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: colorScheme.onSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ],
            ),
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
                    color: colorScheme.primary.withOpacity(0.12),
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(10),
                      right: Radius.circular(10),
                    ),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 24,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
            if (_showScrollToTopButton)
              Positioned(
                bottom: 80,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                    setState(() {
                      _isAddBarVisible = true;
                    });
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: LowerBar(currentIndex: currentIndex, onTap: onTap),
    );
  }
}
