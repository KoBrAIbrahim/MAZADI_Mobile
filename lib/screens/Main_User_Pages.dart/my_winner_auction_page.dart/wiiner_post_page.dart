import 'dart:async';
import 'package:application/API_Service/api.dart';
import 'package:application/models/post_2.dart';
import 'package:application/screens/Main_User_Pages.dart/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class MyWinnersPage extends StatefulWidget {
  const MyWinnersPage({Key? key}) : super(key: key);

  @override
  State<MyWinnersPage> createState() => _MyWinnersPageState();
}

class _MyWinnersPageState extends State<MyWinnersPage> {
  int currentPage = 1;
  final int pageSize = 10;

  List<Post> allWinnerPosts = [];
  List<Post> displayedWinnerPosts = [];

  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchWinnerPosts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        loadMoreWinnerPosts();
      }
    });
  }

Future<void> fetchWinnerPosts() async {
  try {
    final api = ApiService();

    final userData = await api.getCurrentUser();
    if (userData == null || userData['id'] == null) {
      throw Exception("فشل في جلب بيانات المستخدم");
    }

    final int userId = userData['id'];
    final authBox = await Hive.openBox('authBox');
    final token = authBox.get('access_token');

    if (token == null) {
      throw Exception("فشل في جلب التوكن");
    }

    final posts = await api.getUserWonPosts(
      userId: userId,
      token: token,
      page: currentPage,
      size: pageSize,
    );

    allWinnerPosts = posts;
    displayedWinnerPosts = posts;

    setState(() => _isLoading = false);
  } catch (e) {
    setState(() {
      _error = 'فشل تحميل البيانات';
      _isLoading = false;
    });
    print("❌ Error in fetchWinnerPosts: $e");
  }
}


  void loadMoreWinnerPosts() {
    final start = (currentPage - 1) * pageSize;
    final end = (start + pageSize).clamp(0, allWinnerPosts.length);

    if (start >= allWinnerPosts.length) return;

    setState(() {
      displayedWinnerPosts.addAll(allWinnerPosts.sublist(start, end));
      currentPage++;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!, style: const TextStyle(color: Colors.red))),
      );
    }

    return HomePage(
      pageType: PageType.myWinners,
      scrollController: _scrollController,
      initialPosts: allWinnerPosts,
    );
  }
}
