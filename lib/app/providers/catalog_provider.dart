import 'package:flutter/foundation.dart' hide Category;
import '../../core/models/product_model.dart';
import '../../core/models/category_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/category_repository.dart';

class CatalogProvider extends ChangeNotifier {
  final ProductRepository _productRepository;
  final CategoryRepository _categoryRepository;

  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _error;

  CatalogProvider({
    ProductRepository? productRepository,
    CategoryRepository? categoryRepository,
  })  : _productRepository = productRepository ?? JsonProductRepository(),
        _categoryRepository = categoryRepository ?? JsonCategoryRepository() {
    loadData();
  }

  List<Product> get products => _products;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Active products for Customer App
  List<Product> get activeProducts => _products.where((p) => p.isActive).toList();
  List<Product> get popularProducts => activeProducts.where((p) => p.isFeatured || p.rating >= 4.7).toList();
  List<Product> get bestSellers => activeProducts.where((p) => p.isBestSeller).toList();

  // Admin Dashboard Calculations
  int get totalProductsCount => _products.length;
  int get activeProductsCount => _products.where((p) => p.isActive).length;
  int get inactiveProductsCount => _products.where((p) => !p.isActive).length;
  int get lowStockProductsCount => _products.where((p) => p.isLowStock).length;
  int get outOfStockProductsCount => _products.where((p) => p.isOutOfStock).length;

  List<Product> get lowStockProducts => _products.where((p) => p.isLowStock || p.isOutOfStock).toList();

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _products = await _productRepository.getProducts();
      _categories = await _categoryRepository.getCategories();
    } catch (e) {
      _error = 'Failed to load catalog: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Product> getProductsByCategory(String categoryId) {
    return activeProducts.where((p) => p.categoryId == categoryId).toList();
  }

  List<Product> searchProducts(String query, {String? categoryId}) {
    final q = query.toLowerCase().trim();
    return activeProducts.where((p) {
      final matchesCategory = categoryId == null || categoryId.isEmpty || p.categoryId == categoryId;
      if (!matchesCategory) return false;
      if (q.isEmpty) return true;

      final inName = p.name.toLowerCase().contains(q);
      final inSku = p.sku.toLowerCase().contains(q);
      final inCategory = p.categoryName.toLowerCase().contains(q);
      final inTags = p.tags.any((t) => t.toLowerCase().contains(q));
      final inDesc = p.shortDescription.toLowerCase().contains(q);
      return inName || inSku || inCategory || inTags || inDesc;
    }).toList();
  }

  // Admin Actions
  Future<void> addProduct(Product product) async {
    await _productRepository.addProduct(product);
    _products = await _productRepository.getProducts();
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    await _productRepository.updateProduct(product);
    _products = await _productRepository.getProducts();
    notifyListeners();
  }

  Future<void> updateStock(String productId, int newStock) async {
    await _productRepository.updateStock(productId, newStock);
    _products = await _productRepository.getProducts();
    notifyListeners();
  }

  Future<void> toggleProductActive(String productId) async {
    await _productRepository.toggleProductActive(productId);
    _products = await _productRepository.getProducts();
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    await _productRepository.deleteProduct(id);
    _products = await _productRepository.getProducts();
    notifyListeners();
  }
}
