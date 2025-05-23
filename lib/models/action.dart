import 'package:application/models/post.dart';

class Auction {
  final String id;
  final String title;
  final String category;
  final DateTime endTime;
  final List<Post> posts;
  final int viewCount;
  final int participantCount;
  final String thumbnailUrl;
  final double currentHighestBid;

  Auction({
    required this.id,
    required this.title,
    required this.category,
    required this.endTime,
    required this.posts,
    required this.viewCount,
    required this.participantCount,
    required this.thumbnailUrl,
    required this.currentHighestBid,
  });
}