class Bid {
  final int userId;
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
      userId: json['id'] ?? '',
      userName: json['userIdentifier'] ?? '',
      amount: (json['bidAmount'] ?? 0).toDouble(),
      time: DateTime.parse(json['timestamp']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'userIdentifier': userName,
      'bidAmount': amount,
      'timestamp': time.toIso8601String(),
    };
  }
}