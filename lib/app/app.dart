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
import 'package:mobileremunerationapplication/features/salary_slip/providers/pdf_provider.dart';
import 'package:mobileremunerationapplication/features/salary_slip/presentation/screens/salary_slip_list_screen.dart';
import 'package:mobileremunerationapplication/features/salary_slip/presentation/screens/salary_slip_detail_screen.dart';
import 'package:mobileremunerationapplication/features/salary_slip/presentation/screens/salary_slip_form_screen.dart';
import 'package:mobileremunerationapplication/features/salary_slip/presentation/screens/salary_slip_bulk_screen.dart';
import 'package:mobileremunerationapplication/features/salary_slip/presentation/screens/pdf_viewer_screen.dart';
import 'package:mobileremunerationapplication/features/email/providers/email_provider.dart';
import 'package:mobileremunerationapplication/features/email/presentation/screens/email_history_screen.dart';
import 'package:mobileremunerationapplication/features/email/presentation/screens/email_bulk_send_screen.dart';
import 'package:mobileremunerationapplication/features/dashboard/providers/dashboard_provider.dart';
import 'package:mobileremunerationapplication/features/dashboard/presentation/screens/dashboard_owner_screen.dart';
import 'package:mobileremunerationapplication/features/dashboard/presentation/screens/dashboard_head_screen.dart';
import 'package:mobileremunerationapplication/features/dashboard/presentation/screens/dashboard_admin_screen.dart';
import 'package:mobileremunerationapplication/shared/theme/app_theme.dart';
import 'package:mobileremunerationapplication/core/constants/app_constants.dart';
import 'package:mobileremunerationapplication/app/routes.dart';

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
        ChangeNotifierProvider(create: (_) => EmailProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
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

          // Payroll Period
          AppRoutes.payrollPeriods:      (_) => const PayrollPeriodListScreen(),
          AppRoutes.payrollPeriodCreate: (_) => const PayrollPeriodFormScreen(),

          // Salary Slip
          AppRoutes.salarySlips:      (_) => const SalarySlipListScreen(),
          AppRoutes.salarySlipCreate: (_) => const SalarySlipFormScreen(),
          AppRoutes.salarySlipDetail: (_) => const SalarySlipDetailScreen(),
          AppRoutes.salarySlipBulk:   (_) => const SalarySlipBulkScreen(),

          // PDF
          AppRoutes.pdfViewer: (_) => const PdfViewerScreen(),

          // Email
          AppRoutes.emailHistory:  (_) => const EmailHistoryScreen(),
          AppRoutes.emailBulkSend: (_) => const EmailBulkSendScreen(),

          // Dashboard (real screens)
          AppRoutes.dashboardOwner: (_) => const DashboardOwnerScreen(),
          AppRoutes.dashboardHead:  (_) => const DashboardHeadScreen(),
          AppRoutes.dashboardAdmin: (_) => const DashboardAdminScreen(),
        },
      ),
    );
  }
}