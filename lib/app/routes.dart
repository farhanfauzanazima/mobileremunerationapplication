class AppRoutes {
  static const String splash  = '/';
  static const String login   = '/login';
  static const String profile = '/profile';

  static const String dashboardOwner = '/dashboard/owner';
  static const String dashboardHead  = '/dashboard/head';
  static const String dashboardAdmin = '/dashboard/admin';

  // Salary Category
  static const String salaryCategories     = '/salary-categories';
  static const String salaryCategoryCreate = '/salary-categories/create';
  static const String salaryCategoryEdit   = '/salary-categories/edit';

  // Employee
  static const String employees      = '/employees';
  static const String employeeCreate = '/employees/create';
  static const String employeeEdit   = '/employees/edit';
  static const String employeeDetail = '/employees/detail';

  // Payroll Period
  static const String payrollPeriods      = '/payroll-periods';
  static const String payrollPeriodCreate = '/payroll-periods/create';

  // Salary Slip
  static const String salarySlips      = '/salary-slips';
  static const String salarySlipCreate = '/salary-slips/create';
  static const String salarySlipDetail = '/salary-slips/detail';
  static const String salarySlipBulk   = '/salary-slips/bulk';

  // Email
  static const String emailHistory = '/email/history';

  // Reports
  static const String reports     = '/reports';
  static const String activityLog = '/activity-logs';
}