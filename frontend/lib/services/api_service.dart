import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000";

    static Future<Map<String, String>> getHeaders() async {

      final prefs =
          await SharedPreferences.getInstance();

      final token =
          prefs.getString("token");

      print("TOKEN = $token");

      return {
        "Content-Type": "application/json",
        if (token != null)
          "Authorization": "Bearer $token",
      };
    }


  static Future<List<dynamic>> getRestaurants({
    String? keyword,
    int? categoryId,
    int? areaId,
  }) async {

    Map<String, String> params = {};

    if (keyword != null && keyword.isNotEmpty) {
      params["keyword"] = keyword;
    }

    if (categoryId != null) {
      params["category_id"] = categoryId.toString();
    }

    if (areaId != null) {
      params["area_id"] = areaId.toString();
    }

    final uri = Uri.parse(
      "$baseUrl/restaurants",
    ).replace(
      queryParameters: params,
    );
      
    final response = await http.get(uri);

    final result = jsonDecode(response.body);

    return result["data"];
  }

  static Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse("$baseUrl/categories"),
    );

    final result = jsonDecode(response.body);

    return result["data"];
  }

  static Future<List<dynamic>> getAreas() async {
    final response = await http.get(
      Uri.parse("$baseUrl/areas"),
    );

    final result = jsonDecode(response.body);

    return result["data"];
  }

  static Future<List<dynamic>> getReviews(
    String restaurantId,
  ) async {
    final response = await http.get(
      Uri.parse(
        "$baseUrl/reviews/restaurants/$restaurantId",
      ),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(
      "Không tải được đánh giá",
    );
  }

  static Future<void> createReview(
    String restaurantId,
    int rating,
    String comment,
  ) async {

    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getString("user_id");
    final body = {
      "user_id": userId,
      "restaurant_id": restaurantId,
      "rating": rating,
      "comment": comment,
    };

    final requestHeaders = await getHeaders();
    print("HEADERS = $requestHeaders");
    print("BODY = $body");

    final response = await http.post(
      Uri.parse("$baseUrl/reviews/$restaurantId"),

      headers: requestHeaders,

      body: jsonEncode(body),
    );

    print("REVIEW STATUS = ${response.statusCode}");
    print("REVIEW BODY = ${response.body}");

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception("Không thể gửi đánh giá");
    }
  }

  static Future<Map<String, dynamic>> getRestaurant(String id) async {
    final response = await http.get(
      Uri.parse("$baseUrl/restaurants/$id"),
    );

    if (response.statusCode != 200) {
      throw Exception("Không tải được nhà hàng");
    }

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        "username": email,
        "password": password,
      },
    );

    print("STATUS = ${response.statusCode}");
    print("BODY = ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        "token",
        data["access_token"],
      );
      
      return data;
    } else {
      throw Exception("Sai tài khoản hoặc mật khẩu");
    }
  }

  static Future<Map<String, dynamic>> getMe() async {

    final headers = await getHeaders();

    print("HEADERS = $headers");

    final response = await http.get(
      Uri.parse("$baseUrl/auth/me"),
      headers: headers,
    );

    print("ME STATUS = ${response.statusCode}");
    print("ME BODY = ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Không lấy được thông tin user");
    }

    return jsonDecode(response.body);
  }
}