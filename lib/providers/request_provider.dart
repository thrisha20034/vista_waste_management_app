import 'package:flutter/foundation.dart';
import '../models/service_request.dart';

class RequestProvider with ChangeNotifier {
  List<ServiceRequest> _requests = [];
  bool _isLoading = false;

  List<ServiceRequest> get requests => _requests;
  bool get isLoading => _isLoading;

  // Mock data for demonstration
  final List<ServiceRequest> _mockRequests = [
    ServiceRequest(
      id: '1',
      userId: '1',
      title: 'Kitchen Waste Collection',
      description: 'Organic waste from kitchen including vegetable peels and food scraps',
      wasteType: WasteType.organic,
      estimatedWeight: 5.0,
      address: 'AJ Hospital, Bejai, Car Street, Mangalore',
      latitude: 12.8738,
      longitude: 74.8354,
      status: RequestStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ServiceRequest(
      id: '2',
      userId: '1',
      title: 'Plastic Bottles Collection',
      description: 'Clean plastic bottles and containers for recycling',
      wasteType: WasteType.plastic,
      estimatedWeight: 3.5,
      address: 'Forum Fiza Mall, Pandeshwar, Mangalore',
      latitude: 12.8806,
      longitude: 74.8428,
      status: RequestStatus.inProgress,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    ),
    ServiceRequest(
      id: '3',
      userId: '2',
      title: 'Paper Waste Pickup',
      description: 'Old newspapers, magazines, and cardboard boxes',
      wasteType: WasteType.paper,
      estimatedWeight: 8.0,
      address: 'Hampankatta Circle, Mangalore',
      latitude: 12.8731,
      longitude: 74.8436,
      status: RequestStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  Future<void> loadRequests() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, you would fetch from an API
      _requests = List.from(_mockRequests);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> createRequest(ServiceRequest request) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Add to local list (in a real app, you would send to API)
      _requests.insert(0, request);
      _mockRequests.insert(0, request);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateRequestStatus(String requestId, String newStatus) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      final requestIndex = _requests.indexWhere((r) => r.id == requestId);
      if (requestIndex != -1) {
        RequestStatus status;
        switch (newStatus.toLowerCase()) {
          case 'completed':
            status = RequestStatus.completed;
            break;
          case 'cancelled':
            status = RequestStatus.cancelled;
            break;
          case 'in_progress':
          case 'inprogress':
            status = RequestStatus.inProgress;
            break;
          case 'assigned':
            status = RequestStatus.assigned;
            break;
          default:
            status = RequestStatus.pending;
        }

        _requests[requestIndex] = _requests[requestIndex].copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );

        // Update mock data as well
        final mockIndex = _mockRequests.indexWhere((r) => r.id == requestId);
        if (mockIndex != -1) {
          _mockRequests[mockIndex] = _requests[requestIndex];
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteRequest(String requestId) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      _requests.removeWhere((r) => r.id == requestId);
      _mockRequests.removeWhere((r) => r.id == requestId);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  List<ServiceRequest> getRequestsByUserId(String userId) {
    return _requests.where((r) => r.userId == userId).toList();
  }

  List<ServiceRequest> getRequestsByStatus(RequestStatus status) {
    return _requests.where((r) => r.status == status).toList();
  }

  ServiceRequest? getRequestById(String id) {
    try {
      return _requests.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }
}
