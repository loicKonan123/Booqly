import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_utils.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppointmentProvider>().loadMyAppointments();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final appointments = context.watch<AppointmentProvider>();

    final upcoming = appointments.upcoming;
    final todayRdv = upcoming
        .where((a) =>
            a.startTime.year == DateTime.now().year &&
            a.startTime.month == DateTime.now().month &&
            a.startTime.day == DateTime.now().day)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Bonjour, ${auth.user?.firstName ?? ''}'),
        automaticallyImplyLeading: false,
      ),
      body: appointments.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () =>
                  context.read<AppointmentProvider>().loadMyAppointments(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _StatsRow(
                    todayCount: todayRdv.length,
                    upcomingCount: upcoming.length,
                    totalCount: appointments.all.length,
                  ),
                  const SizedBox(height: 24),
                  if (todayRdv.isNotEmpty) ...[
                    const Text("Aujourd'hui",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    ...todayRdv.map((a) => _DashboardCard(appointment: a)),
                    const SizedBox(height: 24),
                  ],
                  const Text('À venir',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  if (upcoming.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text('Aucun rendez-vous à venir')),
                    )
                  else
                    ...upcoming.take(5).map((a) => _DashboardCard(appointment: a)),
                ],
              ),
            ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int todayCount;
  final int upcomingCount;
  final int totalCount;
  const _StatsRow(
      {required this.todayCount,
      required this.upcomingCount,
      required this.totalCount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: _StatCard(
                label: "Aujourd'hui", value: '$todayCount', icon: Icons.today)),
        const SizedBox(width: 12),
        Expanded(
            child: _StatCard(
                label: 'À venir',
                value: '$upcomingCount',
                icon: Icons.upcoming_outlined)),
        const SizedBox(width: 12),
        Expanded(
            child: _StatCard(
                label: 'Total',
                value: '$totalCount',
                icon: Icons.bar_chart_rounded)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatCard(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final dynamic appointment;
  const _DashboardCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            a.clientName.isNotEmpty ? a.clientName[0].toUpperCase() : '?',
            style: const TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(a.clientName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${a.service.name} · ${AppDateUtils.formatTime(a.startTime)}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        trailing: _StatusDot(status: a.status),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final String status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.statusColor(status),
      ),
    );
  }
}
