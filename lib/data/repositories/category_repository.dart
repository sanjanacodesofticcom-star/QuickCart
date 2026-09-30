import '../../core/models/category_model.dart';
import '../../core/services/json_data_service.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<Category?> getCategoryById(String id);
  Future<void> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
}

class JsonCategoryRepository implements CategoryRepository {
  final JsonDataService _jsonDataService;
  List<Category> _categoriesCache = [];
  bool _isInitialized = false;

  JsonCategoryRepository({JsonDataService? jsonDataService})
      : _jsonDataService = jsonDataService ?? JsonDataService();

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      _categoriesCache = await _jsonDataService.loadCategories();
      _isInitialized = true;
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    await _ensureInitialized();
    return List<Category>.unmodifiable(_categoriesCache);
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    await _ensureInitialized();
    try {
      return _categoriesCache.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addCategory(Category category) async {
    await _ensureInitialized();
    _categoriesCache.add(category);
  }

  @override
  Future<void> updateCategory(Category category) async {
    await _ensureInitialized();
    final index = _categoriesCache.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categoriesCache[index] = category;
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _ensureInitialized();
    _categoriesCache.removeWhere((c) => c.id == id);
  }
}
