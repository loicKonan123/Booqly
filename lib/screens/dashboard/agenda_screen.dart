import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/utils/date_utils.dart';
import '../../models/appointment.dart';
import '../../providers/appointment_provider.dart';
import '../../theme/app_colors.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<AppointmentProvider>().loadMyAppointments();
  }

  List<Appointment> _appointmentsForDay(
      List<Appointment> all, DateTime day) {
    return all.where((a) => isSameDay(a.startTime, day)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();
    final dayAppointments =
        _appointmentsForDay(provider.all, _selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          TableCalendar<Appointment>(
            locale: 'fr_FR',
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
            eventLoader: (day) => _appointmentsForDay(provider.all, day),
            calendarStyle: CalendarStyle(
              markerDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            onPageChanged: (focused) {
              _focusedDay = focused;
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : dayAppointments.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun RDV le ${AppDateUtils.formatDate(_selectedDay)}',
                          style: const TextStyle(
                              color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: dayAppointments.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) =>
                            _AgendaCard(appointment: dayAppointments[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

class _AgendaCard extends StatelessWidget {
  final Appointment appointment;
  const _AgendaCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final color = AppColors.statusColor(a.status);
    return InkWell(
      onTap: () => context.push('/appointments/${a.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 80,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${AppDateUtils.formatTime(a.startTime)} – ${AppDateUtils.formatTime(a.endTime)}',
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                        _StatusBadge(status: a.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(a.clientName,
                        style:
                            const TextStyle(fontWeight: FontWeight.w600)),
                    Text(a.service.name,
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label(status),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
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
