import 'package:application/models/post.dart';

class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phoneNumber;
  final String city;
  final String gender;
  final DateTime lastLogin;
  final double rating;
  final String role;
  final String status;
  final String paymentToken;
  final String lahzaCustomerId;
  final int last4;
  final String cardBrand;
  final List<Post> my_posts;
  final List<Post> winner_posts;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.city,
    required this.gender,
    required this.lastLogin,
    required this.rating,
    required this.role,
    required this.status,
    required this.paymentToken,
    required this.lahzaCustomerId,
    required this.last4,
    required this.cardBrand,
    required this.my_posts,
    required this.winner_posts,
  });
}
