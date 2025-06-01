import 'package:application/models/post_2.dart';

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

  factory Auction.fromJson(Map<String, dynamic> json) {
  return Auction(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    category: json['category'] ?? '',
    endTime: DateTime.parse(json['endTime']),
    posts: (json['posts'] as List<dynamic>? ?? [])
        .map((postJson) => Post.fromJson(postJson))
        .toList(),
    viewCount: json['viewCount'] ?? 0,
    participantCount: json['participantCount'] ?? 0,
    thumbnailUrl: json['thumbnailUrl'] ?? '',
    currentHighestBid: (json['currentHighestBid'] ?? 0).toDouble(),
  );
}

}