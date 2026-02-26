class ApiConstants {
  ApiConstants._();

  static const String appName = 'AppointEase';
  // ── Changer selon l'environnement ────────────────────────────────────────────
  // Émulateur Android   → http://10.0.2.2:5000/api
  // Simulateur iOS/Web  → http://localhost:5000/api
  // Téléphone physique  → http://<TON_IP_WIFI>:5000/api  (ex: 192.168.2.32)
  // Production          → https://api.booqly.com/api
  // ─────────────────────────────────────────────────────────────────────────────
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://192.168.2.32:5000/api',
  );

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';

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
