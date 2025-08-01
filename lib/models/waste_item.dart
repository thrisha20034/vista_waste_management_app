import 'service_request.dart';

class WasteItem {
  final String id;
  final String sellerId;
  final String title;
  final String description;
  final WasteType wasteType;
  final double weight;
  final double pricePerKg;
  final String location;
  final double latitude;
  final double longitude;
  final List<String> images;
  final bool isAvailable;
  final DateTime createdAt;

  WasteItem({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.wasteType,
    required this.weight,
    required this.pricePerKg,
    required this.location,
    required this.latitude,
    required this.longitude,
    this.images = const [],
    this.isAvailable = true,
    required this.createdAt,
  });

  double get totalPrice => weight * pricePerKg;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'title': title,
      'description': description,
      'wasteType': wasteType.toString(),
      'weight': weight,
      'pricePerKg': pricePerKg,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'images': images,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WasteItem.fromJson(Map<String, dynamic> json) {
    return WasteItem(
      id: json['id'],
      sellerId: json['sellerId'],
      title: json['title'],
      description: json['description'],
      wasteType: WasteType.values.firstWhere(
            (e) => e.toString() == json['wasteType'],
      ),
      weight: json['weight'].toDouble(),
      pricePerKg: json['pricePerKg'].toDouble(),
      location: json['location'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      images: List<String>.from(json['images'] ?? []),
      isAvailable: json['isAvailable'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}