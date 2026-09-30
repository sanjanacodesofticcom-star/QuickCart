import '../../core/models/product_model.dart';
import '../../core/services/json_data_service.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts();
  Future<Product?> getProductById(String id);
  Future<List<Product>> getProductsByCategory(String categoryId);
  Future<List<Product>> searchProducts(String query);
  Future<void> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> updateStock(String productId, int newStock);
  Future<void> toggleProductActive(String productId);
  Future<void> deleteProduct(String id);
}

class JsonProductRepository implements ProductRepository {
  final JsonDataService _jsonDataService;
  List<Product> _productsCache = [];
  bool _isInitialized = false;

  JsonProductRepository({JsonDataService? jsonDataService})
      : _jsonDataService = jsonDataService ?? JsonDataService();

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      _productsCache = await _jsonDataService.loadProducts();
      _isInitialized = true;
    }
  }

  @override
  Future<List<Product>> getProducts() async {
    await _ensureInitialized();
    return List<Product>.unmodifiable(_productsCache);
  }

  @override
  Future<Product?> getProductById(String id) async {
    await _ensureInitialized();
    try {
      return _productsCache.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    await _ensureInitialized();
    return _productsCache
        .where((p) => p.categoryId == categoryId && p.isActive)
        .toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    await _ensureInitialized();
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return _productsCache;

    return _productsCache.where((p) {
      final inName = p.name.toLowerCase().contains(q);
      final inSku = p.sku.toLowerCase().contains(q);
      final inCategory = p.categoryName.toLowerCase().contains(q);
      final inTags = p.tags.any((t) => t.toLowerCase().contains(q));
      final inDesc = p.shortDescription.toLowerCase().contains(q);
      return inName || inSku || inCategory || inTags || inDesc;
    }).toList();
  }

  @override
  Future<void> addProduct(Product product) async {
    await _ensureInitialized();
    _productsCache.insert(0, product);
  }

  @override
  Future<void> updateProduct(Product product) async {
    await _ensureInitialized();
    final index = _productsCache.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _productsCache[index] = product;
    }
  }

  @override
  Future<void> updateStock(String productId, int newStock) async {
    await _ensureInitialized();
    final index = _productsCache.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _productsCache[index] = _productsCache[index].copyWith(
        stock: newStock,
        updatedAt: DateTime.now().toIso8601String().split('T')[0],
      );
    }
  }

  @override
  Future<void> toggleProductActive(String productId) async {
    await _ensureInitialized();
    final index = _productsCache.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _productsCache[index] = _productsCache[index].copyWith(
        isActive: !_productsCache[index].isActive,
        updatedAt: DateTime.now().toIso8601String().split('T')[0],
      );
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _ensureInitialized();
    _productsCache.removeWhere((p) => p.id == id);
  }
}
