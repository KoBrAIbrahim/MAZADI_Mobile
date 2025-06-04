import 'package:application/models/post_2.dart';
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

GoRouter appRouter(String startRoute) {
  return GoRouter(
    initialLocation: startRoute,
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
      GoRoute(path: '/home_page', builder: (context, state) => HomePage()),
      GoRoute(
        path: '/auction_home_page',
        builder: (context, state) {
          return AuctionHomePage();
        },
      ),
      GoRoute(
        path: '/bid_bottom_sheet',
        builder: (context, state) {
          return BidBottomSheet(
            post: state.extra as Post,
          );
        },
      ),
      GoRoute(
        path: '/auction_detail',
        builder: (context, state) {
          return AuctionDetailPage(
            post: state.extra as Post,
            auctionId: state.extra as int ,
          );
        },
      ),
      GoRoute(
        path: '/home_screen',
        builder: (context, state) {
          return HomeScreen();
        },
      ),
      GoRoute(
        path: '/main_auction',
        builder: (context, state) {
          return AuctionApp();
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
        builder: (context, state) => InterestedPage(),
      ),
      GoRoute(path: '/my_posts', builder: (context, state) => MyPostsPage()),
      GoRoute(path: '/winners', builder: (context, state) => MyWinnersPage()),
      GoRoute(
        path: '/add_post',
        builder: (context, state) => const AddPostPage(),
      ),
      GoRoute(
        path: '/details_post/:postId/:pageType',
        name: 'detailsPost',
        builder: (context, state) {
          final postId = state.pathParameters['postId'];
          final pageTypeString = state.pathParameters['pageType'];

          final pageType = PageType.values.firstWhere(
            (e) => e.name == pageTypeString,
          );

          return DetailsPostPage(postId: postId, pageType: pageType);
        },
      ),

      GoRoute(path: '/profile', builder: (context, state) => ProfilePage()),
      GoRoute(
        path: '/change_password',
        builder: (context, state) => ChangePasswordPage(),
      ),
    ],
  );
}
