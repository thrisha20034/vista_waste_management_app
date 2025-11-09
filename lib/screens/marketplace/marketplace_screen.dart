import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';
// Add this import
import '../../utils/colors.dart';
import 'buy_waste_screen.dart';
import 'sell_waste_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  final int initialTab;

  const MarketplaceScreen({super.key, this.initialTab = 0});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MarketplaceProvider>(context, listen: false).loadWasteItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Row(
      children: [
        ClipOval(
          child: Image.asset(
            'assets/vista.png', // your logo path
            height: 40,
            width: 40,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 120),
        const Text(
          'MarketPlace',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Colors.white,
          ),
        ),
      ],
    ),
    const SizedBox(height: 4),
  ],
),
centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Buy Waste'),
            Tab(text: 'Sell Waste'),
          ],
        ),
      ),
      backgroundColor: AppColors.background,
      body: TabBarView(
        controller: _tabController,
        children: [
          _BuyWasteListTab(), // Changed this line
          const SellWasteScreen(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Add this new widget class
class _BuyWasteListTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MarketplaceProvider>(
      builder: (context, marketplaceProvider, child) {
        if (marketplaceProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (marketplaceProvider.wasteItems.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No waste items available', style: TextStyle(fontSize: 18, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: marketplaceProvider.wasteItems.length,
          itemBuilder: (context, index) {
            final item = marketplaceProvider.wasteItems[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withOpacity(0.1),
                  child: const Icon(Icons.eco, color: Colors.green),
                ),
                title: Text(item.title),
                subtitle: Text('${item.weight} kg - Rs.${item.pricePerKg}/kg'),
                trailing: Text('Rs.${(item.weight * item.pricePerKg).toStringAsFixed(2)}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BuyWasteScreen(wasteItem: item),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}