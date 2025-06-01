class Bid {
  final String userId;
  final String userName;
  final double amount;
  final DateTime time;

  Bid({
    required this.userId,
    required this.userName,
    required this.amount,
    required this.time,
  });

  factory Bid.fromJson(Map<String, dynamic> json) {
  return Bid(
    userId: json['userId'] ?? '',
    userName: json['userName'] ?? '',
    amount: (json['amount'] ?? 0).toDouble(),
    time: DateTime.parse(json['time']),
  );
}
}
