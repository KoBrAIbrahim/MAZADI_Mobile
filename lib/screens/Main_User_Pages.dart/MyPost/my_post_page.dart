import 'dart:async';
import 'package:application/API_Service/api.dart';
import 'package:application/models/post_2.dart';
import 'package:application/screens/Main_User_Pages.dart/home_page.dart';
import 'package:flutter/material.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({Key? key}) : super(key: key);

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  int currentPage = 1;
  final int pageSize = 10;

  List<Post> displayedUserPosts = [];

  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _hasMore = true;
  String? _error;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _initAndFetch();

    _scrollController.addListener(() {
      if (!mounted) return;

      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        loadMoreUserPosts();
      }
    });
  }

  Future<void> _initAndFetch() async {
    final api = ApiService();
    try {
      final userData = await api.getCurrentUser();
      if (userData == null || userData['id'] == null) {
        throw Exception("فشل في جلب بيانات المستخدم");
      }

      _userId = userData['id'];
      await fetchUserPosts(); // أول تحميل
    } catch (e) {
      setState(() {
        _error = 'فشل تحميل البيانات';
        _isLoading = false;
      });
      print("❌ Error in _initAndFetch: $e");
    }
  }

  Future<void> fetchUserPosts() async {
    if (!_hasMore || _userId == null) return;

    setState(() => _isLoading = true);

    try {
      final api = ApiService();
      final posts = await api.getUserPosts(
        userId: _userId!,
        page: currentPage,
        size: pageSize,
      );

      setState(() {
        for (var post in posts) {
          if (!displayedUserPosts.any((p) => p.id == post.id)) {
            displayedUserPosts.add(post);
          }
        }

        if (posts.length < pageSize) _hasMore = false;
        currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'فشل تحميل البيانات';
        _isLoading = false;
      });
      print("❌ Error in fetchUserPosts: $e");
    }
  }

  void loadMoreUserPosts() {
    if (!_isLoading) {
      fetchUserPosts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && displayedUserPosts.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
            child: Text(_error!, style: const TextStyle(color: Colors.red))),
      );
    }

    return HomePage(
      pageType: PageType.myPosts,
      scrollController: _scrollController,
      initialPosts: displayedUserPosts,
    );
  }
}
