import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/request_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/service_request.dart';
import '../../utils/colors.dart';

class CreateRequestScreen extends StatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _weightController = TextEditingController();

  WasteType _selectedWasteType = WasteType.organic;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Request'),
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
              const Text(
                'New Waste Collection Request',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fill in the details below to create a new request',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Request Title',
                  hintText: 'e.g., Kitchen Waste Collection',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the waste to be collected',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Waste Type Selection
              const Text(
                'Waste Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildWasteTypeSelection(),
              const SizedBox(height: 16),

              // Weight Field
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Estimated Weight (kg)',
                  hintText: 'e.g., 5.0',
                  prefixIcon: const Icon(Icons.scale),
                  suffixText: 'kg',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter estimated weight';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0) {
                    return 'Please enter a valid weight';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Address Field
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Collection Address',
                  hintText: 'e.g., AJ Hospital, Bejai, Car Street, Mangalore',
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter collection address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleCreateRequest,
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
                      : const Text(
                    'Create Request',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWasteTypeSelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: WasteType.values.map((type) {
        final isSelected = _selectedWasteType == type;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedWasteType = type;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getWasteTypeIcon(type),
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  _getWasteTypeText(type),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
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
        return 'Organic';
      case WasteType.plastic:
        return 'Plastic';
      case WasteType.paper:
        return 'Paper';
      case WasteType.electronic:
        return 'Electronic';
      case WasteType.hazardous:
        return 'Hazardous';
      case WasteType.mixed:
        return 'Mixed';
    }
  }

  Future<void> _handleCreateRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final requestProvider = Provider.of<RequestProvider>(context, listen: false);

      final request = ServiceRequest(
        id: const Uuid().v4(),
        userId: authProvider.user!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        wasteType: _selectedWasteType,
        estimatedWeight: double.parse(_weightController.text),
        address: _addressController.text.trim(),
        latitude: 12.8697, // Mangalore - AJ Hospital, Bejai, Car Street
        longitude: 74.8420,
        status: RequestStatus.pending,
        createdAt: DateTime.now(),
      );

      await requestProvider.createRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create request: ${e.toString()}'),
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

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}
