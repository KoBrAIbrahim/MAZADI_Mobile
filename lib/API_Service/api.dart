import 'dart:convert';
import 'dart:io';
import 'package:application/models/action.dart';
import 'package:application/models/bid.dart';
import 'package:application/models/post_2.dart';
import 'package:application/models/user.dart';
import 'package:hive/hive.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

import '../models/AuctionInfo.dart';
import 'AppConfig.dart';

class ApiService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Android emulator
      return "http://192.168.1.20:8080";
    } else if (Platform.isIOS) {
      // iOS simulator can use localhost, but physical device needs IP
      return "http://localhost:8080";
      // For physical iOS device, use: "http://192.168.1.XXX:8080"
    } else {
      // Web or other platforms
      return "http://localhost:8080";
    }
  }

  String? accessToken;
  String? refreshToken;

  Future<Map<String, dynamic>?> registerUser(
    Map<String, dynamic> userData,
  ) async {
    final url = Uri.parse('$baseUrl/whitelist/Register');
    final headers = {
      'Content-Type': 'application/json',
      'accept': 'application/json',
    };

    try {
      print('Attempting to connect to: $url'); // Debug log
      print('Request body: ${jsonEncode(userData)}'); // Debug log

      final response = await http
          .post(url, headers: headers, body: jsonEncode(userData))
          .timeout(Duration(seconds: 10)); // Add timeout

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        accessToken = data['access_token'];
        refreshToken = data['refresh_token'];
        print(data['message']);
        return data;
      } else {
        print('Registration failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during registration: $e');
      return null;
    }
  }

  Map<String, String> getAuthHeaders() {
    if (accessToken == null) {
      throw Exception(
        'Access token is not available. Please register or login first.',
      );
    }
    return {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    };
  }

  Future<bool> sendVerificationCode(String email) async {
    final url = Uri.parse('$baseUrl/auth/send-verification-code?email=$email');

    try {
      final response = await http.post(url, headers: {'accept': '*/*'});

      print('Response code: ${response.statusCode}');
      print('Response body: ${response.body}');

      return response.statusCode == 200 &&
          response.body.toLowerCase().contains('verification code sent');
    } catch (e) {
      print('Error sending verification code: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final headers = {'accept': '*/*', 'Content-Type': 'application/json'};
    final body = jsonEncode({'email': email, 'password': password});

    try {
      final response = await http.post(url, headers: headers, body: body);

      print('Response: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final accessToken = data['access_token'];
        final refreshToken = data['refresh_token'];

        // Save tokens to Hive
        final box = Hive.box('authBox');
        await box.put('access_token', accessToken);
        await box.put('refresh_token', refreshToken);

        print('Tokens saved to Hive');
        return true;
      } else {
        print('Login failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  Future<void> uploadPostWithImages({
    required Map<String, dynamic> postJson,
    required List<File> imageFiles,
  }) async {
    final url = Uri.parse('$baseUrl/posts/'); // تأكد من المسار الصحيح
    final request = http.MultipartRequest('POST', url);

    // ✅ التوكن
    final authBox = await Hive.openBox('authBox');
    final token = authBox.get('access_token');
    if (token == null) {
      print('❌ Access token not found!');
      return;
    }

    request.headers.addAll({'Authorization': 'Bearer $token', 'Accept': '*/*'});

    // ✅ إرسال post.json
    final postString = jsonEncode(postJson);
    request.files.add(
      http.MultipartFile.fromString(
        'post',
        postString,
        filename: 'post.json',
        contentType: MediaType('application', 'json'),
      ),
    );

    // ✅ إرسال الصور
    for (var imageFile in imageFiles) {
      final fileName = basename(imageFile.path);
      final mimeType = _getMimeType(imageFile.path);

      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          imageFile.path,
          filename: fileName,
          contentType: mimeType,
        ),
      );
    }

    // ✅ الإرسال
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Uploaded successfully!');
      print(responseBody);
    } else {
      print('❌ Failed: ${response.statusCode}');
      print('Error: $responseBody');
    }
  }

  MediaType _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  Future<Map<String, dynamic>?> getAuctionByCategoryAndStatus({
    required String category,
    required String status,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/auction/category-status?category=$category&status=$status',
    );

    final authBox = await Hive.openBox('authBox');
    final token = authBox.get('access_token');

    if (token == null) {
      print('❌ Access token not found');
      return null;
    }

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ Auction data: $data');
      return data;
    } else {
      print('❌ Error ${response.statusCode}: ${response.body}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final authBox = await Hive.openBox('authBox');
    String? token = authBox.get('access_token');

    if (token == null) {
      print('❌ Access token not found');
      return null;
    }

    final uri = Uri.parse('$baseUrl/auth/getUser');

    http.Response response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
    );

    // ✅ تحقق من انتهاء صلاحية التوكن
    if (response.statusCode == 401 && response.body.contains('expired')) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        // أعد المحاولة بعد تحديث التوكن
        token = authBox.get('access_token');
        response = await http.get(
          uri,
          headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
        );
      } else {
        return null;
      }
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ User data: $data');
      return data;
    } else {
      print('❌ Failed to fetch user: ${response.statusCode}');
      print('Response: ${response.body}');
      return null;
    }
  }

  Future<List<Post>> getAllPosts({
    int page = 1,
    int size = 10,
    String? searchQuery,
    String? category,
    String? sortKey,
  }) async {
    try {
      final authBox = await Hive.openBox('authBox');
      String? token = authBox.get('access_token');

      final Map<String, String> queryParams = {
        'page': page.toString(),
        'size': size.toString(),
      };

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      if (category != null &&
          category.isNotEmpty &&
          category.toUpperCase() != 'ALL') {
        queryParams['category'] = category.toUpperCase();
      }

      // Convert sortKey to API fields
      switch (sortKey) {
        case 'sort_date':
          queryParams['sortByDate'] = 'true';
          break;
        case 'sort_price':
          queryParams['sortByPrice'] = 'true';
          break;
        case 'sort_rating':
          queryParams['sortByRating'] = 'true';
          break;
      }

      final uri = Uri.parse('$baseUrl/whitelist/posts')
          .replace(queryParameters: queryParams);

      http.Response response = await http.get(
        uri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      // Handle 401 (Unauthorized) error - token might be expired
      if (response.statusCode == 401) {
        final refreshed = await refreshAccessToken();
        if (refreshed) {
          // Get the new token and retry the request
          token = authBox.get('access_token');
          response = await http.get(
            uri,
            headers: {'Authorization': 'Bearer $token', 'Accept': '*/*'},
          );
        } else {
          throw Exception('Failed to refresh token');
        }
      }

      // Process the response (either the initial one or after token refresh)
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> content = jsonData['content'];
        return content.map((e) => Post.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  Future<bool> markPostAsInterested({
    required int userId,
    required int postId,
    required String token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/interested/$userId/$postId');

      final response = await http.post(
        uri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        print('Request failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error marking post as interested: $e');
      return false;
    }
  }

  Future<bool> unmarkPostAsInterested({
    required int userId,
    required int postId,
    required String token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/interested/$userId/$postId');

      final response = await http.delete(
        uri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        print('Interest removed successfully');
        return true;
      } else {
        print('Failed to remove interest: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error removing interest: $e');
      return false;
    }
  }

  Future<List<Post>> getInterestedPosts({
    required int userId,
    required String token,
    int page = 1,
    int size = 10,
    String? category, // ✅ أضفنا category
  }) async {
    try {
      // ✅ جهز الكويري باراميترز
      final queryParams = {'page': page.toString(), 'size': size.toString()};

      if (category != null && category.isNotEmpty && category != 'ALL') {
        queryParams['category'] = category.toUpperCase(); // حسب الـ API
      }

      final uri = Uri.parse(
        '$baseUrl/interested/$userId',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> content = jsonData['content'];
        return content.map((e) => Post.fromJson(e)).toList();
      } else {
        throw Exception(
          'فشل في تحميل المنشورات المهتم بها: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }

  Future<bool> refreshAccessToken() async {
    final box = await Hive.openBox('authBox');
    final refreshToken = box.get('refresh_token');

    if (refreshToken == null) {
      print('❌ No refresh token found');
      return false;
    }

    final url = Uri.parse('$baseUrl/auth/refresh-token');
    final headers = {'accept': '*/*', 'Authorization': 'Bearer $refreshToken'};

    try {
      final response = await http.post(url, headers: headers);

      print('🔄 Refresh token response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];

        await box.put('access_token', newAccessToken);
        await box.put('refresh_token', newRefreshToken);

        print('✅ Tokens refreshed successfully');
        return true;
      } else {
        print('❌ Failed to refresh token: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Exception in refreshAccessToken: $e');
      return false;
    }
  }

  Future<void> logoutUser() async {
    final authBox = await Hive.openBox('authBox');
    final token = authBox.get('access_token');

    if (token == null) {
      print('❌ No token found');
      return;
    }

    final uri = Uri.parse('$baseUrl/auth/logout');

    try {
      final response = await http.post(
        uri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Logout successful');

        // احذف بيانات المستخدم
        await authBox.delete('access_token');
        await authBox.delete('refresh_token');
      } else {
        print('❌ Logout failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }

  Future<List<Post>> getUserPosts({
    required int userId,
    int page = 1,
    int size = 10,
    String? category, // ✅ الفلتر الإضافي
  }) async {
    try {
      final authBox = await Hive.openBox('authBox');
      final token = authBox.get('access_token');

      if (token == null) {
        throw Exception('❌ Access token غير موجود');
      }

      // إعداد الكويري باراميترز
      final queryParams = {'page': page.toString(), 'size': size.toString()};

      if (category != null &&
          category.trim().isNotEmpty &&
          category.trim().toUpperCase() != 'ALL') {
        queryParams['category'] = category.trim().toUpperCase();
      }

      final uri = Uri.parse(
        '$baseUrl/posts/user/$userId',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> content = jsonData['content'];
        return content.map((e) => Post.fromJson(e)).toList();
      } else {
        throw Exception(
          'فشل في تحميل منشورات المستخدم: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error in getUserPosts: $e');
      rethrow;
    }
  }

  Future<List<Post>> getUserWonPosts({
    required int userId,
    required String token,
    int page = 1,
    int size = 10,
    String? category,
  }) async {
    try {
      final queryParams = {'page': page.toString(), 'size': size.toString()};

      if (category != null &&
          category.isNotEmpty &&
          category.toUpperCase() != 'ALL') {
        queryParams['category'] = category.toUpperCase();
      }

      final uri = Uri.parse(
        '$baseUrl/posts/userWon/$userId',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> content = jsonData['content'];
        return content.map((e) => Post.fromJson(e)).toList();
      } else {
        throw Exception(
          'فشل في تحميل البوستات الفائزة: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('API Error in getUserWonPosts: $e');
      rethrow;
    }
  }

  Future<Post?> getPostById(int postId) async {
    try {
      final authBox = await Hive.openBox('authBox');
      final token = authBox.get('access_token');

      if (token == null) {
        print('❌ No access token found');
        return null;
      }

      final uri = Uri.parse('$baseUrl/whitelist/$postId');

      final response = await http.get(
        uri,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Post.fromJson(data); // تأكد من وجود Post.fromJson()
      } else {
        print('❌ Failed to fetch post: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching post by ID: $e');
      return null;
    }
  }

  Future<List<Post>> getSimilarPosts(String category) async {
    final authBox = await Hive.openBox('authBox');
    final token = authBox.get('access_token');

    final uri = Uri.parse('$baseUrl/whitelist/posts').replace(
      queryParameters: {
        'page': '1',
        'size': '10',
        'category': category.toUpperCase(),
      },
    );

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> content = data['content'];
      return content.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception("فشل في تحميل البوستات المتشابهة");
    }
  }

  //-----------------------------------------------------------------------------------------------------------------------------

  Future<List<Auction>?> getAllAuctions() async {
    try {
      final url = Uri.parse('$baseUrl/whitelist/auctions');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List content = data['content']; // لو كان الرد فيه paging
        return content.map((e) => Auction.fromJson(e)).toList();
      } else {
        print("Failed to load auctions: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error loading auctions: $e");
      return null;
    }
  }

  Future<List<Bid>?> getAllBids() async {
    try {
      final url = Uri.parse('$baseUrl/whitelist/bids');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((e) => Bid.fromJson(e)).toList();
      } else {
        print("Failed to load bids: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error loading bids: $e");
      return null;
    }
  }

  Future<List<String>> getCategories() async {
    try {
      // لاحقاً غيّر هذا المسار لو عندك endpoint خاص بالتصنيفات
      final url = Uri.parse('$baseUrl/whitelist/categories');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data);
      } else {
        print("Failed to load categories: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error loading categories: $e");
      return [];
    }
  }

  getAuctionById(String s) {}

  fetchAuctions() {}

  fetchPosts() {}

  fetchBids() {}

  fetchCategories() {}

  updatePost(Post post) {}


  // Add to api.dart
  Future<User> updateUserProfile({
    required int userId,
    required User user,
  }) async {
    try {
      final authBox = await Hive.openBox('authBox');
      final token = authBox.get('access_token');

      if (token == null) {
        throw Exception('Access token not found');
      }

      final uri = Uri.parse('$baseUrl/common/$userId');

      final body = jsonEncode({
        'firstName': user.firstName,
        'lastName': user.lastName,
        'phone': user.phone,
        'city': user.city,
        'gender': user.gender.toUpperCase(),
      });

      final response = await http.patch(
        uri,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print('✅ Profile updated successfully');
        // Parse the response and return the updated user
        final Map<String, dynamic> userData = jsonDecode(response.body);
        return User(
          id: userData['id'] ?? userId,
          firstName: userData['firstName'] ?? user.firstName,
          lastName: userData['lastName'] ?? user.lastName,
          email: userData['email'] ?? user.email,
          phone: userData['phone'] ?? user.phone,
          city: userData['city'] ?? user.city,
          gender: userData['gender'] ?? user.gender,
          password: user.password, // Keep the existing password
          role: userData['role'] ?? user.role,
        );
      } else {
        print('❌ Failed to update profile: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      throw Exception('Error updating profile: $e');
    }
  }

  // Change password API call
  Future<http.Response> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
    required String token
  }) async {
    final Uri uri = Uri.parse('$baseUrl/common/changePassword')
        .replace(queryParameters: {
      'email': email,
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });

    try {
      final response = await http.post(
        uri,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      print('Password change status code: ${response.statusCode}');
      return response;
    } catch (e) {
      print('Error changing password: $e');
      rethrow;
    }
  }
  Future<AuctionInfo?> getAuctionByCategoryAndStatusDefulat({
    required String category,
    String status = 'IN_PROGRESS',
  }) async {
    try {
      print('🔍 Getting auction for category: $category, status: $status');

      final authBox = await Hive.openBox('authBox');
      final token = authBox.get('access_token');
      if (token == null) {
        print('❌ No authentication token found');
        throw Exception('No authentication token found');
      }

      final url = Uri.parse(
        '$baseUrl/auction/category-status?category=$category&status=$status',
      );

      print('📡 Making request to: $url');

      final response = await http.get(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final auctionInfo = AuctionInfo.fromJson(jsonData);
        print('✅ Successfully got auction: $auctionInfo');
        return auctionInfo;
      } else if (response.statusCode == 404) {
        print('⚠️ No auction found for category: $category, status: $status');
        return null;
      } else {
        print('❌ Failed to load auction: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load auction: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting auction by category and status: $e');
      return null;
    }
  }

  // Get waiting/in-progress posts for auction with pagination
  Future<PaginationResponse<Post>?> getPostsForAuction({
    required int auctionId,
    int page = 1,
    int size = 10,
    String? category,
  }) async {
    try {
      print('🔍 Getting posts for auction: $auctionId, page: $page, size: $size, category: $category');

      final authBox = await Hive.openBox('authBox');
      final token = authBox.get('access_token');
      if (token == null) {
        print('❌ No authentication token found');
        throw Exception('No authentication token found');
      }

      // Build URL with query parameters
      final uri = Uri.parse('$baseUrl/posts/auction-waiting/$auctionId/').replace(
        queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
          if (category != null) 'category': category,
        },
      );

      print('📡 Making request to: $uri');

      final response = await http.get(
        uri,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('📊 Parsing pagination response...');

        final paginationResponse = PaginationResponse.fromJson(
          jsonData,
              (json) {
            print('📄 Parsing post: ${json['id']} - ${json['title']}');
            return Post.fromJson(json);
          },
        );

        print('✅ Successfully got ${paginationResponse.content.length} posts');
        print('📊 Pagination info: $paginationResponse');

        return paginationResponse;
      } else if (response.statusCode == 404) {
        print('⚠️ Auction not found: $auctionId');
        throw Exception('Auction not found');
      } else {
        print('❌ Failed to load posts: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting posts for auction: $e');
      return null;
    }
  }

  // Combined method to get auction and its posts
  Future<Map<String, dynamic>?> getAuctionWithPosts({
    required String category,
    String status = 'IN_PROGRESS',
    int page = 1,
    int size = 10,
  }) async {
    try {
      print('🔄 Getting auction with posts for category: $category');

      // First, get the auction info
      final auctionInfo = await getAuctionByCategoryAndStatusDefulat(
        category: category,
        status: status,
      );

      if (auctionInfo == null) {
        print('⚠️ No auction found for category: $category');
        return null;
      }

      // Then, get the posts for this auction
      final postsResponse = await getPostsForAuction(
        auctionId: auctionInfo.id,
        page: page,
        size: size,
        category: category,
      );

      final result = {
        'auctionInfo': auctionInfo,
        'postsResponse': postsResponse,
      };

      print('✅ Successfully combined auction and posts data');
      return result;
    } catch (e) {
      print('❌ Error getting auction with posts: $e');
      return null;
    }
  }

  // Helper method to get all posts (with pagination handling)
  Future<List<Post>> getAllPostsForAuction({
    required int auctionId,
    String? category,
    int pageSize = 20,
  }) async {
    List<Post> allPosts = [];
    int currentPage = 1;
    bool hasMorePages = true;

    print('🔄 Getting all posts for auction: $auctionId');

    while (hasMorePages) {
      final response = await getPostsForAuction(
        auctionId: auctionId,
        page: currentPage,
        size: pageSize,
        category: category,
      );

      if (response != null && response.content.isNotEmpty) {
        allPosts.addAll(response.content);
        hasMorePages = currentPage < response.totalPages;
        currentPage++;
        print('📄 Loaded page $currentPage, total posts so far: ${allPosts.length}');
      } else {
        hasMorePages = false;
      }
    }

    print('✅ Loaded all ${allPosts.length} posts for auction: $auctionId');
    return allPosts;
  }

  static Future<Map<String, dynamic>?> startAuctionTimer(int postId) async {
    try {
      final authBox = await Hive.openBox('authBox');
      final token = authBox.get('access_token');
      final response = await http.post(
        Uri.parse(AppConfig.postTimerUrl(postId)),
        headers: {
          'Content-Type': 'application/json',
           'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to start timer: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error starting timer: $e');
      return null;
    }
  }

  /// Get timer status for a post
  static Future<Map<String, dynamic>?> getTimerStatus(int postId) async {
    try {
      final authBox = await Hive.openBox('authBox');
      final token = authBox.get('access_token');
      final response = await http.get(
        Uri.parse(AppConfig.postTimerStatusUrl(postId)),
        headers: {
          'Content-Type': 'application/json',
           'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to get timer status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting timer status: $e');
      return null;
    }
  }

  /// Place bid via HTTP (fallback when WebSocket is not available)
  static Future<bool> placeBid(int postId, double amount) async {
    try {
      final authBox = await Hive.openBox('authBox');
      final token = authBox.get('access_token');
      final response = await http.put(
        Uri.parse(AppConfig.placeBidUrl(postId, amount)),
        headers: {
          'Content-Type': 'application/json',
           'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error placing bid: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getCurrentActivePost(int auctionId) async {
    try {
      print('🔍 Getting current active post for auction: $auctionId');

      // Get authentication token
      final authBox = await Hive.openBox('authBox');
      final token = authBox.get('access_token');

      final response = await http.get(
        Uri.parse(AppConfig.getCurrentActivePostUrl(auctionId)),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('📡 getCurrentActivePost response: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Successfully got current active post data');
        return data;
      } else if (response.statusCode == 401) {
        print('🔐 Authentication failed, attempting token refresh...');

        // Try to refresh token
        final apiService = ApiService();
        final refreshed = await apiService.refreshAccessToken();

        if (refreshed) {
          // Retry with new token
          final newToken = authBox.get('access_token');
          final retryResponse = await http.get(
            Uri.parse(AppConfig.getCurrentActivePostUrl(auctionId)),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $newToken',
            },
          );

          if (retryResponse.statusCode == 200) {
            return json.decode(retryResponse.body);
          }
        }

        print('❌ Authentication failed even after token refresh');
        return null;
      } else if (response.statusCode == 403) {
        print('⚠️ Access forbidden - using fallback approach');
        return null; // Let the calling code handle fallback
      } else {
        print('❌ Failed to get current active post: ${response.statusCode}');
        print('❌ Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting current active post: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> startNextPost(int auctionId) async {
    try {
      final authBox = await Hive.openBox('authBox');
      final token = authBox.get('access_token');
      final response = await http.post(
        Uri.parse(AppConfig.startNextPostUrl(auctionId)),
        headers: {
          'Content-Type': 'application/json',
           'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to start next post: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error starting next post: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getAuctionStats(int auctionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auctions/$auctionId/stats'),
        headers: {
          'Content-Type': 'application/json',
          // Add your authentication headers here
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Failed to get auction stats: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting auction stats: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> getPostsByAuctionAndStatus(int auctionId, String status) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/auction/$auctionId/status/$status'),
        headers: {
          'Content-Type': 'application/json',
          // Add your authentication headers here
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['posts'] ?? [];
      } else {
        print('Failed to get posts by status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting posts by status: $e');
      return null;
    }
  }


}
