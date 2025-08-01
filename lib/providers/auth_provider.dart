import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  User? get currentUser => _user; // Add this getter for compatibility
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _user = await _authService.getCurrentUser();
    notifyListeners();
  }

  Future<bool> login(String email, String password, String userTypeString) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Convert string to UserType enum
      UserType userType;
      if (userTypeString == 'driver') {
        userType = UserType.driver;
      } else {
        userType = UserType.user;
      }

      _user = await _authService.login(email, password, userType);
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name, String userTypeString) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Convert string to UserType enum
      UserType userType;
      if (userTypeString == 'driver') {
        userType = UserType.driver;
      } else {
        userType = UserType.user;
      }

      _user = await _authService.register(email, password, name, userType);
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
}