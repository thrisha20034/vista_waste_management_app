import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'current_user';

  // Mock users for demo
  static final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': '1',
      'name': 'John Doe',
      'email': 'user@vista.com',
      'password': 'password123',
      'phone': '+1234567890',
      'userType': 'UserType.user',
      'address': '123 Main St, City',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': '2',
      'name': 'Admin User',
      'email': 'admin@vista.com',
      'password': 'admin123',
      'phone': '+1234567891',
      'userType': 'UserType.admin',
      'address': '456 Admin Ave, City',
      'createdAt': DateTime.now().toIso8601String(),
    },
    {
      'id': '3',
      'name': 'Driver Smith',
      'email': 'driver@vista.com',
      'password': 'driver123',
      'phone': '+1234567892',
      'userType': 'UserType.driver',
      'address': '789 Driver Rd, City',
      'createdAt': DateTime.now().toIso8601String(),
    },
  ];

  Future<User?> login(String email, String password, UserType userType) async {
    try {
      // Find user in mock data
      final userData = _mockUsers.firstWhere(
            (user) => user['email'] == email &&
            user['password'] == password &&
            user['userType'] == userType.toString(),
        orElse: () => {},
      );

      if (userData.isEmpty) {
        throw Exception('Invalid credentials');
      }

      final user = User.fromJson(userData);
      await _saveCurrentUser(user);
      return user;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        return User.fromJson(json.decode(userJson));
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<void> _saveCurrentUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }
}