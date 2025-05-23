import 'package:flutter/material.dart';
import 'package:application/models/post.dart';
import 'package:application/screens/Main_User_Pages.dart/home_page.dart';

class MyWinnersPage extends StatefulWidget {
  final List<Post> winnerPosts;

  const MyWinnersPage({Key? key, required this.winnerPosts}) : super(key: key);

  @override
  State<MyWinnersPage> createState() => _MyWinnersPageState();
}

class _MyWinnersPageState extends State<MyWinnersPage> {
  int currentPage = 1;
  final int pageSize = 10;

  late List<Post> allWinnerPosts;
  List<Post> displayedWinnerPosts = [];

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    allWinnerPosts = widget.winnerPosts;
    loadMoreWinnerPosts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        loadMoreWinnerPosts();
      }
    });
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
    return HomePage(
      posts: displayedWinnerPosts,
      pageType: PageType.myWinners,
      scrollController: _scrollController,
    );
  }
}
