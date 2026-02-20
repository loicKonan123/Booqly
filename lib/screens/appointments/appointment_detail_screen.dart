import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_utils.dart';
import '../../models/appointment.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final String appointmentId;
  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();
    final appointment = provider.findById(appointmentId);

    if (appointment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détail rendez-vous')),
        body: const Center(child: Text('Rendez-vous introuvable')),
      );
    }

    final isPro = context.watch<AuthProvider>().isProfessional;

    return Scaffold(
      appBar: AppBar(title: const Text('Détail rendez-vous')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionCard(
              children: [
                // Pro sees client info; client sees professional info
                if (isPro) ...[
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Client',
                    value: appointment.clientName,
                  ),
                  if (appointment.clientPhone.isNotEmpty)
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Téléphone',
                      value: appointment.clientPhone,
                    ),
                ] else
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Professionnel',
                    value: appointment.professional.fullName,
                  ),
                _InfoRow(
                  icon: Icons.work_outline,
                  label: 'Service',
                  value: appointment.service.name,
                ),
                _InfoRow(
                  icon: Icons.attach_money,
                  label: 'Prix',
                  value: appointment.service.formattedPrice,
                ),
                _InfoRow(
                  icon: Icons.timer_outlined,
                  label: 'Durée',
                  value: appointment.service.formattedDuration,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              children: [
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Date',
                  value: AppDateUtils.formatDate(appointment.startTime),
                ),
                _InfoRow(
                  icon: Icons.access_time_outlined,
                  label: 'Heure',
                  value:
                      '${AppDateUtils.formatTime(appointment.startTime)} – ${AppDateUtils.formatTime(appointment.endTime)}',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _StatusSection(appointment: appointment),
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionCard(
                children: [
                  _InfoRow(
                    icon: Icons.notes_outlined,
                    label: 'Notes',
                    value: appointment.notes!,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            _ActionButtons(appointment: appointment, isPro: isPro),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(children: children),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusSection extends StatelessWidget {
  final Appointment appointment;
  const _StatusSection({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(appointment.status);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.circle, size: 10, color: color),
            const SizedBox(width: 10),
            Text('Statut',
                style: const TextStyle(color: AppColors.textSecondary)),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _label(appointment.status),
                style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _label(String s) {
    switch (s) {
      case 'pending':
        return 'En attente';
      case 'confirmed':
        return 'Confirmé';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return s;
    }
  }
}

class _ActionButtons extends StatelessWidget {
  final Appointment appointment;
  final bool isPro;
  const _ActionButtons({required this.appointment, required this.isPro});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppointmentProvider>();

    if (appointment.isCancelled || appointment.isCompleted) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isPro && appointment.isPending)
          ElevatedButton(
            onPressed: () => _confirm(context, provider),
            child: const Text('Confirmer le rendez-vous'),
          ),
        if (isPro && appointment.isConfirmed) ...[
          ElevatedButton(
            onPressed: () => _complete(context, provider),
            child: const Text('Marquer comme terminé'),
          ),
          const SizedBox(height: 8),
        ],
        if (appointment.isPending || (!isPro && appointment.isConfirmed))
          OutlinedButton(
            onPressed: () => _cancel(context, provider),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
            child: const Text('Annuler le rendez-vous'),
          ),
      ],
    );
  }

  Future<void> _confirm(
      BuildContext context, AppointmentProvider provider) async {
    await provider.confirm(appointment.id);
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _complete(
      BuildContext context, AppointmentProvider provider) async {
    await provider.complete(appointment.id);
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _cancel(
      BuildContext context, AppointmentProvider provider) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler le rendez-vous ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Non')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child:
                  const Text('Oui, annuler', style: TextStyle(color: AppColors.error))),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await provider.cancel(appointment.id);
      if (context.mounted) Navigator.of(context).pop();
    }
  }
}
