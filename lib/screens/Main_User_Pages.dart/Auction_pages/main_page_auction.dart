import 'package:application/models/action.dart';
import 'package:application/models/bid.dart';
import 'package:application/models/post.dart';
import 'package:application/screens/Main_User_Pages.dart/Auction_pages/home_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';


class AuctionApp extends StatelessWidget {
  final List<Auction> auction;
  final List<Post> posts;
  final List<Bid> bids;

  const AuctionApp({
    super.key,
    required this.auction,
    required this.posts,
    required this.bids,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      'category_electronics'.tr(),
      'category_cars'.tr(),
      'category_real_estate'.tr(),
      'category_furniture'.tr(),
      'category_clothing'.tr(),
      'category_other'.tr(),
    ];
    

    return HomeScreen(
      auction: auction,
      posts: posts,
      bids: bids,
      categories: categories,
    );
  }
}

