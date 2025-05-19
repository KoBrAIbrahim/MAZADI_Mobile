import 'package:application/models/post.dart';
import 'package:application/screens/Main_User_Pages.dart/home_page.dart';
import 'package:flutter/material.dart';

List<Post> posts = [
  Post(
    title: 'لابتوب',
    category: 'إلكترونيات',
    description: 'لابتوب بحالة ممتازة, لابتوب مودل 2023, شاشة LED',
    startPrice: 1000.0,
    media: [
      'assets/images/laptop3.png',
      'assets/images/laptop1.jfif',
      'assets/images/laptop2.jfif',
      'assets/images/airpod2.jfif',
    ],
    bidStep: 50.0,
    status: 'active',
    numberOfOnAuction: 1 ,
  ),
  Post(
    title: 'سماعة',
    category: 'إلكترونيات',
    description: 'سماعة أصلية استعمال خفيف...',
    startPrice: 80.0,
    media: ['assets/images/airpod1.jfif', 'assets/images/airpod2.jfif'],
    bidStep: 10.0,
    status: 'active',
    numberOfOnAuction: 2 ,
  ),

   Post(
    title: 'سماعة',
    category: 'إلكترونيات',
    description: 'سماعة أصلية استعمال خفيف...',
    startPrice: 80.0,
    media: ['assets/images/airpod1.jfif', 'assets/images/airpod2.jfif'],
    bidStep: 10.0,
    status: 'active',
    numberOfOnAuction: 4 ,
  ),

   Post(
    title: 'سماعة',
    category: 'إلكترونيات',
    description: 'سماعة أصلية استعمال خفيف...',
    startPrice: 80.0,
    media: ['assets/images/airpod1.jfif', 'assets/images/airpod2.jfif'],
    bidStep: 10.0,
    status: 'active',
    numberOfOnAuction: 6 ,
  ),

   Post(
    title: 'سماعة',
    category: 'إلكترونيات',
    description: 'سماعة أصلية استعمال خفيف...',
    startPrice: 80.0,
    media: ['assets/images/airpod1.jfif', 'assets/images/airpod2.jfif'],
    bidStep: 10.0,
    status: 'active',
    numberOfOnAuction: 7 ,
  ),
];

void main() {
  runApp(const MazadiApp());
}

class MazadiApp extends StatelessWidget {
  const MazadiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'مزادي',
      theme: ThemeData(
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomePage(posts: posts),
    );
  }
}
