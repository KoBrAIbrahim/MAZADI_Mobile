import 'dart:async';
import 'package:application/API_Service/api.dart';
import 'package:application/models/post_2.dart';
import 'package:application/screens/Main_User_Pages.dart/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class InterestedPage extends StatefulWidget {
  const InterestedPage({Key? key}) : super(key: key);

  @override
  State<InterestedPage> createState() => _InterestedPageState();
}

class _InterestedPageState extends State<InterestedPage> {
  int currentPage = 1;
  final int pageSize = 10;

  List<Post> displayedFavPosts = [];

  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _hasMore = true;
  String? _error;

  String? _token;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _initAuthAndFetch();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMore) {
        _fetchFavPosts();
      }
    });
  }

  Future<void> _initAuthAndFetch() async {
    try {
      final authBox = await Hive.openBox('authBox');
      _token = authBox.get('access_token');
      ApiService api = ApiService();
      final userData = await api.getCurrentUser();
      _userId  = userData?['id'];

      if (_token == null || _userId == null) {
        throw Exception("User ID or token missing");
      }

      _fetchFavPosts();
    } catch (e, stackTrace) {
      print('❌ ERROR during interested fetch: $e');
      print('📌 StackTrace: $stackTrace');

      setState(() {
        _error = 'فشل في تحميل البيانات.';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchFavPosts() async {
    try {
      setState(() => _isLoading = true);

      final api = ApiService();
      final posts = await api.getInterestedPosts(
        userId: _userId!,
        token: _token!,
        page: currentPage,
        size: pageSize,
      );

      setState(() {
        displayedFavPosts.addAll(posts);
        currentPage++;
        _isLoading = false;
        if (posts.length < pageSize) _hasMore = false;
      });
    } catch (e) {
      setState(() {
        _error = 'فشل تحميل البيانات.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && displayedFavPosts.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(child: Text(_error!, style: TextStyle(color: Colors.red))),
      );
    }

    return HomePage(
      pageType: PageType.interested,
      scrollController: _scrollController,
      initialPosts: displayedFavPosts,
    );
  }
}
