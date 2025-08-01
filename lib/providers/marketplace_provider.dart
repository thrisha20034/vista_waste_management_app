import 'package:flutter/material.dart';
import '../models/waste_item.dart';
import '../models/service_request.dart';

class MarketplaceProvider with ChangeNotifier {
  List<WasteItem> _wasteItems = [];
  bool _isLoading = false;

  List<WasteItem> get wasteItems => _wasteItems;
  bool get isLoading => _isLoading;

  Future<void> loadWasteItems() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    _wasteItems = [
      WasteItem(
        id: '1',
        sellerId: '2',
        title: 'Organic Waste',
        description: 'Fresh kitchen waste and garden clippings',
        wasteType: WasteType.organic,
        weight: 25.0,
        pricePerKg: 15.0,
        location: 'Downtown Area',
        latitude: 37.7749,
        longitude: -122.4194,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      WasteItem(
        id: '2',
        sellerId: '3',
        title: 'Paper Waste',
        description: 'Clean office paper and cardboard',
        wasteType: WasteType.paper,
        weight: 50.0,
        pricePerKg: 8.0,
        location: 'Business District',
        latitude: 37.7849,
        longitude: -122.4094,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWasteItem(WasteItem item) async {
    _wasteItems.insert(0, item);
    notifyListeners();
  }

  Future<void> purchaseWasteItem(String itemId) async {
    final index = _wasteItems.indexWhere((item) => item.id == itemId);
    if (index != -1) {
      _wasteItems.removeAt(index);
      notifyListeners();
    }
  }
}