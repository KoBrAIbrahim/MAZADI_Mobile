import 'package:application/models/post_2.dart';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone; // Changed from phoneNumber to match API
  final String city;
  final String gender;
  final String role;
  DateTime? createdDate;  // Added to match API
  DateTime? updatedDate;  // Added to match API
  DateTime? lastLogin;
  double rating;
  String status;
  String? paymentToken;
  String? lahzaCustomerId;
  int last4;
  String? brand; // Changed from cardBrand to match API
  List<Post> my_posts;
  List<Post> winner_posts;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    required this.city,
    required this.gender,
    required this.role,
    this.createdDate,
    this.updatedDate,
    this.lastLogin,
    this.rating = 0,
    this.status = '',
    this.paymentToken,
    this.lahzaCustomerId,
    this.last4 = 0,
    this.brand,
    this.my_posts = const [],
    this.winner_posts = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      phone: json['phone'] ?? '', // Updated from phoneNumber to phone
      city: json['city'] ?? '',
      gender: json['gender'] ?? '',
      role: json['role'] ?? '',
      createdDate: json['createdDate'] != null ? DateTime.parse(json['createdDate']) : null,
      updatedDate: json['updatedDate'] != null ? DateTime.parse(json['updatedDate']) : null,
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      rating: (json['rating'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      paymentToken: json['paymentToken'],
      lahzaCustomerId: json['lahzaCustomerId'],
      last4: json['last4'] ?? 0,
      brand: json['brand'], // Updated from cardBrand to brand
      my_posts: (json['my_posts'] as List<dynamic>?)
          ?.map((item) => Post.fromJson(item))
          .toList() ??
          [],
      winner_posts: (json['winner_posts'] as List<dynamic>?)
          ?.map((item) => Post.fromJson(item))
          .toList() ??
          [],
    );
  }
}
