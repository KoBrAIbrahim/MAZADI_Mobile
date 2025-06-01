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

class ApiService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      // Android emulator
      return "http://192.168.1.4:8080";
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
      final token = authBox.get('access_token');
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'size': size.toString(),
      };
      print("aaaaa   ${searchQuery}");
      if (searchQuery != null && searchQuery.isNotEmpty) {
        print("asdasdasd");
        queryParams['search'] = searchQuery;
      }
      print("sssss   ${category}");

      if (category != null &&
          category.isNotEmpty &&
          category.toUpperCase() != 'ALL') {
        print("hihihi");
        queryParams['category'] = category.toUpperCase();
      }

      print("rrrrr   ${sortKey}");
      // تحويل sortKey لحقول API المعروفة
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

      final uri = Uri.parse(
        '$baseUrl/whitelist/posts',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> content = jsonData['content'];
        print("${jsonData}   ----- ${response}");
        return content.map((e) => Post.fromJson(e)).toList();
      } else {
        throw Exception('فشل في تحميل البيانات: ${response.statusCode}');
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

  placeBid(int id, double bidAmount) {}

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

}
