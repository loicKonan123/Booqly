import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/booqly_logo.dart';
import '../../widgets/glass_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  late final AnimationController _entryCtrl;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _cardFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      context.go(auth.isProfessional ? '/dashboard' : '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Erreur de connexion'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          // ── Fond dégradé violet ─────────────────────────────────────────
          Container(
            width: size.width,
            height: size.height,
            decoration: const BoxDecoration(
              gradient: AppColors.splashGradient,
            ),
          ),

          // ── Cercle déco haut-droit ──────────────────────────────────────
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGlow.withValues(alpha: 0.18),
              ),
            ),
          ),

          // ── Cercle déco bas-gauche ──────────────────────────────────────
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.14),
              ),
            ),
          ),

          // ── Contenu principal ───────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: (size.height * 0.055).clamp(20.0, 52.0)),

                  // Logo animé
                  BooqlyLogo(size: (size.height * 0.11).clamp(60.0, 90.0)),
                  SizedBox(height: (size.height * 0.015).clamp(8.0, 16.0)),

                  // Nom de l'app
                  Text(
                    'Booqly',
                    style: GoogleFonts.poppins(
                      fontSize: size.height < 700 ? 26 : 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vos rendez-vous, simplifiés',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.65),
                    ),
                  ),

                  SizedBox(height: (size.height * 0.04).clamp(20.0, 48.0)),

                  // ── Carte glassmorphism ─────────────────────────────────
                  FadeTransition(
                    opacity: _cardFade,
                    child: SlideTransition(
                      position: _cardSlide,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                                width: 1.5,
                              ),
                            ),
                            padding: const EdgeInsets.all(28),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Connexion',
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Bienvenue ! Connectez-vous pour continuer.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color:
                                          Colors.white.withValues(alpha: 0.65),
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // Email
                                  GlassField(
                                    controller: _emailCtrl,
                                    hint: 'Email',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: AppValidators.email,
                                  ),
                                  const SizedBox(height: 16),

                                  // Mot de passe
                                  GlassField(
                                    controller: _passCtrl,
                                    hint: 'Mot de passe',
                                    icon: Icons.lock_outline,
                                    obscure: _obscure,
                                    validator: AppValidators.password,
                                    suffix: IconButton(
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Colors.white60,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          setState(() => _obscure = !_obscure),
                                    ),
                                  ),

                                  // Mot de passe oublié
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () =>
                                          context.push('/forgot-password'),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        'Mot de passe oublié ?',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.white
                                              .withValues(alpha: 0.75),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Bouton connexion
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppColors.primaryDark,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        elevation: 0,
                                      ),
                                      onPressed: loading ? null : _submit,
                                      child: loading
                                          ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primary,
                                              ),
                                            )
                                          : Text(
                                              'Se connecter',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: (size.height * 0.02).clamp(12.0, 24.0)),

                  // Lien inscription
                  FadeTransition(
                    opacity: _cardFade,
                    child: TextButton(
                      onPressed: () => context.push('/register'),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.70),
                          ),
                          children: [
                            const TextSpan(text: "Pas encore de compte ? "),
                            TextSpan(
                              text: "S'inscrire",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: (size.height * 0.03).clamp(16.0, 40.0)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
