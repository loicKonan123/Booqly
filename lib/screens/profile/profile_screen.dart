import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Header gradient ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _ProfileHeader(
              user: user,
              isProfessional: auth.isProfessional,
            ),
          ),

          // ── Corps ────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Section Compte
                _Section(
                  title: 'Compte',
                  isDark: isDark,
                  items: [
                    _MenuItem(
                      icon: Icons.person_outline,
                      label: 'Informations personnelles',
                      onTap: () => context.push('/profile/edit'),
                    ),
                    _MenuDivider(isDark: isDark),
                    _MenuItem(
                      icon: Icons.lock_outline,
                      label: 'Changer le mot de passe',
                      onTap: () => context.push('/profile/password'),
                    ),
                    _MenuDivider(isDark: isDark),
                    _MenuItem(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      onTap: () => context.push('/profile/notifications'),
                    ),
                  ],
                ),

                if (auth.isProfessional) ...[
                  const SizedBox(height: 16),
                  _Section(
                    title: 'Espace professionnel',
                    isDark: isDark,
                    items: [
                      _MenuItem(
                        icon: Icons.store_outlined,
                        label: 'Mon profil professionnel',
                        onTap: () => context.push('/profile/pro'),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 16),

                // Section Application
                _Section(
                  title: 'Application',
                  isDark: isDark,
                  items: [
                    const _ThemeToggleTile(),
                    _MenuDivider(isDark: isDark),
                    _MenuItem(
                      icon: Icons.help_outline,
                      label: 'Aide & Support',
                      onTap: () => context.push('/profile/help'),
                    ),
                    _MenuDivider(isDark: isDark),
                    _MenuItem(
                      icon: Icons.info_outline,
                      label: 'À propos',
                      onTap: () => _showAbout(context),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bouton déconnexion
                _LogoutButton(
                  isDark: isDark,
                  onTap: () => _logout(context, auth),
                ),

                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Booqly v1.0.0',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.calendar_month, color: AppColors.primary),
            const SizedBox(width: 10),
            Text('Booqly',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Text(
              'Booqly est une plateforme de prise de rendez-vous en ligne connectant clients et professionnels.',
              style: GoogleFonts.poppins(
                  color: AppColors.textSecondary, height: 1.5, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Text('Développé avec Flutter & ASP.NET Core 8',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text('© 2026 Booqly. Tous droits réservés.',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Fermer',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, AuthProvider auth) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Se déconnecter ?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('Voulez-vous vraiment vous déconnecter ?',
            style: GoogleFonts.poppins(
                color: AppColors.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Annuler',
                style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Déconnexion',
                style: GoogleFonts.poppins(
                    color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await auth.logout();
      if (context.mounted) context.go('/login');
    }
  }
}

// ── Header gradient avec avatar ───────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final dynamic user;
  final bool isProfessional;

  const _ProfileHeader({required this.user, required this.isProfessional});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initial = user?.firstName?.isNotEmpty == true
        ? (user!.firstName as String)[0].toUpperCase()
        : '?';
    final titleColor = isDark ? Colors.white : AppColors.headerTitle;
    final subtitleColor =
        isDark ? Colors.white.withValues(alpha: 0.72) : AppColors.headerSubtitle;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? AppColors.softHeaderGradientDark
            : AppColors.softHeaderGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            children: [
              // Avatar avec gradient violet fort
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  gradient: AppColors.brandGradient,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Nom complet
              Text(
                user?.fullName ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),

              const SizedBox(height: 4),

              // Email
              Text(
                user?.email ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: subtitleColor,
                ),
              ),

              const SizedBox(height: 12),

              // Badge rôle
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: Text(
                  isProfessional ? 'Professionnel' : 'Client',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section avec carte ─────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> items;
  final bool isDark;

  const _Section(
      {required this.title, required this.items, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : AppColors.primary)
                    .withValues(alpha: isDark ? 0.12 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _MenuDivider extends StatelessWidget {
  final bool isDark;
  const _MenuDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 56,
      color: isDark ? AppColors.borderDark : AppColors.border,
    );
  }
}

// ── Menu item ─────────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 18),
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textSecondary, size: 20),
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

// ── Toggle thème ──────────────────────────────────────────────────────────────

class _ThemeToggleTile extends StatelessWidget {
  const _ThemeToggleTile();

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final isDark = theme.isDark ||
        (theme.isSystem &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            key: ValueKey(isDark),
            color: AppColors.primary,
            size: 18,
          ),
        ),
      ),
      title: Text(
        'Thème',
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: Switch(
        value: isDark,
        onChanged: (_) => theme.toggle(),
        activeColor: AppColors.primary,
      ),
      onTap: () => theme.toggle(),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

// ── Bouton déconnexion ────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _LogoutButton({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.20)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: AppColors.error, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              'Se déconnecter',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
