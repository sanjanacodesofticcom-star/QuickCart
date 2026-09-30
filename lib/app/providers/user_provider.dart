import 'package:flutter/foundation.dart';
import '../../core/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository;
  List<User> _users = [];
  User? _currentUser;
  bool _isAdminLoggedIn = false;
  bool _isLoading = true;

  UserProvider({UserRepository? userRepository})
      : _userRepository = userRepository ?? JsonUserRepository() {
    loadUsers();
  }

  List<User> get users => _users;
  User? get currentUser => _currentUser;
  bool get isAdminLoggedIn => _isAdminLoggedIn;
  bool get isLoading => _isLoading;

  Future<void> loadUsers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _users = await _userRepository.getUsers();
      _currentUser = await _userRepository.getCurrentUser();
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  void switchCustomer(User user) {
    _currentUser = user;
    _userRepository.setCurrentUser(user);
    notifyListeners();
  }

  Future<void> addAddress(UserAddress address) async {
    if (_currentUser != null) {
      await _userRepository.addAddress(_currentUser!.id, address);
      _currentUser = await _userRepository.getUserById(_currentUser!.id);
      _users = await _userRepository.getUsers();
      notifyListeners();
    }
  }

  bool loginAdmin(String email, String password) {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();

    if ((cleanEmail == 'admin@quickcart.app' || cleanEmail == 'admin') && cleanPass == 'admin') {
      _isAdminLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logoutAdmin() {
    _isAdminLoggedIn = false;
    notifyListeners();
  }
}
