class AppConstants {
  // App Info
  static const String appName    = 'Remunerasi Restoran';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String tokenKey    = 'auth_token';
  static const String userKey     = 'user_data';
  static const String roleKey     = 'user_role';

  // Roles
  static const String roleOwner = 'owner';
  static const String roleHead  = 'head';
  static const String roleAdmin = 'admin';

  // Pagination
  static const int defaultPerPage = 20;

  // Timeout
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}