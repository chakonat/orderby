import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/menu_item.dart';
import '../models/order_summary.dart';
import '../models/promo.dart';
import '../models/restaurant.dart';
import '../models/user_profile.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> _headers() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<List<Restaurant>> fetchRestaurants({String? query}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/restaurants').replace(
      queryParameters: query != null && query.isNotEmpty ? {'q': query} : null,
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw ApiException('Failed to load restaurants', []);
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((json) => Restaurant.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<String>> fetchCategories() async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/categories');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw ApiException('Failed to load categories', []);
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) => item['name']?.toString() ?? item.toString()).toList();
  }

  Future<List<Promo>> fetchPromos() async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/promos');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw ApiException('Failed to load promos', []);
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((json) => Promo.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<MenuItem>> fetchMenu(String restaurantId) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/restaurants/$restaurantId/menu');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw ApiException('Failed to load menu', []);
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((json) => MenuItem.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> createOrder({
    required String restaurantId,
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    required Map<String, dynamic> customer,
    String? couponCode,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/orders');
    final response = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode({
        'restaurantId': restaurantId,
        'items': items,
        'paymentMethod': paymentMethod,
        'customer': customer,
        'couponCode': couponCode,
      }),
    );

    if (response.statusCode != 201) {
      _throwApiError(response, fallback: 'Failed to create order');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<OrderSummary>> fetchOrders() async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/orders');
    final response = await _client.get(uri, headers: _headers());
    if (response.statusCode != 200) {
      throw ApiException('Failed to load orders', []);
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((json) => OrderSummary.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String password,
    String? email,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/auth/register');
    final payload = <String, dynamic>{
      'name': name,
      'phone': phone,
      'password': password,
    };
    if (email != null && email.trim().isNotEmpty) {
      payload['email'] = email.trim();
    }
    final response = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode(payload),
    );

    if (response.statusCode != 201) {
      _throwApiError(response, fallback: 'Failed to register');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/auth/login');
    final response = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode({
        'phone': phone,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      _throwApiError(response, fallback: 'Failed to login');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  UserProfile parseUser(Map<String, dynamic> json) {
    return UserProfile.fromJson(json);
  }

  Future<UserProfile> fetchProfile() async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/users/me');
    final response = await _client.get(uri, headers: _headers());
    if (response.statusCode != 200) {
      _throwApiError(response, fallback: 'Failed to load profile');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> updateProfile({
    required String name,
    required String email,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/users/me');
    final response = await _client.put(
      uri,
      headers: _headers(),
      body: jsonEncode({
        'name': name,
        'email': email,
      }),
    );

    if (response.statusCode != 200) {
      _throwApiError(response, fallback: 'Failed to update profile');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  Future<List<dynamic>> addAddress(Map<String, dynamic> payload) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/users/me/addresses');
    final response = await _client.post(
      uri,
      headers: _headers(),
      body: jsonEncode(payload),
    );
    if (response.statusCode != 201) {
      _throwApiError(response, fallback: 'Failed to add address');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['addresses'] as List<dynamic>;
  }

  Future<List<dynamic>> updateAddress(String id, Map<String, dynamic> payload) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/users/me/addresses/$id');
    final response = await _client.put(
      uri,
      headers: _headers(),
      body: jsonEncode(payload),
    );
    if (response.statusCode != 200) {
      _throwApiError(response, fallback: 'Failed to update address');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['addresses'] as List<dynamic>;
  }

  Future<List<dynamic>> deleteAddress(String id) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/users/me/addresses/$id');
    final response = await _client.delete(uri, headers: _headers());
    if (response.statusCode != 200) {
      _throwApiError(response, fallback: 'Failed to delete address');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['addresses'] as List<dynamic>;
  }

  Never _throwApiError(http.Response response, {required String fallback}) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final message = data['message']?.toString() ?? fallback;
      final errors = (data['errors'] as List?)
              ?.map((e) => (e as Map<String, dynamic>)['msg']?.toString() ?? '')
              .where((e) => e.isNotEmpty)
              .toList() ??
          [];
      throw ApiException(message, errors);
    } catch (_) {
      throw ApiException(fallback, []);
    }
  }
}

class ApiException implements Exception {
  ApiException(this.message, this.errors);

  final String message;
  final List<String> errors;

  @override
  String toString() => message;
}
