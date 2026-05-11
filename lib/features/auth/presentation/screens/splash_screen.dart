import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../app/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final isLoggedIn   = await authProvider.checkAuth();

    if (!mounted) return;

    if (isLoggedIn) {
      _navigateByRole(authProvider.user?.role ?? '');
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
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
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo / Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Colors.white,
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sistem Penggajian Restoran',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}