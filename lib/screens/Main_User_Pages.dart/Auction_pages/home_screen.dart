import 'dart:async';
import 'package:application/API_Service/api.dart';
import 'package:application/models/action.dart';
import 'package:application/models/bid.dart';
import 'package:application/models/post_2.dart';
import 'package:application/screens/Main_User_Pages.dart/Auction_pages/auction_home_page.dart';
import 'package:application/screens/Main_User_Pages.dart/dashboard.dart/dashboard_page.dart';
import 'package:application/widgets/main_page/lower_bar_pages.dart';
import 'package:flutter/material.dart';
import 'package:application/constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _drawerHintController;
  late Animation<Offset> _drawerHintAnimation;
  bool _isLoading = true;
  String? _error;
  List<Auction> _auctions = [];
  List<Post> _posts = [];
  List<Bid> _bids = [];
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
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

    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final api = ApiService();
      final auctions = await api.getAllAuctions();
      final posts = await api.getAllPosts();
      final bids = await api.getAllBids();
      final categories = await api.getCategories();

      setState(() {
        _auctions = auctions!;
        _posts = posts!;
        _bids = bids!;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'فشل تحميل البيانات';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _drawerHintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    return Scaffold(
      drawer: const AuctionDrawer(selectedItem: 'auctions'),
      body: Stack(
        children: [
          AuctionHomePage(

          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 16,
            left: Directionality.of(context) == TextDirection.rtl ? null : 0,
            right: Directionality.of(context) == TextDirection.rtl ? 0 : null,
            child: SlideTransition(
              position: _drawerHintAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(10),
                    right: Radius.circular(10),
                  ),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 1.5),
                    ),
                  ],
                ),
                child: Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.arrow_forward
                      : Icons.arrow_forward,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: LowerBar(currentIndex: 1, onTap: (_) {}),
    );
  }
}
