import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/profile_screen.dart';
import '../features/salary_category/providers/salary_category_provider.dart';
import '../features/salary_category/presentation/screens/salary_category_list_screen.dart';
import '../features/salary_category/presentation/screens/salary_category_form_screen.dart';
import '../features/employee/providers/employee_provider.dart';
import '../features/employee/presentation/screens/employee_list_screen.dart';
import '../features/employee/presentation/screens/employee_form_screen.dart';
import '../features/employee/presentation/screens/employee_detail_screen.dart';
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
        ChangeNotifierProvider(create: (_) => SalaryCategoryProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash:   (_) => const SplashScreen(),
          AppRoutes.login:    (_) => const LoginScreen(),
          AppRoutes.profile:  (_) => const ProfileScreen(),

          // Salary Category
          AppRoutes.salaryCategories:     (_) => const SalaryCategoryListScreen(),
          AppRoutes.salaryCategoryCreate: (_) => const SalaryCategoryFormScreen(),
          AppRoutes.salaryCategoryEdit:   (_) => const SalaryCategoryFormScreen(),

          // Employee
          AppRoutes.employees:      (_) => const EmployeeListScreen(),
          AppRoutes.employeeCreate: (_) => const EmployeeFormScreen(),
          AppRoutes.employeeEdit:   (_) => const EmployeeFormScreen(),
          AppRoutes.employeeDetail: (_) => const EmployeeDetailScreen(),

          // Dashboard placeholder
          AppRoutes.dashboardOwner: (_) => const _DashboardPlaceholder(role: 'Owner'),
          AppRoutes.dashboardHead:  (_) => const _DashboardPlaceholder(role: 'Kepala Toko'),
          AppRoutes.dashboardAdmin: (_) => const _DashboardPlaceholder(role: 'Admin Toko'),
        },
      ),
    );
  }
}

class _DashboardPlaceholder extends StatelessWidget {
  final String role;
  const _DashboardPlaceholder({required this.role});

  @override
  Widget build(BuildContext context) {
    final isOwner = role == 'Owner';
    final isHead  = role == 'Kepala Toko';

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle,
                  color: AppTheme.secondary, size: 64),
              const SizedBox(height: 16),
              Text(
                'Login berhasil sebagai $role ✅',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              if (isOwner) ...[
                _MenuButton(
                  icon: Icons.category_outlined,
                  label: 'Kategori Gaji',
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.salaryCategories),
                ),
                const SizedBox(height: 12),
              ],

              if (isOwner || isHead) ...[
                _MenuButton(
                  icon: Icons.people_outline,
                  label: 'Data Karyawan',
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.employees),
                ),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 12),
              Consumer<AuthProvider>(
                builder: (context, auth, _) => _MenuButton(
                  icon: Icons.logout,
                  label: 'Logout',
                  color: AppTheme.accent,
                  onTap: () async {
                    await auth.logout();
                    if (!context.mounted) return;
                    Navigator.pushReplacementNamed(
                        context, AppRoutes.login);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(220, 48),
      ),
    );
  }
}