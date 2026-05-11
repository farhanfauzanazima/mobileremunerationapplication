import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../app/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword     = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      _navigateByRole(authProvider.user?.role ?? '');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.message),
          backgroundColor: AppTheme.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateByRole(String role) {
    switch (role) {
      case AppConstants.roleOwner:
        Navigator.pushReplacementNamed(context, AppRoutes.dashboardOwner);
        break;
      case AppConstants.roleHead:
        Navigator.pushReplacementNamed(context, AppRoutes.dashboardHead);
        break;
      case AppConstants.roleAdmin:
        Navigator.pushReplacementNamed(context, AppRoutes.dashboardAdmin);
        break;
      default:
        Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // Header
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    color: AppTheme.primary,
                    size: 44,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  'Masuk ke akun Anda',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        hintText: 'Masukkan email Anda',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email wajib diisi';
                        }
                        if (!value.contains('@')) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        hintText: 'Masukkan password Anda',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password wajib diisi';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Tombol Login
                    Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        return ElevatedButton(
                          onPressed: auth.isLoading ? null : _login,
                          child: auth.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width:  20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Masuk'),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Info default accounts (untuk testing)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.blue.shade700, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Akun Testing',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildAccountInfo('Owner',       'owner@resto.com'),
                    _buildAccountInfo('Kepala Toko', 'head@resto.com'),
                    _buildAccountInfo('Admin',       'admin@resto.com'),
                    const SizedBox(height: 4),
                    Text(
                      'Password semua akun: password123',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountInfo(String role, String email) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              role,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            ': $email',
            style: TextStyle(
              color: Colors.blue.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}