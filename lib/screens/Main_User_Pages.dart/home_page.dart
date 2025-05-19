import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:application/models/post.dart';
import 'package:application/widgets/main_page/add_post_bar.dart';
import 'package:application/widgets/main_page/category_carousel.dart';
import 'package:application/widgets/main_page/lower_bar_pages.dart';
import 'package:application/widgets/main_page/search_bar.dart';
import 'package:application/widgets/post/post_card.dart';

class HomePage extends StatefulWidget {
  final List<Post> posts;

  const HomePage({super.key, required this.posts});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;
  late ScrollController _scrollController;
  bool _isAddBarVisible = true;

  void onTap(int index) {
    setState(() => currentIndex = index);
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final direction = _scrollController.position.userScrollDirection;

    if (direction == ScrollDirection.reverse && _isAddBarVisible) {
      setState(() => _isAddBarVisible = false);
    } else if (direction == ScrollDirection.forward && !_isAddBarVisible) {
      setState(() => _isAddBarVisible = true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            const SearchBarWidget(),
            const CategoryCarousel(),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1.0,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: _isAddBarVisible
                  ? const AddNewPostBar(key: ValueKey('addBar'))
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),

            const SizedBox(height: 10),

            // ✅ List of Posts
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: widget.posts.length,
                itemBuilder: (context, index) {
                  return PostCard(post: widget.posts[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: LowerBar(
        currentIndex: currentIndex,
        onTap: onTap,
      ),
    );
  }
}
