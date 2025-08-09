enum RequestStatus {
  pending,
  assigned,
  inProgress,
  completed,
  cancelled,
}

enum WasteType {
  organic,
  plastic,
  paper,
  electronic,
  hazardous,
  mixed,
}

class ServiceRequest {
  final String id;
  final String userId;
  final String title;
  final String description;
  final WasteType wasteType;
  final double estimatedWeight;
  final String address;
  final double latitude;
  final double longitude;
  final RequestStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt; // Add this field

  ServiceRequest({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.wasteType,
    required this.estimatedWeight,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    this.updatedAt, // Add this parameter
  });

  ServiceRequest copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    WasteType? wasteType,
    double? estimatedWeight,
    String? address,
    double? latitude,
    double? longitude,
    RequestStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      wasteType: wasteType ?? this.wasteType,
      estimatedWeight: estimatedWeight ?? this.estimatedWeight,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'wasteType': wasteType.toString(),
      'estimatedWeight': estimatedWeight,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      wasteType: WasteType.values.firstWhere(
            (e) => e.toString() == json['wasteType'],
        orElse: () => WasteType.mixed,
      ),
      estimatedWeight: json['estimatedWeight'].toDouble(),
      address: json['address'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      status: RequestStatus.values.firstWhere(
            (e) => e.toString() == json['status'],
        orElse: () => RequestStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
