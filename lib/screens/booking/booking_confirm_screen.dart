import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_utils.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/professional_provider.dart';
import '../../theme/app_colors.dart';

class BookingConfirmScreen extends StatefulWidget {
  final String proId;
  final String serviceId;
  final String slotId;

  const BookingConfirmScreen({
    super.key,
    required this.proId,
    required this.serviceId,
    required this.slotId,
  });

  @override
  State<BookingConfirmScreen> createState() => _BookingConfirmScreenState();
}

class _BookingConfirmScreenState extends State<BookingConfirmScreen> {
  bool _loading = false;

  Future<void> _confirm() async {
    setState(() => _loading = true);
    final appointment = await context.read<AppointmentProvider>().book(
          professionalId: widget.proId,
          serviceId: widget.serviceId,
          slotId: widget.slotId,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (appointment != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rendez-vous confirmé !'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la réservation'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final proProvider = context.watch<ProfessionalProvider>();
    final pro = proProvider.selected;
    final service = proProvider.services
        .where((s) => s.id == widget.serviceId)
        .firstOrNull;
    final slot = proProvider.slots
        .where((s) => s.id == widget.slotId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmer la réservation')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoCard(
              icon: Icons.person_outline,
              label: 'Professionnel',
              value: pro?.fullName ?? '—',
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.design_services_outlined,
              label: 'Service',
              value: service != null
                  ? '${service.name} — ${service.formattedDuration}'
                  : '—',
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.calendar_today_outlined,
              label: 'Date et heure',
              value: slot != null
                  ? AppDateUtils.formatDateTime(slot.startTime)
                  : '—',
            ),
            const SizedBox(height: 12),
            _InfoCard(
              icon: Icons.euro_outlined,
              label: 'Prix',
              value: service?.formattedPrice ?? '—',
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _loading ? null : _confirm,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Confirmer le rendez-vous'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtitleColor =
        isDark ? Colors.white54 : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: subtitleColor, fontSize: 12)),
              Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: textColor)),
            ],
          ),
        ],
      ),
    );
  }
}
