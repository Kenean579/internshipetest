import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _licenseController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authService.register(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          companyName: _companyController.text.trim(),
          licenseNumber: _licenseController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          AppUIHelpers.showSnackBar(context, 'Registration Successful!',
              isError: false);
          Navigator.pop(context);
        }
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
        title: const Text('CREATE ACCOUNT'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'PARTNER REGISTRATION',
                style: AppTextStyles.display.copyWith(
                  letterSpacing: 1,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Create your account to get started.',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Card(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildSimpleField('Full Name', _fullNameController,
                            Icons.person_outline),
                        const SizedBox(height: 16),
                        _buildSimpleField('Email', _emailController,
                            Icons.alternate_email_rounded,
                            type: TextInputType.emailAddress),
                        const SizedBox(height: 16),
                        _buildSimpleField(
                            'Phone', _phoneController, Icons.phone_android,
                            type: TextInputType.phone),
                        const SizedBox(height: 16),
                        _buildSimpleField('Company Name', _companyController,
                            Icons.business_outlined),
                        const SizedBox(height: 16),
                        _buildSimpleField('License Number', _licenseController,
                            Icons.badge_outlined),
                        const SizedBox(height: 16),
                        _buildSimpleField(
                            'Password', _passwordController, Icons.lock_outline,
                            isPassword: true),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  'REGISTER NOW',
                                  style: AppTextStyles.button.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
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

  Widget _buildSimpleField(
      String label, TextEditingController controller, IconData icon,
      {bool isPassword = false, TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: type,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        if (label == 'Email') {
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(v)) return 'Enter a valid email';
        }
        if (isPassword && v.length < 6) return 'Min 6 chars';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }
}
