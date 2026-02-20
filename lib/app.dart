import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/constants/api_constants.dart';
import 'core/mock/mock_data.dart';
import 'providers/auth_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/professional_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/theme_provider.dart';
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
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'widgets/booqly_logo.dart';

class AppointEaseApp extends StatefulWidget {
  const AppointEaseApp({super.key});

  @override
  State<AppointEaseApp> createState() => _AppointEaseAppState();
}

class _AppointEaseAppState extends State<AppointEaseApp> {
  late final AuthProvider _auth;
  late final GoRouter _router;

  // Notifie le router quand la durée minimale du splash est écoulée
  final _splashNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _auth = AuthProvider();
    _router = _buildRouter();
    Future.delayed(const Duration(milliseconds: 2600), () {
      _splashNotifier.value = true;
    });
  }

  @override
  void dispose() {
    _auth.dispose();
    _splashNotifier.dispose();
    super.dispose();
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/',
      // Router se re-évalue quand auth change OU quand le splash est terminé
      refreshListenable: Listenable.merge([_auth, _splashNotifier]),
      redirect: (context, state) {
        if (kMockMode) return null;

        // Attendre Hive + durée minimale du splash
        if (!_auth.initialized || !_splashNotifier.value) return null;

        final isLoggedIn = _auth.isAuthenticated;
        final loc = state.matchedLocation;
        final isOnAuth = loc == '/login' ||
            loc == '/register' ||
            loc == '/role-select';

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
        ChangeNotifierProvider<AuthProvider>.value(value: _auth),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => ProfessionalProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, themeProvider, __) => MaterialApp.router(
          title: ApiConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.mode,
          routerConfig: _router,
        ),
      ),
    );
  }
}

// ── Splash screen ──────────────────────────────────────────────────────────────

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _taglineFade;
  late final Animation<double> _spinnerFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    // Logo : scale elastique + fade rapide
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
      ),
    );
    _logoOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
    );

    // Titre "Booqly"
    _textFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.30, 0.60, curve: Curves.easeOut),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.30, 0.62, curve: Curves.easeOutCubic),
    ));

    // Tagline
    _taglineFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.50, 0.80, curve: Curves.easeOut),
    );

    // Spinner
    _spinnerFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: [
            // ── Cercles déco ────────────────────────────────────────────
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryGlow.withValues(alpha: 0.12),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent.withValues(alpha: 0.10),
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.35,
              left: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryLight.withValues(alpha: 0.06),
                ),
              ),
            ),

            // ── Contenu centré ──────────────────────────────────────────
            SafeArea(
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (context, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),

                      // Logo
                      Opacity(
                        opacity: _logoOpacity.value.clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: const BooqlyLogo(size: 116, animate: false),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // "Booqly"
                      Opacity(
                        opacity: _textFade.value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, _textSlide.value.dy * 40),
                          child: Text(
                            'Booqly',
                            style: GoogleFonts.poppins(
                              fontSize: 42,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -1.0,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Tagline
                      Opacity(
                        opacity: _taglineFade.value.clamp(0.0, 1.0),
                        child: Text(
                          'Vos rendez-vous, simplifiés',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.60),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Spinner de chargement
                      Opacity(
                        opacity: _spinnerFade.value.clamp(0.0, 1.0),
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white.withValues(alpha: 0.45),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
