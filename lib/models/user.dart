import 'package:application/models/post_2.dart';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phoneNumber;
  final String city;
  final String gender;
  final String role;
  late DateTime lastLogin;
  late double rating;
  late String status;
  late String paymentToken;
  late String lahzaCustomerId;
  late int last4;
  late String cardBrand;
  late List<Post> my_posts;
  late List<Post> winner_posts;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.city,
    required this.gender,
    required this.role,
  });
  factory User.fromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'],
    firstName: json['firstName'],
    lastName: json['lastName'],
    email: json['email'],
    password: json['password'],
    phoneNumber: json['phoneNumber'],
    city: json['city'],
    gender: json['gender'],
    role: json['role'],
  )
    ..lastLogin = DateTime.parse(json['lastLogin'])
    ..rating = (json['rating'] ?? 0).toDouble()
    ..status = json['status'] ?? ''
    ..paymentToken = json['paymentToken'] ?? ''
    ..lahzaCustomerId = json['lahzaCustomerId'] ?? ''
    ..last4 = json['last4'] ?? 0
    ..cardBrand = json['cardBrand'] ?? ''
    ..my_posts = (json['my_posts'] as List<dynamic>?)
            ?.map((item) => Post.fromJson(item))
            .toList() ??
        []
    ..winner_posts = (json['winner_posts'] as List<dynamic>?)
            ?.map((item) => Post.fromJson(item))
            .toList() ??
        [];
}

}
