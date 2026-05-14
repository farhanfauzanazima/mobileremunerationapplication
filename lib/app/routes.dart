class AppRoutes {
  static const String splash  = '/';
  static const String login   = '/login';
  static const String profile = '/profile';

  static const String dashboardOwner = '/dashboard/owner';
  static const String dashboardHead  = '/dashboard/head';
  static const String dashboardAdmin = '/dashboard/admin';

  static const String salaryCategories     = '/salary-categories';
  static const String salaryCategoryCreate = '/salary-categories/create';
  static const String salaryCategoryEdit   = '/salary-categories/edit';

  static const String employees      = '/employees';
  static const String employeeCreate = '/employees/create';
  static const String employeeEdit   = '/employees/edit';
  static const String employeeDetail = '/employees/detail';

  static const String payrollPeriods      = '/payroll-periods';
  static const String payrollPeriodCreate = '/payroll-periods/create';

  static const String salarySlips      = '/salary-slips';
  static const String salarySlipCreate = '/salary-slips/create';
  static const String salarySlipDetail = '/salary-slips/detail';
  static const String salarySlipBulk   = '/salary-slips/bulk';

  static const String pdfViewer = '/pdf-viewer';

  static const String emailHistory  = '/email/history';
  static const String emailBulkSend = '/email/bulk-send';

  // Tambahkan routes baru
  static const String reports     = '/reports';
  static const String statistics  = '/statistics';
  static const String activityLog = '/activity-logs';
}