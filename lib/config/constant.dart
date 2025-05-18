class AppConstants {
  // App general constants
  static const String appName = 'Toru Inventory';
  static const String appVersion = '1.0.0';

  // API related constants
  static const String baseUrl = 'https://pos.torufarm.com';
  static const int apiTimeout = 30; // in seconds

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';

  // Route names
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String inventoryRoute = '/inventory';

  // Asset paths
  static const String imagePath = 'assets/images';
  static const String iconPath = 'assets/icons';

  // Default values
  static const int defaultPageSize = 10;
  static const String defaultDateFormat = 'yyyy-MM-dd';
  static const String defaultTimeFormat = 'HH:mm';

  // Error messages
  static const String defaultErrorMessage = 'Something went wrong';
  static const String networkErrorMessage = 'Network connection error';
}
