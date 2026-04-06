class AppConstants {
  // Use 10.0.2.2 for Android Emulator to connect to localhost.
  // Changed from 0.0.0.0 to your actual local Wi-Fi IP address
  // for testing on a physical device over the local network.
  static const String baseUrl = 'http://10.123.216.165:5000/api';

  static const String tokenKey = 'jwt_token';
  static const String userKey = 'user_data';
  static const String roleKey = 'user_role';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String profileEndpoint = '/auth/me';

  static const String issuesCreateEndpoint = '/issue/create';
  static const String issuesAllEndpoint = '/issue/all';
  static const String issuesMyEndpoint = '/issue/my-issues';
  static const String issuesUpdateStatusEndpoint = '/issue/update-status';
  static const String issuesAssignEndpoint = '/issue/assign';

  // Admin Endpoints
  static const String adminContractorsEndpoint = '/admin/contractors';
}
