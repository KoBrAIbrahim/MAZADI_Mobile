import 'package:application/Router/app_route.dart';
import 'package:application/models/action.dart';
import 'package:application/models/bid.dart';
import 'package:application/models/post.dart';
import 'package:application/models/user.dart';
import 'package:application/setup/app_localization_setup.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
/*
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
*/

List<Bid> bids = [
  Bid(
    userId: 'user_1',
    userName: 'أحمد',
    amount: 1050.0,
    time: DateTime.now().subtract(Duration(minutes: 5)),
  ),
  Bid(
    userId: 'user_2',
    userName: 'ليلى',
    amount: 1100.0,
    time: DateTime.now().subtract(Duration(minutes: 3)),
  ),
  Bid(
    userId: 'user_3',
    userName: 'سامي',
    amount: 1150.0,
    time: DateTime.now().subtract(Duration(minutes: 1)),
  ),
];

List<Post> posts = [
  Post(
    id: 'post_1',
    title: 'لابتوب',
    description: 'لابتوب بحالة ممتازة, موديل 2023, شاشة LED',
    startPrice: 1000.0,
    currentBid: 1150.0,
    bid_step: 50.0,
    media: ['assets/images/laptop3.png', 'assets/images/laptop1.jfif'],
    sellerId: 'seller_1',
    sellerName: 'باسم',
    sellerAvatar: 'assets/avatars/seller_1.jpg',
    category: 'إلكترونيات',
    numberOfOnAuction: 1,
    viewCount: 120,
    isLive: "IN_PROGRASS",
    bids: bids,
    numberOfBidders: bids.length,
    isFav: true,
  ),
  Post(
    id: 'post_2',
    title: 'سماعة',
    description: 'سماعة أصلية استعمال خفيف...',
    startPrice: 80.0,
    currentBid: 110.0,
    bid_step: 10.0,
    media: ['assets/images/airpod1.jfif'],
    sellerId: 'seller_2',
    sellerName: 'سارة',
    sellerAvatar: 'assets/avatars/seller_2.jpg',
    category: 'إلكترونيات',
    numberOfOnAuction: 2,
    viewCount: 75,
    isLive: "WAITING",
    bids: [],
    numberOfBidders: 0,
    isFav: true,
  ),
  Post(
    id: 'post_3',
    title: 'AIR_',
    description: 'سماعة أصلية استعمال خفيف...',
    startPrice: 80.0,
    currentBid: 110.0,
    bid_step: 10.0,
    media: ['assets/images/airpod2.jfif'],
    sellerId: 'seller_2',
    sellerName: 'سارة',
    sellerAvatar: 'assets/avatars/seller_2.jpg',
    category: 'إلكترونيات',
    numberOfOnAuction: 2,
    viewCount: 75,
    isLive: "COMPLETED",
    bids: [],
    numberOfBidders: 0,
    isFav: false,
  ),
];

List<Post> posts_1 = [
  Post(
    id: 'post_4',
    title: 'AIR_',
    description: 'سماعة أصلية استعمال خفيف...',
    startPrice: 80.0,
    currentBid: 110.0,
    bid_step: 10.0,
    media: ['assets/images/airpod2.jfif'],
    sellerId: 'seller_2',
    sellerName: 'سارة',
    sellerAvatar: 'assets/avatars/seller_2.jpg',
    category: 'سيارات',
    numberOfOnAuction: 2,
    viewCount: 75,
    isLive: "WAITING",
    bids: [],
    numberOfBidders: 0,
    isFav: true,
  ),

  Post(
    id: 'post_5',
    title: 'AIR_',
    description: 'سماعة أصلية استعمال خفيف...',
    startPrice: 80.0,
    currentBid: 110.0,
    bid_step: 10.0,
    media: ['assets/images/airpod2.jfif'],
    sellerId: 'seller_2',
    sellerName: 'سارة',
    sellerAvatar: 'assets/avatars/seller_2.jpg',
    category: 'سيارات',
    numberOfOnAuction: 2,
    viewCount: 75,
    isLive: "IN_PROGRASS",
    bids: [],
    numberOfBidders: 0,
    isFav: true,
  ),
];

List<Auction> auctions = [
  Auction(
    id: 'auction_1',
    title: 'مزاد الإلكترونيات',
    category: 'إلكترونيات',
    endTime: DateTime.now().add(Duration(hours: 12)),
    posts: posts,
    viewCount: 300,
    participantCount: 20,
    thumbnailUrl: 'assets/auctions/إلكترونيات_1.jpg',
    currentHighestBid: 1150.0,
  ),
  // يمكنك إضافة المزيد:
  Auction(
    id: 'auction_2',
    title: 'مزاد سيارات',
    category: 'سيارات',
    endTime: DateTime.now().add(Duration(hours: 24)),
    posts: posts_1, // ← غيرها حسب الحاجة
    viewCount: 150,
    participantCount: 8,
    thumbnailUrl: 'assets/auctions/ملابس_1.jpg',
    currentHighestBid: 85.0,
  ),
];

final User testUser = User(
  id: 1,
  firstName: "Ibrahim",
  lastName: "Ghanem",
  email: "ibrahim@example.com",
  password: "securePassword123",
  phoneNumber: "+962790000000",
  city: "جنين",
  gender: "ذكر",
  lastLogin: DateTime.now(),
  rating: 4.8,
  role: "Customer",
  status: "Active",
  paymentToken: "tok_abc123",
  lahzaCustomerId: "cus_456def",
  last4: 1234,
  cardBrand: "Visa",
  my_posts: posts,
  winner_posts: posts_1,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  await Hive.initFlutter();

  var settingsBox = await Hive.openBox('settings');

  String? savedLangCode = settingsBox.get('language', defaultValue: 'ar');
  Locale startLocale = Locale(savedLangCode ?? 'ar');

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/langs',
      fallbackLocale: const Locale('ar'),
      startLocale: Locale(savedLangCode ?? 'ar'),
      child: const MazadiApp(),
    ),
  );
}

class MazadiApp extends StatelessWidget {
  const MazadiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: tr('app.title'),
          theme: ThemeData(
            fontFamily: 'Cairo',
            scaffoldBackgroundColor: Colors.white,
          ),
          locale: context.locale,
          supportedLocales: context.supportedLocales,
          localizationsDelegates: context.localizationDelegates,
          routerConfig: appRouter,
        );
      },
    );
  }
}
