
import 'package:application/screens/Main_User_Pages.dart/Auction_pages/home_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';


class AuctionApp extends StatelessWidget {


  const AuctionApp({
    super.key,

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

    );
  }
}

