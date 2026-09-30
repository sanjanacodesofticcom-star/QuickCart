import '../../core/models/user_model.dart';
import '../../core/services/json_data_service.dart';

abstract class UserRepository {
  Future<List<User>> getUsers();
  Future<User?> getUserById(String id);
  Future<User> getCurrentUser();
  Future<void> setCurrentUser(User user);
  Future<void> addAddress(String userId, UserAddress address);
}

class JsonUserRepository implements UserRepository {
  final JsonDataService _jsonDataService;
  List<User> _usersCache = [];
  User? _currentUser;
  bool _isInitialized = false;

  JsonUserRepository({JsonDataService? jsonDataService})
      : _jsonDataService = jsonDataService ?? JsonDataService();

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      _usersCache = await _jsonDataService.loadUsers();
      if (_usersCache.isNotEmpty) {
        _currentUser = _usersCache.first; // Default to CUS001 Rahul Sharma
      }
      _isInitialized = true;
    }
  }

  @override
  Future<List<User>> getUsers() async {
    await _ensureInitialized();
    return List<User>.unmodifiable(_usersCache);
  }

  @override
  Future<User?> getUserById(String id) async {
    await _ensureInitialized();
    try {
      return _usersCache.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<User> getCurrentUser() async {
    await _ensureInitialized();
    if (_currentUser == null && _usersCache.isNotEmpty) {
      _currentUser = _usersCache.first;
    }
    return _currentUser ??
        const User(
          id: 'CUS001',
          name: 'Demo Customer',
          email: 'customer@example.com',
          phone: '9876543210',
          avatar: '',
        );
  }

  @override
  Future<void> setCurrentUser(User user) async {
    await _ensureInitialized();
    _currentUser = user;
  }

  @override
  Future<void> addAddress(String userId, UserAddress address) async {
    await _ensureInitialized();
    final index = _usersCache.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final updatedAddresses = List<UserAddress>.from(_usersCache[index].addresses)..add(address);
      _usersCache[index] = User(
        id: _usersCache[index].id,
        name: _usersCache[index].name,
        email: _usersCache[index].email,
        phone: _usersCache[index].phone,
        avatar: _usersCache[index].avatar,
        addresses: updatedAddresses,
      );
      if (_currentUser?.id == userId) {
        _currentUser = _usersCache[index];
      }
    }
  }
}
