import 'package:application/models/post.dart';
import 'package:application/screens/Main_User_Pages.dart/home_page.dart';
import 'package:flutter/material.dart';

class InterestedPage extends StatefulWidget {
  final List<Post> allPosts;

  const InterestedPage({Key? key, required this.allPosts}) : super(key: key);

  @override
  State<InterestedPage> createState() => _InterestedPageState();
}

class _InterestedPageState extends State<InterestedPage> {
  int currentPage = 1;
  final int pageSize = 10;

  late List<Post> allFavPosts;
  List<Post> displayedFavPosts = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    allFavPosts = widget.allPosts.where((post) => post.isFav).toList();
    loadMoreFavPosts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        loadMoreFavPosts();
      }
    });
  }

  void loadMoreFavPosts() {
    final start = (currentPage - 1) * pageSize;
    final end = (start + pageSize).clamp(0, allFavPosts.length);

    if (start >= allFavPosts.length) return;

    setState(() {
      displayedFavPosts.addAll(allFavPosts.sublist(start, end));
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
    return HomePage(
      posts: displayedFavPosts,
     pageType: PageType.interested,
      scrollController: _scrollController,
    );
  }
}
