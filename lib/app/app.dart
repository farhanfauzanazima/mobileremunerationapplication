import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobileremunerationapplication/features/auth/providers/auth_provider.dart';
import 'package:mobileremunerationapplication/features/auth/presentation/screens/splash_screen.dart';
import 'package:mobileremunerationapplication/features/auth/presentation/screens/login_screen.dart';
import 'package:mobileremunerationapplication/features/auth/presentation/screens/profile_screen.dart';
import 'package:mobileremunerationapplication/features/salary_category/providers/salary_category_provider.dart';
import 'package:mobileremunerationapplication/features/salary_category/presentation/screens/salary_category_list_screen.dart';
import 'package:mobileremunerationapplication/features/salary_category/presentation/screens/salary_category_form_screen.dart';
import 'package:mobileremunerationapplication/features/employee/providers/employee_provider.dart';
import 'package:mobileremunerationapplication/features/employee/presentation/screens/employee_list_screen.dart';
import 'package:mobileremunerationapplication/features/employee/presentation/screens/employee_form_screen.dart';
import 'package:mobileremunerationapplication/features/employee/presentation/screens/employee_detail_screen.dart';
import 'package:mobileremunerationapplication/features/payroll_period/providers/payroll_period_provider.dart';
import 'package:mobileremunerationapplication/features/payroll_period/presentation/screens/payroll_period_list_screen.dart';
import 'package:mobileremunerationapplication/features/payroll_period/presentation/screens/payroll_period_form_screen.dart';
import 'package:mobileremunerationapplication/features/salary_slip/providers/salary_slip_provider.dart';
import 'package:mobileremunerationapplication/features/salary_slip/presentation/screens/salary_slip_list_screen.dart';
import 'package:mobileremunerationapplication/features/salary_slip/presentation/screens/salary_slip_detail_screen.dart';
import 'package:mobileremunerationapplication/features/salary_slip/presentation/screens/salary_slip_form_screen.dart';
import 'package:mobileremunerationapplication/features/salary_slip/presentation/screens/salary_slip_bulk_screen.dart';
import 'package:mobileremunerationapplication/shared/theme/app_theme.dart';
import 'package:mobileremunerationapplication/core/constants/app_constants.dart';
import 'package:mobileremunerationapplication/app/routes.dart';
import 'package:mobileremunerationapplication/features/salary_slip/providers/pdf_provider.dart';
import 'package:mobileremunerationapplication/features/salary_slip/presentation/screens/pdf_viewer_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SalaryCategoryProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => PayrollPeriodProvider()),
        ChangeNotifierProvider(create: (_) => SalarySlipProvider()),
        ChangeNotifierProvider(create: (_) => PdfProvider()),
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

          AppRoutes.salaryCategories:     (_) => const SalaryCategoryListScreen(),
          AppRoutes.salaryCategoryCreate: (_) => const SalaryCategoryFormScreen(),
          AppRoutes.salaryCategoryEdit:   (_) => const SalaryCategoryFormScreen(),

          AppRoutes.employees:      (_) => const EmployeeListScreen(),
          AppRoutes.employeeCreate: (_) => const EmployeeFormScreen(),
          AppRoutes.employeeEdit:   (_) => const EmployeeFormScreen(),
          AppRoutes.employeeDetail: (_) => const EmployeeDetailScreen(),

          AppRoutes.payrollPeriods:      (_) => const PayrollPeriodListScreen(),
          AppRoutes.payrollPeriodCreate: (_) => const PayrollPeriodFormScreen(),

          AppRoutes.salarySlips:      (_) => const SalarySlipListScreen(),
          AppRoutes.salarySlipCreate: (_) => const SalarySlipFormScreen(),
          AppRoutes.salarySlipDetail: (_) => const SalarySlipDetailScreen(),
          AppRoutes.salarySlipBulk:   (_) => const SalarySlipBulkScreen(),

          AppRoutes.dashboardOwner: (_) => const _DashboardPlaceholder(role: 'Owner'),
          AppRoutes.dashboardHead:  (_) => const _DashboardPlaceholder(role: 'Kepala Toko'),
          AppRoutes.dashboardAdmin: (_) => const _DashboardPlaceholder(role: 'Admin Toko'),

          AppRoutes.pdfViewer: (_) => const PdfViewerScreen(),
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
    final isAdmin = role == 'Admin Toko';

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
                'Login sebagai $role ✅',
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
                _MenuButton(
                  icon: Icons.date_range_outlined,
                  label: 'Periode Penggajian',
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.payrollPeriods),
                ),
                const SizedBox(height: 12),
              ],

              if (isOwner || isHead || isAdmin) ...[
                _MenuButton(
                  icon: Icons.receipt_long_outlined,
                  label: 'Slip Gaji',
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.salarySlips),
                ),
                const SizedBox(height: 12),
              ],

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