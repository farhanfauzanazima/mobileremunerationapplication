class ApiConstants {
  // static const String baseUrl = 'http://10.0.2.2:8000/api';
  static const String baseUrl = 'http://172.18.0.218:8000/api';

  static const String login          = '/auth/login';
  static const String logout         = '/auth/logout';
  static const String profile        = '/auth/profile';
  static const String updateProfile  = '/auth/profile';
  static const String changePassword = '/auth/change-password';

  static const String salaryCategories = '/salary-categories';
  static const String employees        = '/employees';
  static const String payrollPeriods   = '/payroll-periods';
  static const String salarySlips      = '/salary-slips';
  static const String bulkGenerate     = '/salary-slips/bulk-generate';
  static const String bulkGeneratePdf  = '/salary-slips/bulk-generate-pdf';

  // Email — tambahkan baris ini
  static const String emailSend     = '/email/send';
  static const String emailResend   = '/email/resend';
  static const String emailSendBulk = '/email/send-bulk';
  static const String emailHistory  = '/email/history';

  static const String dashboardOwner  = '/dashboard/owner';
  static const String dashboardHead   = '/dashboard/head';
  static const String dashboardAdmin  = '/dashboard/admin';

  static const String salarySummary    = '/reports/salary-summary';
  static const String reportStatistics = '/reports/statistics';
  static const String activityLogs     = '/activity-logs';
}