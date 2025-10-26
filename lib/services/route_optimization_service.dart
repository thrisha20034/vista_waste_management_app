import 'dart:math';
import '../models/service_request.dart';

class RouteStop {
  final String id;
  final String address;
  final double latitude;
  final double longitude;
  final String type; // 'start', 'pickup', 'destination'
  final ServiceRequest? request;

  RouteStop({
    required this.id,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.request,
  });
}

class OptimizedRoute {
  final List<RouteStop> stops;
  final double totalDistance;
  final int estimatedTimeMinutes;
  final double fuelSaved;
  final String routeId;

  OptimizedRoute({
    required this.stops,
    required this.totalDistance,
    required this.estimatedTimeMinutes,
    required this.fuelSaved,
    required this.routeId,
  });
}

class RouteOptimizationService {
  static Future<OptimizedRoute> optimizeRoute(List<ServiceRequest> requests) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Create route stops from requests
    final stops = <RouteStop>[];

    // Add starting point (depot/warehouse) - Mangalore City Corporation Office
    stops.add(RouteStop(
      id: 'start',
      address: 'Mangalore City Corporation, Lalbagh Road, Mangalore',
      latitude: 12.8697,
      longitude: 74.8420,
      type: 'start',
    ));

    // Add pickup stops from actual request locations (already Mangalore locations)
    for (final request in requests) {
      stops.add(RouteStop(
        id: request.id,
        address: request.address, // Use actual request address
        latitude: request.latitude,
        longitude: request.longitude,
        type: 'pickup',
        request: request,
      ));
    }

    // Add final destination (waste processing center) - Mangalore Waste Treatment Plant
    stops.add(RouteStop(
      id: 'destination',
      address: 'Antony Waste Handling Cell, Vamanjoor Industrial Area, Mangalore',
      latitude: 12.8164,
      longitude: 74.8731,
      type: 'destination',
    ));

    // Optimize route using nearest neighbor algorithm (simplified)
    final optimizedStops = _optimizeStopOrder(stops);

    // Calculate route metrics
    final totalDistance = _calculateTotalDistance(optimizedStops);
    final estimatedTime = _calculateEstimatedTime(totalDistance, optimizedStops.length);
    final fuelSaved = _calculateFuelSavings(totalDistance);

    return OptimizedRoute(
      stops: optimizedStops,
      totalDistance: totalDistance,
      estimatedTimeMinutes: estimatedTime,
      fuelSaved: fuelSaved,
      routeId: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  static List<RouteStop> _optimizeStopOrder(List<RouteStop> stops) {
    if (stops.length <= 3) return stops; // Start, maybe one pickup, destination

    final optimized = <RouteStop>[];
    final remaining = List<RouteStop>.from(stops);

    // Always start with the starting point
    final start = remaining.firstWhere((s) => s.type == 'start');
    optimized.add(start);
    remaining.remove(start);

    // Remove destination for now
    final destination = remaining.firstWhere((s) => s.type == 'destination');
    remaining.remove(destination);

    // Use nearest neighbor for pickup stops
    RouteStop current = start;
    while (remaining.isNotEmpty) {
      RouteStop? nearest;
      double minDistance = double.infinity;

      for (final stop in remaining) {
        final distance = _calculateDistance(
          current.latitude, current.longitude,
          stop.latitude, stop.longitude,
        );
        if (distance < minDistance) {
          minDistance = distance;
          nearest = stop;
        }
      }

      if (nearest != null) {
        optimized.add(nearest);
        remaining.remove(nearest);
        current = nearest;
      }
    }

    // Add destination at the end
    optimized.add(destination);

    return optimized;
  }

  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  static double _calculateTotalDistance(List<RouteStop> stops) {
    double total = 0;
    for (int i = 0; i < stops.length - 1; i++) {
      total += _calculateDistance(
        stops[i].latitude, stops[i].longitude,
        stops[i + 1].latitude, stops[i + 1].longitude,
      );
    }
    return total;
  }

  static int _calculateEstimatedTime(double distance, int stopCount) {
    // Base time: 30 km/h average speed + 10 minutes per stop
    final drivingTime = (distance / 30) * 60; // minutes
    final stopTime = stopCount * 10; // 10 minutes per stop
    return (drivingTime + stopTime).round();
  }

  static double _calculateFuelSavings(double optimizedDistance) {
    // Assume 20% savings compared to unoptimized route
    final unoptimizedDistance = optimizedDistance * 1.25;
    const fuelConsumption = 0.08; // liters per km
    return (unoptimizedDistance - optimizedDistance) * fuelConsumption;
  }
}
