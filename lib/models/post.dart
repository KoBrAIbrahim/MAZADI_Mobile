class Post {
  final String title;
  final String category;
  final String description;
  final double startPrice;
  final List<String> media;
  final double bidStep;
  final String status;
  final int numberOfOnAuction;

  Post({
    required this.title,
    required this.category,
    required this.description,
    required this.startPrice,
    required this.media,
    required this.bidStep,
    required this.status,
    required this.numberOfOnAuction,
  });
}
