import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/address.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';
import '../models/order_summary.dart';
import '../models/promo.dart';
import '../models/restaurant.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  AppState({ApiService? apiService}) : _apiService = apiService ?? ApiService() {
    _init();
  }

  final ApiService _apiService;

  List<Restaurant> restaurants = [];
  List<String> categories = [];
  List<Promo> promos = [];
  List<MenuItem> menuItems = [];
  List<OrderSummary> orders = [];
  Restaurant? selectedRestaurant;
  UserProfile? currentUser;
  String? errorMessage;
  List<String> validationErrors = [];
  bool isLoading = false;
  bool isMenuLoading = false;
  bool isProfileLoading = false;
  String? _token;

  final Map<String, CartItem> _cart = {};

  List<CartItem> get cartItems => _cart.values.toList();

  int get subtotal => _cart.values.fold(0, (sum, item) => sum + item.total);

  int get total => subtotal + (selectedRestaurant?.deliveryFee ?? 0);

  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Address? get defaultAddress {
    final addresses = currentUser?.addresses ?? [];
    if (addresses.isEmpty) return null;
    return addresses.firstWhere((item) => item.isDefault, orElse: () => addresses.first);
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      _apiService.setToken(_token);
      final name = prefs.getString('user_name');
      final phone = prefs.getString('user_phone');
      final id = prefs.getString('user_id');
      final email = prefs.getString('user_email');
      if (name != null && phone != null && id != null) {
        currentUser = UserProfile(id: id, name: name, phone: phone, email: email ?? '', addresses: []);
      }
      await loadProfile();
    }
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String phone,
    required String password,
    String? email,
  }) async {
    isLoading = true;
    errorMessage = null;
    validationErrors = [];
    notifyListeners();

    try {
      final response = await _apiService.register(
        name: name,
        phone: phone,
        password: password,
        email: email,
      );
      await _saveAuth(response);
      await loadProfile();
    } catch (e) {
      if (e is ApiException) {
        errorMessage = e.message;
        validationErrors = e.errors;
      } else {
        errorMessage = e.toString();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({
    required String phone,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    validationErrors = [];
    notifyListeners();

    try {
      final response = await _apiService.login(phone: phone, password: password);
      await _saveAuth(response);
      await loadProfile();
    } catch (e) {
      if (e is ApiException) {
        errorMessage = e.message;
        validationErrors = e.errors;
      } else {
        errorMessage = e.toString();
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveAuth(Map<String, dynamic> response) async {
    _token = response['token'] as String;
    _apiService.setToken(_token);
    final user = _apiService.parseUser(response['user'] as Map<String, dynamic>);

    await _cacheUser(user);
  }

  Future<void> _cacheUser(UserProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', _token ?? '');
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_phone', user.phone);
    await prefs.setString('user_email', user.email);
  }

  Future<void> logout() async {
    _token = null;
    currentUser = null;
    _apiService.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_phone');
    await prefs.remove('user_email');
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    validationErrors = [];
    notifyListeners();
  }

  Future<void> loadProfile() async {
    if (!isAuthenticated) return;
    isProfileLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await _apiService.fetchProfile();
      if (currentUser != null) {
        await _cacheUser(currentUser!);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isProfileLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    if (!isAuthenticated) return;
    isProfileLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      currentUser = await _apiService.updateProfile(name: name, email: email);
      if (currentUser != null) {
        await _cacheUser(currentUser!);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isProfileLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAddress(AddressPayload payload) async {
    if (!isAuthenticated) return;
    isProfileLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final addresses = await _apiService.addAddress(payload.toJson());
      final updated = addresses.map((item) => Address.fromJson(item as Map<String, dynamic>)).toList();
      if (currentUser != null) {
        currentUser = UserProfile(
          id: currentUser!.id,
          name: currentUser!.name,
          phone: currentUser!.phone,
          email: currentUser!.email,
          addresses: updated,
        );
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isProfileLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAddress(String id, AddressPayload payload) async {
    if (!isAuthenticated) return;
    isProfileLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final addresses = await _apiService.updateAddress(id, payload.toJson());
      final updated = addresses.map((item) => Address.fromJson(item as Map<String, dynamic>)).toList();
      if (currentUser != null) {
        currentUser = UserProfile(
          id: currentUser!.id,
          name: currentUser!.name,
          phone: currentUser!.phone,
          email: currentUser!.email,
          addresses: updated,
        );
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isProfileLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAddress(String id) async {
    if (!isAuthenticated) return;
    isProfileLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final addresses = await _apiService.deleteAddress(id);
      final updated = addresses.map((item) => Address.fromJson(item as Map<String, dynamic>)).toList();
      if (currentUser != null) {
        currentUser = UserProfile(
          id: currentUser!.id,
          name: currentUser!.name,
          phone: currentUser!.phone,
          email: currentUser!.email,
          addresses: updated,
        );
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isProfileLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHome({String? query}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.fetchRestaurants(query: query),
        _apiService.fetchCategories(),
        _apiService.fetchPromos(),
      ]);
      restaurants = results[0] as List<Restaurant>;
      categories = results[1] as List<String>;
      promos = results[2] as List<Promo>;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMenu(Restaurant restaurant) async {
    if (selectedRestaurant?.id != restaurant.id) {
      _cart.clear();
    }
    selectedRestaurant = restaurant;
    isMenuLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      menuItems = await _apiService.fetchMenu(restaurant.id);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isMenuLoading = false;
      notifyListeners();
    }
  }

  void addToCart(MenuItem item) {
    if (_cart.containsKey(item.id)) {
      _cart[item.id]!.quantity += 1;
    } else {
      _cart[item.id] = CartItem(item: item, quantity: 1);
    }
    notifyListeners();
  }

  void removeFromCart(MenuItem item) {
    if (!_cart.containsKey(item.id)) return;

    final cartItem = _cart[item.id]!;
    cartItem.quantity -= 1;
    if (cartItem.quantity <= 0) {
      _cart.remove(item.id);
    }
    notifyListeners();
  }

  void updateQuantity(MenuItem item, int quantity) {
    if (quantity <= 0) {
      _cart.remove(item.id);
    } else {
      _cart[item.id] = CartItem(item: item, quantity: quantity);
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Future<void> loadOrders() async {
    if (!isAuthenticated) return;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      orders = await _apiService.fetchOrders();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> placeOrder({
    required String paymentMethod,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    String? couponCode,
  }) async {
    if (selectedRestaurant == null) return null;
    if (!isAuthenticated) {
      errorMessage = 'Тапсырыс үшін авторизация қажет';
      notifyListeners();
      return null;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final order = await _apiService.createOrder(
        restaurantId: selectedRestaurant!.id,
        items: _cart.values
            .map((item) => {
                  'menuItemId': item.item.id,
                  'quantity': item.quantity,
                })
            .toList(),
        paymentMethod: paymentMethod,
        customer: {
          'name': customerName,
          'phone': customerPhone,
          'address': customerAddress,
        },
        couponCode: couponCode,
      );

      clearCart();
      return order;
    } catch (e) {
      errorMessage = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class AddressPayload {
  AddressPayload({
    required this.label,
    required this.city,
    required this.street,
    required this.building,
    required this.apartment,
    required this.comment,
    required this.isDefault,
  });

  final String label;
  final String city;
  final String street;
  final String building;
  final String apartment;
  final String comment;
  final bool isDefault;

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'city': city,
      'street': street,
      'building': building,
      'apartment': apartment,
      'comment': comment,
      'isDefault': isDefault,
    };
  }
}
