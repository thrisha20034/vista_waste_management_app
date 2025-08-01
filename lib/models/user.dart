enum UserType { user, driver, admin }

class User {
  final String id;
  final String name;
  final String email;
  final UserType userType;
  final String? phoneNumber;
  final String? address;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    this.phoneNumber,
    this.address,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      userType: _parseUserType(json['userType']),
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static UserType _parseUserType(dynamic userType) {
    if (userType == null) return UserType.user;

    if (userType is String) {
      switch (userType.toLowerCase()) {
        case 'admin':
          return UserType.admin;
        case 'driver':
          return UserType.driver;
        case 'user':
        default:
          return UserType.user;
      }
    }

    if (userType is UserType) return userType;
    return UserType.user;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'userType': userType.toString().split('.').last,
      'phoneNumber': phoneNumber,
      'address': address,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserType? userType,
    String? phoneNumber,
    String? address,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}