import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../models/service_item.dart';
import '../../services/db_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import 'package:uuid/uuid.dart';

class EditServiceScreen extends StatefulWidget {
  final ServiceCategory category;
  final ServiceItem? service;

  const EditServiceScreen({super.key, required this.category, this.service});

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _vatController = TextEditingController();
  final _discountController = TextEditingController();
  final _imageController = TextEditingController();
  final DbService _db = DbService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _nameController.text = widget.service!.serviceName;
      _priceController.text = widget.service!.basePrice.toString();
      _vatController.text = widget.service!.vatPercent.toString();
      _discountController.text = widget.service!.discountAmount.toString();
      _imageController.text = widget.service!.imageUrl ?? '';
    } else {
      _vatController.text = '15'; // Default VAT
      _discountController.text = '0';
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final id = widget.service?.id ?? const Uuid().v4();
        final basePrice = double.parse(_priceController.text.trim());
        final vatPercent = double.parse(_vatController.text.trim());
        final discountAmount = double.parse(_discountController.text.trim());

        final service = ServiceItem(
          id: id,
          categoryId: widget.category.id,
          serviceName: _nameController.text.trim(),
          basePrice: basePrice,
          vatPercent: vatPercent,
          discountAmount: discountAmount,
          imageUrl: _imageController.text.trim().isEmpty
              ? null
              : _imageController.text.trim(),
        );

        if (widget.service == null) {
          await _db.addService(service);
        } else {
          await _db.updateService(service);
        }

        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service == null ? 'New Service' : 'Edit Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                label: 'Service Name',
                controller: _nameController,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Base Price',
                controller: _priceController,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'VAT (%)',
                controller: _vatController,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Discount Amount',
                controller: _discountController,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Image URL (Optional)',
                controller: _imageController,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Save Service',
                onPressed: _save,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
