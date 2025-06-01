import 'package:application/models/bid.dart';

class Post {
  final int id;
  String title;
  String description;
  double startPrice;
  double? currentBid;
  int? numberOfOnAuction;
  String? sellerId;
  String? sellerName;
  String? sellerAvatar;
  List<String> media;
  String category;
  int viewCount;
  List<Bid> bids;
  String? isLive;
  int? numberOfBidders;
  double bidStep;
  bool isFav;
  String status;
  double? finalPrice;
  int? numberOfPostInAuction;

  Post({
    required this.id,
    required this.title,
    required this.description,
    required this.startPrice,
    this.currentBid,
    this.numberOfOnAuction,
    this.sellerId,
    this.sellerName,
    this.sellerAvatar,
    required this.media,
    required this.category,
    required this.viewCount,
    this.bids = const [],
    this.isLive,
    this.numberOfBidders,
    required this.bidStep,
    this.isFav = false,
    required this.status,
    this.finalPrice,
  });
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startPrice: json['startPrice'].toDouble(),
      category: json['category'],
      media:
          json['media'] != null
              ? json['media'].toString().split(',')
              : <String>[],
      bidStep: json['bidStep'],
      status: json['status'],
      finalPrice: json['finalPrice']?.toDouble(),
      viewCount: json['viewCount'],
      numberOfOnAuction: json['auctionPostNumber'] ?? 0,
    );
  }
}
