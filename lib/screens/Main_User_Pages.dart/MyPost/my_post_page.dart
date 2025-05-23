import 'package:application/models/post.dart';
import 'package:application/screens/Main_User_Pages.dart/home_page.dart';
import 'package:flutter/material.dart';

class MyPostsPage extends StatefulWidget {
  final List<Post> myPosts;

  const MyPostsPage({Key? key, required this.myPosts}) : super(key: key);

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  int currentPage = 1;
  final int pageSize = 10;

  late List<Post> allUserPosts;
  List<Post> displayedUserPosts = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    allUserPosts = widget.myPosts;
    loadMoreUserPosts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        loadMoreUserPosts();
      }
    });
  }

  void loadMoreUserPosts() {
    final start = (currentPage - 1) * pageSize;
    final end = (start + pageSize).clamp(0, allUserPosts.length);

    if (start >= allUserPosts.length) return;

    setState(() {
      displayedUserPosts.addAll(allUserPosts.sublist(start, end));
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
      posts: displayedUserPosts,
      pageType: PageType.myPosts,
      scrollController: _scrollController,
    );
  }
}
