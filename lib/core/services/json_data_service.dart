import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

class JsonDataService {
  static final JsonDataService _instance = JsonDataService._internal();
  factory JsonDataService() => _instance;
  JsonDataService._internal();

  Future<List<Product>> loadProducts() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/products.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList.map((j) => Product.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback empty list or rethrow with clear error
      return [];
    }
  }

  Future<List<Category>> loadCategories() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/categories.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList.map((j) => Category.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Order>> loadOrders() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/orders.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList.map((j) => Order.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<User>> loadUsers() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/users.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList.map((j) => User.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> loadSettings() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/settings.json');
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }
}
