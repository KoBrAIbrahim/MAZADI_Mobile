import 'package:application/models/bid.dart';
import 'package:application/screens/Main_User_Pages.dart/Auction_pages/main_page_auction.dart';

class Post {
  final String id;
  String title;
  String description;
  double startPrice;
  final double currentBid;
  int numberOfOnAuction;
  String sellerId;
  String sellerName;
  String sellerAvatar;
  List<String> media;
  String category;
  int viewCount;
  List<Bid> bids;
  String isLive;
  int numberOfBidders;
  double bid_step;
  bool isFav;

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.startPrice,
    required this.currentBid,
    required this.numberOfOnAuction,
    required this.sellerId,
    required this.sellerName,
    required this.sellerAvatar,
    required this.media,
    required this.category,
    required this.viewCount,
    required this.bids,
    required this.isLive,
    required this.numberOfBidders,
    required this.bid_step,
    required this.isFav,
  });
}
