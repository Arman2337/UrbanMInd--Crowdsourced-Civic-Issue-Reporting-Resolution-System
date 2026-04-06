import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';
import '../../../core/theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  final String role; // 'citizen' or 'contractor'

  const SignupScreen({super.key, required this.role});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedCity = 'Mumbai';
  final List<String> _cities = [
    'Mumbai',
    'Delhi',
    'Bangalore',
    'Chennai',
    'Kolkata',
    'Pune',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Passwords do not match'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: widget.role,
      city: widget.role == 'contractor'
          ? _selectedCity
          : 'Unknown', // Citizens don't set city here
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please login.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Registration failed'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String roleDisplay = widget.role == 'contractor' ? 'Contractor' : 'Citizen';
    final theme = Theme.of(context);

    // Only show city selection for Contractors
    final showCityInput = widget.role == 'contractor';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : theme.primaryColor,
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return LoadingOverlay(
            isLoading: authProvider.isLoading,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: theme.brightness == Brightness.dark
                      ? [const Color(0xFF0F1115), const Color(0xFF1E222A)]
                      : [const Color(0xFFE3EEFF), Colors.white],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          widget.role == 'contractor'
                              ? Icons.engineering_rounded
                              : Icons.person_add_alt_1_rounded,
                          size: 70,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Create Account',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: theme.textTheme.displayLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join as a $roleDisplay',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: AppTheme.glassBoxDecoration(
                            context,
                          ).copyWith(color: theme.cardColor),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CustomTextField(
                                  labelText: 'Full Name',
                                  hintText: 'Enter your full name',
                                  prefixIcon: Icons.person_outline_rounded,
                                  controller: _nameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                CustomTextField(
                                  labelText: 'Email Address',
                                  hintText: 'Enter your email',
                                  prefixIcon: Icons.email_outlined,
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                if (showCityInput) ...[
                                  Text(
                                    'Operating City',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          theme.inputDecorationTheme.fillColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.1),
                                      ),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedCity,
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                          prefixIcon: Icon(
                                            Icons.location_city_rounded,
                                          ),
                                        ),
                                        items: _cities.map((String city) {
                                          return DropdownMenuItem<String>(
                                            value: city,
                                            child: Text(
                                              city,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _selectedCity = newValue!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                CustomTextField(
                                  labelText: 'Password',
                                  hintText: 'Create a password',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  controller: _passwordController,
                                  isPassword: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                CustomTextField(
                                  labelText: 'Confirm Password',
                                  hintText: 'Confirm your password',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  controller: _confirmPasswordController,
                                  isPassword: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),
                                CustomButton(
                                  text: 'Create Account',
                                  onPressed: _handleSignup,
                                  isLoading: authProvider.isLoading,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
