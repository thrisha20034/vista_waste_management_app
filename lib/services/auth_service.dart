import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'current_user';

  // Mock users for demonstration
  static final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': '1',
      'name': 'John Doe',
      'email': 'john@example.com',
      'password': 'password123',
      'userType': 'UserType.user',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': '2',
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'password': 'password123',
      'userType': 'UserType.user',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': '3',
      'name': 'Mike Driver',
      'email': 'driver@example.com',
      'password': 'password123',
      'userType': 'UserType.driver',
      'createdAt': DateTime.now().toIso8601String(),
    },
  ];

  Future<User?> login(String email, String password, UserType userType) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    try {
      final userData = _mockUsers.firstWhere(
            (user) => user['email'] == email &&
            user['password'] == password &&
            user['userType'] == userType.toString(),
      );

      final user = User.fromJson(userData);
      await _saveUser(user);
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<User?> register(String email, String password, String name, UserType userType) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    // Check if user already exists
    final existingUser = _mockUsers.where((user) => user['email'] == email);
    if (existingUser.isNotEmpty) {
      return null; // User already exists
    }

    // Create new user
    final newUserData = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'name': name,
      'email': email,
      'password': password,
      'userType': userType.toString(),
      'createdAt': DateTime.now().toIso8601String(),
    };

    _mockUsers.add(newUserData);
    final user = User.fromJson(newUserData);
    await _saveUser(user);
    return user;
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);

    if (userJson != null) {
      final userData = jsonDecode(userJson);
      return User.fromJson(userData);
    }

    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }
}