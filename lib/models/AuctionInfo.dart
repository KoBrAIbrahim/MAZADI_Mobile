import 'dart:convert';
import 'dart:io';
import 'package:application/models/post_2.dart';

// New model for auction category-status response
class AuctionInfo {
  final int id;
  final String category;
  final String status;
  final int postCount;
  final String createdDate;

  AuctionInfo({
    required this.id,
    required this.category,
    required this.status,
    required this.postCount,
    required this.createdDate,
  });

  factory AuctionInfo.fromJson(Map<String, dynamic> json) {
    return AuctionInfo(
      id: json['id'],
      category: json['category'],
      status: json['status'],
      postCount: json['postCount'],
      createdDate: json['createdDate'],
    );
  }
}

// Updated pagination model
class PaginationResponse<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
  final int numberOfElements;

  PaginationResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
    required this.numberOfElements,
  });

  factory PaginationResponse.fromJson(
      Map<String, dynamic> json,
      T Function(Map<String, dynamic>) fromJsonT,
      ) {
    return PaginationResponse<T>(
      content: (json['content'] as List<dynamic>)
          .map((item) => fromJsonT(item))
          .toList(),
      totalElements: json['totalElements'],
      totalPages: json['totalPages'],
      size: json['size'],
      number: json['number'],
      numberOfElements: json['numberOfElements'],
    );
  }
}