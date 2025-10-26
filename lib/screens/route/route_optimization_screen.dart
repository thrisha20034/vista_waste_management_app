import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/request_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/route_optimization_service.dart';
import '../../models/service_request.dart';
import '../../utils/colors.dart';

class RouteOptimizationScreen extends StatefulWidget {
  const RouteOptimizationScreen({super.key});

  @override
  State<RouteOptimizationScreen> createState() => _RouteOptimizationScreenState();
}

class _RouteOptimizationScreenState extends State<RouteOptimizationScreen> {
  GoogleMapController? _mapController;
  OptimizedRoute? _currentRoute;
  bool _isOptimizing = false;
  bool _isRouteActive = false;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _checkDriverAccess();
    _loadAndOptimizeRoute();
  }

  void _checkDriverAccess() {
    // Allow all authenticated users to access route optimization
    // No restrictions based on user type
  }

  Future<void> _loadAndOptimizeRoute() async {
    setState(() {
      _isOptimizing = true;
    });

    try {
      final requestProvider = Provider.of<RequestProvider>(context, listen: false);
      await requestProvider.loadRequests();

      // Get assigned requests for route optimization
      final assignedRequests = requestProvider.requests
          .where((r) => r.status == RequestStatus.assigned || r.status == RequestStatus.inProgress)
          .toList();

      if (assignedRequests.isNotEmpty) {
        final optimizedRoute = await RouteOptimizationService.optimizeRoute(assignedRequests);

        setState(() {
          _currentRoute = optimizedRoute;
          _createMarkersAndPolylines();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error optimizing route: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isOptimizing = false;
    });
  }

  void _createMarkersAndPolylines() {
    if (_currentRoute == null) return;

    final markers = <Marker>{};
    final polylineCoordinates = <LatLng>[];

    for (int i = 0; i < _currentRoute!.stops.length; i++) {
      final stop = _currentRoute!.stops[i];
      final position = LatLng(stop.latitude, stop.longitude);
      polylineCoordinates.add(position);

      BitmapDescriptor icon;
      String title;
      switch (stop.type) {
        case 'start':
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
          title = '🏢 Collection Depot';
          break;
        case 'destination':
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
          title = '🏭 Processing Center';
          break;
        default:
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
          title = '📍 Pickup $i';
      }

      markers.add(
        Marker(
          markerId: MarkerId(stop.id),
          position: position,
          icon: icon,
          infoWindow: InfoWindow(
            title: title,
            snippet: stop.address,
          ),
          onTap: () => _showStopDetails(stop),
        ),
      );
    }

    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('route'),
        points: polylineCoordinates,
        color: _isRouteActive ? const Color(0xFF00D4AA) : AppColors.primary, // Zomato-like green when active
        width: 5,
        patterns: _isRouteActive ? [] : [PatternItem.dash(15), PatternItem.gap(8)],
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };

    setState(() {
      _markers = markers;
      _polylines = polylines;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Allow all authenticated users to access route optimization

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mangalore Route Optimization'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isOptimizing ? null : _loadAndOptimizeRoute,
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showPredictiveAnalytics(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Map Section
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    if (_currentRoute != null && _currentRoute!.stops.isNotEmpty) {
                      _fitMapToRoute();
                    }
                  },
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(12.8697, 74.8420), // Mangalore Central
                    zoom: 13,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                if (_isOptimizing)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Optimizing Route...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      _isOptimizing ? 'Optimizing...' : 'Route Optimized',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Route Details Section
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[50],
              child: Column(
                children: [
                  _buildRouteHeader(),
                  Expanded(
                    child: _currentRoute == null
                        ? _buildEmptyState()
                        : _buildRouteDetails(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Route Optimization',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isRouteActive ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _isRouteActive ? 'Active' : 'Inactive',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.route_outlined,
            size: 48,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No route to optimize',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Assign requests to drivers to generate routes',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRouteStops(),
          const SizedBox(height: 24),
          _buildRouteSummary(),
          const SizedBox(height: 24),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildRouteStops() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < _currentRoute!.stops.length; i++)
          _buildStopItem(_currentRoute!.stops[i], i),
      ],
    );
  }

  Widget _buildStopItem(RouteStop stop, int index) {
    IconData icon;
    Color color;
    String title;

    switch (stop.type) {
      case 'start':
        icon = Icons.play_circle_filled;
        color = Colors.green;
        title = 'Starting Point';
        break;
      case 'destination':
        icon = Icons.flag;
        color = Colors.red;
        title = 'Final Destination';
        break;
      default:
        icon = Icons.location_on;
        color = Colors.orange;
        title = 'Delivery Stop $index';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stop.address,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.route, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Mangalore Route Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Total Distance',
                  '${_currentRoute!.totalDistance.toStringAsFixed(1)} km',
                  Icons.straighten,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Estimated Time',
                  '${(_currentRoute!.estimatedTimeMinutes / 60).toStringAsFixed(1)} hrs',
                  Icons.access_time,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Fuel Saved',
                  '${_currentRoute!.fuelSaved.toStringAsFixed(1)} L',
                  Icons.local_gas_station,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: AppColors.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _toggleRouteStatus,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isRouteActive ? Colors.red : AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _isRouteActive ? 'Stop Route' : 'Start Route',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _toggleRouteStatus() {
    setState(() {
      _isRouteActive = !_isRouteActive;
      _createMarkersAndPolylines(); // Update polyline style
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isRouteActive
              ? 'Route started! Navigation will begin shortly.'
              : 'Route stopped.',
        ),
        backgroundColor: _isRouteActive ? Colors.green : Colors.orange,
      ),
    );
  }

  void _showStopDetails(RouteStop stop) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            stop.type == 'start' ? 'Collection Depot' :
            stop.type == 'destination' ? 'Processing Center' :
            'Pickup Location',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      stop.address,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              if (stop.request != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.delete_outline, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      'Waste: ${stop.request!.wasteType}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.scale, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Weight: ${stop.request!.estimatedWeight} kg',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _fitMapToRoute() {
    if (_mapController == null || _currentRoute == null || _currentRoute!.stops.isEmpty) {
      return;
    }

    double minLat = _currentRoute!.stops.first.latitude;
    double maxLat = _currentRoute!.stops.first.latitude;
    double minLng = _currentRoute!.stops.first.longitude;
    double maxLng = _currentRoute!.stops.first.longitude;

    for (final stop in _currentRoute!.stops) {
      minLat = min(minLat, stop.latitude);
      maxLat = max(maxLat, stop.latitude);
      minLng = min(minLng, stop.longitude);
      maxLng = max(maxLng, stop.longitude);
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0, // padding
      ),
    );
  }

  void _showPredictiveAnalytics() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.analytics, color: AppColors.primary),
              SizedBox(width: 8),
              Text('AI Predictive Analytics'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mangalore Waste Management Insights:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildAnalyticsItem(
                  'Peak Collection Times',
                  '8:00 AM - 10:00 AM, 2:00 PM - 4:00 PM',
                  Icons.schedule,
                  Colors.blue,
                ),
                _buildAnalyticsItem(
                  'High-Demand Areas',
                  'Hampankatta, Forum Fiza Mall, AJ Hospital',
                  Icons.location_on,
                  Colors.orange,
                ),
                _buildAnalyticsItem(
                  'Optimal Route Efficiency',
                  '${_currentRoute != null ? (100 - (_currentRoute!.fuelSaved * 10)).toStringAsFixed(0) : "85"}% efficiency achieved',
                  Icons.trending_up,
                  Colors.green,
                ),
                _buildAnalyticsItem(
                  'Weather Impact',
                  'Monsoon season: 15% longer routes',
                  Icons.cloud,
                  Colors.grey,
                ),
                _buildAnalyticsItem(
                  'Carbon Footprint',
                  '${_currentRoute?.fuelSaved.toStringAsFixed(1) ?? "2.5"} kg CO₂ saved today',
                  Icons.eco,
                  Colors.green,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Recommendation:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Start collections from Kadri area during morning rush to avoid traffic congestion near Hampankatta.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnalyticsItem(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
