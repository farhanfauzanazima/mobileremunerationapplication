class ApiConstants {
  // Ganti dengan IP komputer kamu jika test di device fisik
  // Gunakan 10.0.2.2 jika test di Android Emulator
  // Gunakan localhost jika test di web/desktop
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Auth
  static const String login          = '/auth/login';
  static const String logout         = '/auth/logout';
  static const String profile        = '/auth/profile';
  static const String updateProfile  = '/auth/profile';
  static const String changePassword = '/auth/change-password';

  // Salary Categories
  static const String salaryCategories = '/salary-categories';

  // Employees
  static const String employees = '/employees';

  // Payroll Periods
  static const String payrollPeriods = '/payroll-periods';

  // Salary Slips
  static const String salarySlips          = '/salary-slips';
  static const String bulkGenerate         = '/salary-slips/bulk-generate';
  static const String bulkGeneratePdf      = '/salary-slips/bulk-generate-pdf';

  // Email
  static const String emailSendBulk = '/email/send-bulk';
  static const String emailHistory   = '/email/history';

  // Dashboard
  static const String dashboardOwner = '/dashboard/owner';
  static const String dashboardHead  = '/dashboard/head';
  static const String dashboardAdmin = '/dashboard/admin';

  // Reports
  static const String salarySummary   = '/reports/salary-summary';
  static const String reportStatistics = '/reports/statistics';

  // Activity Logs
  static const String activityLogs = '/activity-logs';
}