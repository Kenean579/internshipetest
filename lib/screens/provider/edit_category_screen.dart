import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/category.dart';
import '../../services/db_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../utils/styles.dart';
import 'package:uuid/uuid.dart';

class EditCategoryScreen extends StatefulWidget {
  final ServiceCategory? category;

  const EditCategoryScreen({super.key, this.category});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final DbService _db = DbService();
  final StorageService _storage = StorageService();

  bool _isLoading = false;
  File? _selectedImage;
  String? _currentImageUrl;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _titleController.text = widget.category!.title;
      _descriptionController.text = widget.category!.description;
      _currentImageUrl = widget.category!.iconUrl;
      _isActive = widget.category!.status == 'active';
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
          imageUrl = await _storage.uploadImage(_selectedImage!, 'categories');
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw 'User not logged in';

        final id = widget.category?.id ?? const Uuid().v4();
        final category = ServiceCategory(
          id: id,
          providerId: user.uid,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          iconUrl: imageUrl ?? '',
          status: _isActive ? 'active' : 'inactive',
        );

        if (widget.category == null) {
          await _db.addCategory(category);
        } else {
          await _db.updateCategory(category);
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
        title: Text(
          widget.category == null ? 'NEW CATEGORY' : 'EDIT CATEGORY',
          style: AppTextStyles.header.copyWith(fontSize: 14, letterSpacing: 1),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 140,
                    width: 140,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1,
                      ),
                      boxShadow: AppColors.shadowSm,
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover)
                          : (_currentImageUrl != null &&
                                  _currentImageUrl!.isNotEmpty)
                              ? DecorationImage(
                                  image: NetworkImage(_currentImageUrl!),
                                  fit: BoxFit.cover)
                              : null,
                    ),
                    child: (_selectedImage == null &&
                            (_currentImageUrl == null ||
                                _currentImageUrl!.isEmpty))
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_photo_alternate_rounded,
                                  size: 40, color: AppColors.primary),
                              const SizedBox(height: 8),
                              Text('UPLOAD ICON',
                                  style: AppTextStyles.bodySecondary.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1)),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text('BASIC INFORMATION',
                  style: AppTextStyles.header.copyWith(
                      fontSize: 12,
                      letterSpacing: 2,
                      color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Category Title',
                controller: _titleController,
                validator: (v) => v!.isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Description',
                controller: _descriptionController,
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: SwitchListTile(
                  title: Text(
                    'LISTING STATUS',
                    style: AppTextStyles.subHeader
                        .copyWith(fontSize: 12, letterSpacing: 1),
                  ),
                  subtitle: Text(
                    _isActive
                        ? 'Visible to customers'
                        : 'Hidden from customers',
                    style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                  ),
                  value: _isActive,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isActive = val),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                text: widget.category == null
                    ? 'SAVE CATEGORY'
                    : 'UPDATE CATEGORY',
                onPressed: _save,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
