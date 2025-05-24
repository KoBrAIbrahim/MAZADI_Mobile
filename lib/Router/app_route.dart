import 'package:application/models/post.dart';
import 'package:application/models/user.dart';
import 'package:application/screens/Setting/setting_page.dart';
import 'package:application/screens/TechnicalSupport/about_app_page.dart';
import 'package:application/screens/TechnicalSupport/technical_support_page.dart';
import 'package:application/screens/signup_Pages/account_signup_page.dart';
import 'package:application/screens/signup_Pages/confirm_signup_page.dart';
import 'package:application/screens/signup_Pages/info_signup_page.dart';
import 'package:go_router/go_router.dart';

import 'package:application/screens/welcome_page.dart';
import 'package:application/screens/Forget_Password/forget_page.dart';
import 'package:application/screens/Login_Pages/login_page.dart';
import 'package:application/screens/Main_User_Pages.dart/home_page.dart';
import 'package:application/screens/Main_User_Pages.dart/Auction_pages/auction_home_page.dart';
import 'package:application/screens/Main_User_Pages.dart/Auction_pages/bid_button_sheet.dart';
import 'package:application/screens/Main_User_Pages.dart/Auction_pages/detalis_auction.dart';
import 'package:application/screens/Main_User_Pages.dart/Auction_pages/home_screen.dart';
import 'package:application/screens/Main_User_Pages.dart/Auction_pages/main_page_auction.dart';
import 'package:application/screens/Main_User_Pages.dart/dashboard.dart/dashboard_page.dart';
import 'package:application/screens/Main_User_Pages.dart/filter/filter_page.dart';
import 'package:application/screens/Main_User_Pages.dart/interested_pages/main_interested_page.dart';
import 'package:application/screens/Main_User_Pages.dart/MyPost/my_post_page.dart';
import 'package:application/screens/Main_User_Pages.dart/my_winner_auction_page.dart/wiiner_post_page.dart';
import 'package:application/screens/Main_User_Pages.dart/Posts/add_post.dart';
import 'package:application/screens/Main_User_Pages.dart/Posts/details_post_page.dart';
import 'package:application/screens/Main_User_Pages.dart/Profile_Page/edit_profile_sheet.dart';
import 'package:application/screens/Main_User_Pages.dart/Profile_Page/profile_page.dart';
import 'package:application/screens/Main_User_Pages.dart/Profile_Page/change_pass_page/change_pass.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const StartupPage()),
    GoRoute(
      path: '/forget_password',
      builder: (context, state) => const ForgetPasswordPage(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignUpPage()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/support',
      builder: (context, state) => const TechnicalSupportPage(),
    ),
    GoRoute(
      path: '/about_us',
      builder: (context, state) => const AboutAppPage(),
    ),
    GoRoute(
      path: '/account_signup_page',
      builder: (context, state) => const AccountSignUpPage(),
    ),
    GoRoute(
      path: '/confirm_signup_page',
      builder: (context, state) => const ConfirmSignUpPage(),
    ),
    GoRoute(
      path: '/home_page',
      builder: (context, state) => HomePage(posts: state.extra as List<Post>),
    ),
    GoRoute(
      path: '/auction_home_page',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return AuctionHomePage(
          auction: data['auction'],
          posts: data['posts'],
          bids: data['bids'],
          categories: data['categories'],
        );
      },
    ),
    GoRoute(
      path: '/bid_bottom_sheet',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return BidBottomSheet(
          onBidPlaced: data['onBidPlaced'],
          post: data['post'],
        );
      },
    ),
    GoRoute(
      path: '/auction_detail',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return AuctionDetailPage(
          auction: data['auction'],
          posts: data['posts'],
          bids: data['bids'],
        );
      },
    ),
    GoRoute(
      path: '/home_screen',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return HomeScreen(
          auction: data['auction'],
          posts: data['posts'],
          bids: data['bids'],
          categories: data['categories'],
        );
      },
    ),
    GoRoute(
      path: '/main_auction',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return AuctionApp(
          auction: data['auction'],
          posts: data['posts'],
          bids: data['bids'],
        );
      },
    ),
    GoRoute(
      path: '/dashboard',
      builder:
          (context, state) =>
              AuctionDrawer(selectedItem: state.extra as String),
    ),

    GoRoute(path: '/filter', builder: (context, state) => const FilterPage()),
    GoRoute(
      path: '/interested',
      builder:
          (context, state) =>
              InterestedPage(allPosts: state.extra as List<Post>),
    ),
    GoRoute(
      path: '/my_posts',
      builder:
          (context, state) => MyPostsPage(myPosts: state.extra as List<Post>),
    ),
    GoRoute(
      path: '/winners',
      builder:
          (context, state) =>
              MyWinnersPage(winnerPosts: state.extra as List<Post>),
    ),
    GoRoute(
      path: '/add_post',
      builder: (context, state) => const AddPostPage(),
    ),
    GoRoute(
      path: '/details_post',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return DetailsPostPage(post: data['post'], pageType: data['pageType']);
      },
    ),
    GoRoute(
      path: '/edit_profile',
      builder: (context, state) => EditProfileSheet(user: state.extra as User),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => ProfilePage(user: state.extra as User),
    ),
    GoRoute(
      path: '/change_password',
      builder:
          (context, state) => ChangePasswordPage(user: state.extra as User),
    ),
  ],
);
