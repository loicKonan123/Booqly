import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../core/constants/api_constants.dart';
import '../../theme/app_colors.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Box _box;

  // Keys
  static const _keyReminders = 'notif_reminders';
  static const _keyConfirmations = 'notif_confirmations';
  static const _keyCancellations = 'notif_cancellations';
  static const _keyMarketing = 'notif_marketing';

  bool _reminders = true;
  bool _confirmations = true;
  bool _cancellations = true;
  bool _marketing = false;

  @override
  void initState() {
    super.initState();
    _box = Hive.box(ApiConstants.cacheBox);
    _reminders = _box.get(_keyReminders, defaultValue: true) as bool;
    _confirmations = _box.get(_keyConfirmations, defaultValue: true) as bool;
    _cancellations = _box.get(_keyCancellations, defaultValue: true) as bool;
    _marketing = _box.get(_keyMarketing, defaultValue: false) as bool;
  }

  Future<void> _toggle(String key, bool value) async {
    await _box.put(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionHeader(title: 'Rendez-vous'),
          Card(
            child: Column(
              children: [
                _NotifTile(
                  icon: Icons.alarm_outlined,
                  title: 'Rappels de RDV',
                  subtitle: '24h avant chaque rendez-vous',
                  value: _reminders,
                  onChanged: (v) {
                    setState(() => _reminders = v);
                    _toggle(_keyReminders, v);
                  },
                ),
                const Divider(height: 1, indent: 56),
                _NotifTile(
                  icon: Icons.check_circle_outline,
                  title: 'Confirmations',
                  subtitle: 'Quand un RDV est confirmé',
                  value: _confirmations,
                  onChanged: (v) {
                    setState(() => _confirmations = v);
                    _toggle(_keyConfirmations, v);
                  },
                ),
                const Divider(height: 1, indent: 56),
                _NotifTile(
                  icon: Icons.cancel_outlined,
                  title: 'Annulations',
                  subtitle: 'Quand un RDV est annulé',
                  value: _cancellations,
                  onChanged: (v) {
                    setState(() => _cancellations = v);
                    _toggle(_keyCancellations, v);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SectionHeader(title: 'Général'),
          Card(
            child: _NotifTile(
              icon: Icons.campaign_outlined,
              title: 'Nouveautés & offres',
              subtitle: 'Informations sur l\'application',
              value: _marketing,
              onChanged: (v) {
                setState(() => _marketing = v);
                _toggle(_keyMarketing, v);
              },
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: AppColors.textSecondary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Les rappels SMS sont gérés côté serveur et s\'envoient indépendamment de ces réglages.',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary)),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }
}
