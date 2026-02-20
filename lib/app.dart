import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/constants/api_constants.dart';
import 'core/mock/mock_data.dart';
import 'providers/auth_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/professional_provider.dart';
import 'providers/profile_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/role_select_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/explore/professional_detail_screen.dart';
import 'screens/booking/service_select_screen.dart';
import 'screens/booking/slot_picker_screen.dart';
import 'screens/booking/booking_confirm_screen.dart';
import 'screens/appointments/appointment_detail_screen.dart';
import 'screens/dashboard/agenda_screen.dart';
import 'screens/dashboard/services_screen.dart';
import 'screens/dashboard/availability_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/profile/change_password_screen.dart';
import 'screens/profile/notifications_screen.dart';
import 'screens/profile/edit_pro_profile_screen.dart';
import 'screens/profile/help_screen.dart';
import 'theme/app_theme.dart';

class AppointEaseApp extends StatefulWidget {
  const AppointEaseApp({super.key});

  @override
  State<AppointEaseApp> createState() => _AppointEaseAppState();
}

class _AppointEaseAppState extends State<AppointEaseApp> {
  // Créé une seule fois — stable pour toute la durée de vie de l'app
  late final AuthProvider _auth;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _auth = AuthProvider();
    _router = _buildRouter();
  }

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/',
      // Re-évalue le redirect à chaque changement d'état auth
      refreshListenable: _auth,
      redirect: (context, state) {
        if (kMockMode) return null;

        // Pendant le chargement initial depuis Hive → rester sur le splash
        if (!_auth.initialized) return null;

        final isLoggedIn = _auth.isAuthenticated;
        final loc = state.matchedLocation;
        final isOnAuth = loc == '/login' ||
            loc == '/register' ||
            loc == '/role-select';

        // Depuis le splash, rediriger selon l'état auth
        if (loc == '/') {
          return isLoggedIn
              ? (_auth.isProfessional ? '/dashboard' : '/home')
              : '/login';
        }

        if (!isLoggedIn && !isOnAuth) return '/login';
        if (isLoggedIn && isOnAuth) {
          return _auth.isProfessional ? '/dashboard' : '/home';
        }
        return null;
      },
      routes: [
        // Splash — affiché pendant le chargement Hive
        GoRoute(
          path: '/',
          builder: (_, __) => const _SplashScreen(),
        ),

        // Auth
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(
            path: '/role-select', builder: (_, __) => const RoleSelectScreen()),

        // Client
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/professional/:id',
          builder: (_, state) =>
              ProfessionalDetailScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/booking/:proId',
          builder: (_, state) =>
              ServiceSelectScreen(proId: state.pathParameters['proId']!),
        ),
        GoRoute(
          path: '/booking/:proId/slots',
          builder: (_, state) => SlotPickerScreen(
            proId: state.pathParameters['proId']!,
            serviceId: state.uri.queryParameters['serviceId'] ?? '',
          ),
        ),
        GoRoute(
          path: '/booking/:proId/confirm',
          builder: (_, state) => BookingConfirmScreen(
            proId: state.pathParameters['proId']!,
            serviceId: state.uri.queryParameters['serviceId'] ?? '',
            slotId: state.uri.queryParameters['slotId'] ?? '',
          ),
        ),
        GoRoute(
          path: '/appointments/:id',
          builder: (_, state) => AppointmentDetailScreen(
              appointmentId: state.pathParameters['id']!),
        ),

        // Professional
        GoRoute(
          path: '/dashboard',
          builder: (_, __) => const HomeScreen(isPro: true),
        ),
        GoRoute(path: '/agenda', builder: (_, __) => const AgendaScreen()),
        GoRoute(
            path: '/services', builder: (_, __) => const ServicesScreen()),
        GoRoute(
            path: '/availability',
            builder: (_, __) => const AvailabilityScreen()),

        // Profile sub-screens
        GoRoute(
            path: '/profile/edit',
            builder: (_, __) => const EditProfileScreen()),
        GoRoute(
            path: '/profile/password',
            builder: (_, __) => const ChangePasswordScreen()),
        GoRoute(
            path: '/profile/notifications',
            builder: (_, __) => const NotificationsScreen()),
        GoRoute(
            path: '/profile/help', builder: (_, __) => const HelpScreen()),
        GoRoute(
            path: '/profile/pro',
            builder: (_, __) => const EditProProfileScreen()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // _auth est passé par valeur — même instance que celle du router
        ChangeNotifierProvider<AuthProvider>.value(value: _auth),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => ProfessionalProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp.router(
        title: ApiConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}

/// Écran affiché pendant le chargement des tokens depuis Hive
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
