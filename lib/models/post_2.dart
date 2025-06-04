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
  String? isLive; // Keep for backward compatibility
  int? numberOfBidders;
  double bidStep;
  bool isFav;
  String status; // This is the actual status from API (WAITING, IN_PROGRESS, COMPLETED)
  double? finalPrice;
  int? numberOfPostInAuction;
  bool isAccepted;
  DateTime? createdDate;

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
    this.numberOfPostInAuction,
    this.isAccepted = false,
    this.createdDate,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startPrice: (json['startPrice'] ?? 0).toDouble(),
      currentBid: json['currentBid']?.toDouble(),
      category: json['category'] ?? '',
      media: json['media'] != null
          ? json['media'].toString().split(',').where((s) => s.isNotEmpty).toList()
          : <String>[],
      bidStep: (json['bidStep'] ?? 0).toDouble(),
      status: json['status'] ?? 'WAITING',
      finalPrice: json['finalPrice']?.toDouble(),
      viewCount: json['viewCount'] ?? 0,
      numberOfOnAuction: json['auctionPostNumber'] ?? json['numberOfOnAuction'],
      sellerId: json['sellerId']?.toString(),
      sellerName: json['sellerName'],
      sellerAvatar: json['sellerAvatar'],
      numberOfBidders: json['numberOfBidders'],
      isFav: json['isFav'] ?? false,
      isAccepted: json['isAccepted'] ?? false,
      numberOfPostInAuction: json['numberOfPostInAuction'],
      createdDate: json['createdDate'] != null
          ? DateTime.tryParse(json['createdDate'].toString())
          : null,
      // For backward compatibility, map status to isLive
      isLive: _mapStatusToIsLive(json['status']),
      // Parse bids if available
      bids: json['auctionBidTrackers'] != null
          ? (json['auctionBidTrackers'] as List<dynamic>)
          .map((bidJson) => Bid.fromJson(bidJson))
          .toList()
          : [],
    );
  }

  // Helper method to map status to isLive for backward compatibility
  static String _mapStatusToIsLive(String? status) {
    switch (status) {
      case 'IN_PROGRESS':
        return 'IN_PROGRASS'; // Keep the original typo for compatibility
      case 'COMPLETED':
        return 'COMPLETED';
      case 'WAITING':
      default:
        return 'WAITING';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startPrice': startPrice,
      'currentBid': currentBid,
      'category': category,
      'media': media.join(','),
      'bidStep': bidStep,
      'status': status,
      'finalPrice': finalPrice,
      'viewCount': viewCount,
      'auctionPostNumber': numberOfOnAuction,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerAvatar': sellerAvatar,
      'numberOfBidders': numberOfBidders,
      'isFav': isFav,
      'isAccepted': isAccepted,
      'numberOfPostInAuction': numberOfPostInAuction,
      'createdDate': createdDate?.toIso8601String(),
      'bids': bids.map((bid) => bid.toJson()).toList(),
    };
  }

  // Helper getters for UI
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isWaiting => status == 'WAITING';
  bool get isCompleted => status == 'COMPLETED';

  String get displayPrice {
    if (currentBid != null && currentBid! > 0) {
      return currentBid!.toStringAsFixed(2);
    }
    return startPrice.toStringAsFixed(2);
  }

  String get statusDisplayText {
    switch (status) {
      case 'IN_PROGRESS':
        return 'Live';
      case 'COMPLETED':
        return 'Sold';
      case 'WAITING':
      default:
        return 'Coming Soon';
    }
  }
}