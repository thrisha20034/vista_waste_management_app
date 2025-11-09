import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marketplace_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/waste_item.dart';
import '../../models/service_request.dart';
import '../../utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class BuyWasteScreen extends StatefulWidget {
  final WasteItem wasteItem;

  const BuyWasteScreen({super.key, required this.wasteItem});

  @override
  State<BuyWasteScreen> createState() => _BuyWasteScreenState();
}

class _BuyWasteScreenState extends State<BuyWasteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  // Payment form controllers
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _upiController = TextEditingController();

  bool _isLoading = false;
  String _selectedPaymentMethod = 'card';
  String _selectedAddress = '';

  // Mangalore addresses for delivery
  final List<String> _mangaloreAddresses = [
    'AJ Hospital, Bejai, Car Street, Mangalore',
    'Forum Fiza Mall, Pandeshwar, Mangalore',
    'Hampankatta Circle, Mangalore',
    'Kadri Temple Area, Mangalore',
    'Mangaladevi Temple, Bolar, Mangalore',
    'Lalbagh, Falnir, Mangalore',
    'Valencia, Kulshekar, Mangalore',
    'Kankanady Market, Mangalore',
  ];

  @override
  void initState() {
    super.initState();
    _quantityController.text = widget.wasteItem.weight.toString();
    _selectedAddress = _mangaloreAddresses.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(children: [
Image.asset(
        'assets/vista.png', // your logo path
        height: 40,
      ),
      SizedBox(width: 120,),
      const Text(
            'Buy Waste',
            style: TextStyle(fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Colors.white,
            ),
          ),
      ],),
       
      // Logo on top
      
      const SizedBox(height: 4),
      // App name and subtitle
    ],
  ),
  centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildItemDetails(),
              const SizedBox(height: 24),
              _buildPurchaseForm(),
              const SizedBox(height: 24),
              _buildDeliveryAddress(),
              const SizedBox(height: 24),
              _buildPriceCalculation(),
              const SizedBox(height: 24),
              _buildPaymentSection(),
              const SizedBox(height: 32),
              _buildPurchaseButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getWasteTypeColor(widget.wasteItem.wasteType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getWasteTypeIcon(widget.wasteItem.wasteType),
                    color: _getWasteTypeColor(widget.wasteItem.wasteType),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.wasteItem.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getWasteTypeText(widget.wasteItem.wasteType),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.wasteItem.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildDetailItem(
                  'Available Weight',
                  '${widget.wasteItem.weight} kg',
                  Icons.scale,
                ),
                const SizedBox(width: 24),
                _buildDetailItem(
                  'Price per kg',
                  '₹${widget.wasteItem.pricePerKg.toStringAsFixed(2)}',
                  Icons.currency_rupee,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Available in Mangalore',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPurchaseForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Purchase Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity (kg)',
                hintText: 'Enter quantity to purchase',
                prefixIcon: const Icon(Icons.scale),
                suffixText: 'kg',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() {}),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter quantity';
                }
                final quantity = double.tryParse(value);
                if (quantity == null || quantity <= 0) {
                  return 'Please enter a valid quantity';
                }
                if (quantity > widget.wasteItem.weight) {
                  return 'Quantity cannot exceed available weight';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Additional Notes (Optional)',
                hintText: 'Any special requirements or notes',
                prefixIcon: const Icon(Icons.note),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedAddress,
              decoration: InputDecoration(
                labelText: 'Select Delivery Address',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _mangaloreAddresses.map((address) {
                return DropdownMenuItem(
                  value: address,
                  child: Text(
                    address,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAddress = value!;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a delivery address';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCalculation() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final subtotal = quantity * widget.wasteItem.pricePerKg;
    const deliveryFee = 50.0; // Fixed delivery fee
    final gst = subtotal * 0.18; // 18% GST
    final totalPrice = subtotal + deliveryFee + gst;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildPriceRow('Price per kg:', '₹${widget.wasteItem.pricePerKg.toStringAsFixed(2)}'),
            _buildPriceRow('Quantity:', '${quantity.toStringAsFixed(1)} kg'),
            _buildPriceRow('Subtotal:', '₹${subtotal.toStringAsFixed(2)}'),
            _buildPriceRow('Delivery Fee:', '₹${deliveryFee.toStringAsFixed(2)}'),
            _buildPriceRow('GST (18%):', '₹${gst.toStringAsFixed(2)}'),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '₹${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodSelector(),
            const SizedBox(height: 20),
            _buildPaymentForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildPaymentMethodCard(
            'card',
            'Credit/Debit Card',
            Icons.credit_card,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPaymentMethodCard(
            'upi',
            'UPI Payment',
            Icons.account_balance_wallet,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPaymentMethodCard(
            'cod',
            'Cash on Delivery',
            Icons.money,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(String method, String title, IconData icon) {
    final isSelected = _selectedPaymentMethod == method;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    switch (_selectedPaymentMethod) {
      case 'card':
        return _buildCardPaymentForm();
      case 'upi':
        return _buildUPIPaymentForm();
      case 'cod':
        return _buildCODPaymentForm();
      default:
        return Container();
    }
  }

  Widget _buildCardPaymentForm() {
    return Column(
      children: [
        TextFormField(
          controller: _cardNumberController,
          decoration: InputDecoration(
            labelText: 'Card Number',
            hintText: '1234 5678 9012 3456',
            prefixIcon: const Icon(Icons.credit_card),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter card number';
            }
            if (value.replaceAll(' ', '').length != 16) {
              return 'Please enter a valid 16-digit card number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _cardHolderController,
          decoration: InputDecoration(
            labelText: 'Cardholder Name',
            hintText: 'Enter name on card',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter cardholder name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _expiryController,
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'MM/YY',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter expiry date';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _cvvController,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter CVV';
                  }
                  if (value.length != 3) {
                    return 'Please enter a valid 3-digit CVV';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUPIPaymentForm() {
    return Column(
      children: [
        TextFormField(
          controller: _upiController,
          decoration: InputDecoration(
            labelText: 'UPI ID',
            hintText: 'yourname@upi',
            prefixIcon: const Icon(Icons.account_balance_wallet),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter UPI ID';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid UPI ID';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: const Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You will be redirected to your UPI app to complete the payment',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCODPaymentForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.money, color: Colors.orange),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cash on Delivery',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pay in cash when the waste is delivered to your location in Mangalore',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handlePurchase,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          _selectedPaymentMethod == 'cod'
              ? 'Place Order (Cash on Delivery)'
              : 'Pay Now & Place Order',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _handlePurchase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show confirmation dialog first
    final paymentMethod = _getPaymentMethodText();
    final confirmed = await _showPurchaseConfirmation(context, paymentMethod);

    if (!confirmed) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final quantity = double.parse(_quantityController.text);
      final subtotal = quantity * widget.wasteItem.pricePerKg;
      const deliveryFee = 50.0;
      final gst = subtotal * 0.18;
      final totalPrice = subtotal + deliveryFee + gst;

      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      // Remove item from marketplace
      if (mounted) {
        final marketplaceProvider = Provider.of<MarketplaceProvider>(context, listen: false);
        await marketplaceProvider.removeWasteItem(widget.wasteItem.id);
      }

      if (mounted) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                SizedBox(width: 8),
                Text('Order Placed Successfully!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Order Details:'),
                const SizedBox(height: 8),
                Text('• Item: ${widget.wasteItem.title}'),
                Text('• Quantity: ${quantity.toStringAsFixed(1)} kg'),
                Text('• Total: ₹${totalPrice.toStringAsFixed(2)}'),
                Text('• Payment: $paymentMethod'),
                const SizedBox(height: 8),
                const Text('Delivery Address:'),
                Text(_selectedAddress, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                const Text('The seller will contact you within 24 hours for delivery arrangements.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to marketplace
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getPaymentMethodText() {
    switch (_selectedPaymentMethod) {
      case 'card':
        return 'Card Payment';
      case 'upi':
        return 'UPI Payment';
      case 'cod':
        return 'Cash on Delivery';
      default:
        return 'Unknown';
    }
  }

  Color _getWasteTypeColor(WasteType type) {
    switch (type) {
      case WasteType.organic:
        return Colors.green;
      case WasteType.plastic:
        return Colors.blue;
      case WasteType.paper:
        return Colors.orange;
      case WasteType.electronic:
        return Colors.purple;
      case WasteType.hazardous:
        return Colors.red;
      case WasteType.mixed:
        return Colors.grey;
    }
  }

  IconData _getWasteTypeIcon(WasteType type) {
    switch (type) {
      case WasteType.organic:
        return Icons.eco;
      case WasteType.plastic:
        return Icons.recycling;
      case WasteType.paper:
        return Icons.description;
      case WasteType.electronic:
        return Icons.computer;
      case WasteType.hazardous:
        return Icons.warning;
      case WasteType.mixed:
        return Icons.category;
    }
  }

  String _getWasteTypeText(WasteType type) {
    switch (type) {
      case WasteType.organic:
        return 'Organic Waste';
      case WasteType.plastic:
        return 'Plastic Waste';
      case WasteType.paper:
        return 'Paper Waste';
      case WasteType.electronic:
        return 'Electronic Waste';
      case WasteType.hazardous:
        return 'Hazardous Waste';
      case WasteType.mixed:
        return 'Mixed Waste';
    }
  }

  void _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<bool> _showPurchaseConfirmation(BuildContext context, String paymentMethod) async {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final subtotal = quantity * widget.wasteItem.pricePerKg;
    const deliveryFee = 50.0;
    final gst = subtotal * 0.18;
    final totalAmount = subtotal + deliveryFee + gst;

    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Purchase'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to purchase this waste item?'),
              const SizedBox(height: 8),
              Text('Payment Method: $paymentMethod'),
              const SizedBox(height: 8),
              Text('Quantity: ${quantity.toStringAsFixed(1)} kg'),
              Text('Total Amount: ₹${totalAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              const Text('Delivery in Mangalore area only.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text(
                'Confirm Purchase',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    _upiController.dispose();
    super.dispose();
  }
}
