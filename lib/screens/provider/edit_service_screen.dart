import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/category.dart';
import '../../models/service_item.dart';
import '../../services/db_service.dart';
import '../../services/storage_service.dart';
import '../../utils/styles.dart';
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
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _vatController = TextEditingController();
  final _discountController = TextEditingController();
  final DbService _db = DbService();
  final StorageService _storage = StorageService();

  bool _isLoading = false;
  File? _selectedImage;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _nameController.text = widget.service!.serviceName;
      _descriptionController.text = widget.service!.description;
      _priceController.text = widget.service!.basePrice.toString();
      _vatController.text = widget.service!.vatPercent.toString();
      _discountController.text = widget.service!.discountAmount.toString();
      _currentImageUrl = widget.service!.imageUrl;
    } else {
      _vatController.text = '15';
      _discountController.text = '0';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        String? imageUrl = _currentImageUrl;

        if (_selectedImage != null) {
          imageUrl = await _storage.uploadImage(_selectedImage!, 'services');
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw 'User not logged in';

        final id = widget.service?.id ?? const Uuid().v4();
        final basePrice = double.parse(_priceController.text.trim());
        final vatPercent = double.parse(_vatController.text.trim());
        final discountAmount = double.parse(_discountController.text.trim());

        final service = ServiceItem(
          id: id,
          providerId: user.uid,
          categoryId: widget.category.id,
          serviceName: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          basePrice: basePrice,
          vatPercent: vatPercent,
          discountAmount: discountAmount,
          imageUrl: imageUrl,
        );

        if (widget.service == null) {
          await _db.addService(service);
        } else {
          await _db.updateService(service);
        }

        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          AppUIHelpers.showSnackBar(context, e.toString());
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.service == null ? 'NEW SERVICE' : 'EDIT SERVICE'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _isLoading ? null : _pickImage,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: AppColors.surface,
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : (_currentImageUrl != null &&
                                _currentImageUrl!.isNotEmpty)
                            ? Image.network(_currentImageUrl!,
                                fit: BoxFit.cover)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.image_search_rounded,
                                      size: 40, color: AppColors.textLight),
                                  const SizedBox(height: 12),
                                  Text('Select Service Image',
                                      style: AppTextStyles.bodySecondary),
                                ],
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Service Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                          labelText: 'Base Price', prefixText: 'ETB '),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final val = double.tryParse(v);
                        if (val == null || val < 0) return 'Invalid price';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _vatController,
                      decoration: const InputDecoration(labelText: 'VAT %'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final val = double.tryParse(v);
                        if (val == null || val < 0) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(
                    labelText: 'Discount Amount', prefixText: 'ETB '),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final val = double.tryParse(v);
                  if (val == null || val < 0) return 'Invalid';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(widget.service == null
                        ? 'CREATE SERVICE'
                        : 'UPDATE SERVICE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
