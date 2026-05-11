import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/profile_screen.dart';
import '../shared/theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import 'routes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash:  (_) => const SplashScreen(),
          AppRoutes.login:   (_) => const LoginScreen(),
          AppRoutes.profile: (_) => const ProfileScreen(),

          // Placeholder dashboard — akan diganti di Sesi 9
          AppRoutes.dashboardOwner: (_) => const _DashboardPlaceholder(role: 'Owner'),
          AppRoutes.dashboardHead:  (_) => const _DashboardPlaceholder(role: 'Kepala Toko'),
          AppRoutes.dashboardAdmin: (_) => const _DashboardPlaceholder(role: 'Admin Toko'),
        },
      ),
    );
  }
}

// Placeholder sementara sampai Sesi 9
class _DashboardPlaceholder extends StatelessWidget {
  final String role;
  const _DashboardPlaceholder({required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard $role'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.profile),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle,
                color: AppTheme.secondary, size: 64),
            const SizedBox(height: 16),
            Text(
              'Login berhasil sebagai $role ✅',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Dashboard akan dibangun di Sesi 9',
              style: TextStyle(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 32),
            Consumer<AuthProvider>(
              builder: (context, auth, _) => ElevatedButton.icon(
                onPressed: () async {
                  await auth.logout();
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  minimumSize: const Size(200, 48),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}