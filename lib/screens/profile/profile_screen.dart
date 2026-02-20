import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: Text(
                    user?.firstName.isNotEmpty == true
                        ? user!.firstName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.fullName ?? '',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                _RoleBadge(isProfessional: auth.isProfessional),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _Section(
            title: 'Compte',
            items: [
              _MenuItem(
                icon: Icons.person_outline,
                label: 'Informations personnelles',
                onTap: () => context.push('/profile/edit'),
              ),
              _MenuItem(
                icon: Icons.lock_outline,
                label: 'Changer le mot de passe',
                onTap: () => context.push('/profile/password'),
              ),
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
          _Section(
            title: 'Application',
            items: [
              _MenuItem(
                icon: Icons.help_outline,
                label: 'Aide & Support',
                onTap: () => context.push('/profile/help'),
              ),
              _MenuItem(
                icon: Icons.info_outline,
                label: 'À propos',
                onTap: () => _showAbout(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('Se déconnecter',
                  style: TextStyle(color: AppColors.error)),
              onTap: () => _logout(context, auth),
            ),
          ),
          const SizedBox(height: 32),
          const Center(
            child: Text(
              'Booqly v1.0.0',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
        title: const Row(
          children: [
            Icon(Icons.calendar_month, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Booqly'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0',
                style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 10),
            Text(
              'Booqly est une plateforme de prise de rendez-vous en ligne connectant clients et professionnels.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            SizedBox(height: 14),
            Text('Développé avec Flutter & ASP.NET Core 8',
                style:
                    TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            SizedBox(height: 4),
            Text('© 2026 Booqly. Tous droits réservés.',
                style:
                    TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context, AuthProvider auth) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Déconnexion',
                style: TextStyle(color: AppColors.error)),
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

class _RoleBadge extends StatelessWidget {
  final bool isProfessional;
  const _RoleBadge({required this.isProfessional});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isProfessional
            ? AppColors.secondary.withValues(alpha: 0.15)
            : AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isProfessional ? 'Professionnel' : 'Client',
        style: TextStyle(
          color: isProfessional ? AppColors.secondary : AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary),
          ),
        ),
        Card(
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing:
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
