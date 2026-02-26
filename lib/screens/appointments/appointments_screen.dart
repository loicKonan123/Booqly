import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/utils/date_utils.dart';
import '../../models/appointment.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    // Fix: évite setState pendant le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final isPro = context.read<AuthProvider>().isProfessional;
        context.read<AppointmentProvider>().loadMyAppointments(isProfessional: isPro);
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppointmentProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverToBoxAdapter(
            child: _AppointmentsHeader(tabs: _tabs),
          ),
        ],
        body: provider.loading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabs,
                children: [
                  _AppointmentList(
                    appointments: provider.upcoming,
                    emptyMsg: 'Aucun rendez-vous à venir',
                    emptyIcon: Icons.calendar_today_outlined,
                    isDark: isDark,
                  ),
                  _AppointmentList(
                    appointments: provider.past,
                    emptyMsg: 'Aucun rendez-vous passé',
                    emptyIcon: Icons.history_rounded,
                    isDark: isDark,
                  ),
                ],
              ),
      ),
    );
  }
}

// ── Header gradient + TabBar ───────────────────────────────────────────────────

class _AppointmentsHeader extends StatelessWidget {
  final TabController tabs;
  const _AppointmentsHeader({required this.tabs});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mes rendez-vous',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gérez vos réservations facilement',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // TabBar intégré dans le header
            TabBar(
              controller: tabs,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: isDark ? Colors.white : AppColors.primary,
              unselectedLabelColor: isDark
                  ? Colors.white.withValues(alpha: 0.55)
                  : AppColors.textSecondary,
              labelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 14),
              unselectedLabelStyle:
                  GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 14),
              tabs: const [
                Tab(text: 'À venir'),
                Tab(text: 'Passés'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Liste de rendez-vous ───────────────────────────────────────────────────────

class _AppointmentList extends StatelessWidget {
  final List<Appointment> appointments;
  final String emptyMsg;
  final IconData emptyIcon;
  final bool isDark;

  const _AppointmentList({
    required this.appointments,
    required this.emptyMsg,
    required this.emptyIcon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return _EmptyState(message: emptyMsg, icon: emptyIcon);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: appointments.length,
      itemBuilder: (_, i) =>
          _AppointmentCard(appointment: appointments[i], isDark: isDark),
    );
  }
}

// ── Carte rendez-vous ─────────────────────────────────────────────────────────

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool isDark;

  const _AppointmentCard({required this.appointment, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    final statusColor = AppColors.statusColor(a.status);
    final initial = a.professional.fullName.isNotEmpty
        ? a.professional.fullName[0].toUpperCase()
        : '?';

    return GestureDetector(
      onTap: () => context.push('/appointments/${a.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : AppColors.primary)
                  .withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar gradient
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.brandGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.professional.fullName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      a.service.name,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppDateUtils.formatDateTime(a.startTime),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Badge statut
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(a.status),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(String s) {
    switch (s.toLowerCase()) {
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

// ── État vide ─────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const _EmptyState({required this.message, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Vos réservations apparaîtront ici',
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}
