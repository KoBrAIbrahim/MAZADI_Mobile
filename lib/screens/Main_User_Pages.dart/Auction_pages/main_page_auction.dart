import 'package:application/models/action.dart';
import 'package:application/models/bid.dart';
import 'package:application/models/post.dart';
import 'package:application/screens/Main_User_Pages.dart/Auction_pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

final List<String> categories = [
  'إلكترونيات',
  'سيارات',
  'عقارات',
  'أثاث',
  'ملابس',
  'أخرى',
];

class AuctionApp extends StatelessWidget {
  final List<Auction> auction;
  final List<Post> posts;
  final List<Bid> bids;

  const AuctionApp({
    Key? key,
    required this.auction,
    required this.posts,
    required this.bids,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مزادي',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Cairo',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 2,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: HomeScreen(
        auction: auction,
        posts: posts,
        bids: bids,
        categories: categories,
      ),
    );
  }
}
