class ApiConstants {
  ApiConstants._();

  static const String appName = 'AppointEase';
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android emulator
  // static const String baseUrl = 'http://localhost:5000/api'; // Web / iOS simulator

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';

  // Professionals
  static const String professionals = '/professionals';
  static String professionalById(String id) => '/professionals/$id';
  static String professionalSlots(String id) => '/professionals/$id/slots';

  // Services
  static String services(String proId) => '/professionals/$proId/services';
  static String serviceById(String proId, String serviceId) =>
      '/professionals/$proId/services/$serviceId';

  // Availabilities
  static String availabilities(String proId) =>
      '/professionals/$proId/availabilities';
  static String availabilityById(String proId, String availId) =>
      '/professionals/$proId/availabilities/$availId';

  // Appointments
  static const String appointments = '/appointments';
  static const String myAppointments = '/appointments/mine';
  static String appointmentStatus(String id) => '/appointments/$id/status';

  // Profile
  static const String profile = '/profile';
  static const String changePassword = '/profile/password';

  // Dashboard
  static const String dashboardStats = '/dashboard/stats';

  // Hive box keys
  static const String authBox = 'auth';
  static const String cacheBox = 'cache';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user';
}
