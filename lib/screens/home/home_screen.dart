import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../explore/explore_screen.dart';
import '../appointments/appointments_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/agenda_screen.dart';
import '../dashboard/services_screen.dart';
import '../dashboard/availability_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isPro;
  const HomeScreen({super.key, this.isPro = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  List<Widget> get _clientScreens => const [
        ExploreScreen(),
        AppointmentsScreen(),
        ProfileScreen(),
      ];

  List<Widget> get _proScreens => [
        const DashboardScreen(),
        const AgendaScreen(),
        const ServicesScreen(),
        const AvailabilityScreen(),
        const ProfileScreen(),
      ];

  List<BottomNavigationBarItem> get _clientItems => const [
        BottomNavigationBarItem(
            icon: Icon(Icons.search), label: 'Explorer'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined), label: 'RDV'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Profil'),
      ];

  List<BottomNavigationBarItem> get _proItems => const [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
        BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined), label: 'Agenda'),
        BottomNavigationBarItem(
            icon: Icon(Icons.design_services_outlined), label: 'Services'),
        BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined), label: 'Disponibilités'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Profil'),
      ];

  @override
  Widget build(BuildContext context) {
    final isPro =
        widget.isPro || context.watch<AuthProvider>().isProfessional;
    final screens = isPro ? _proScreens : _clientScreens;
    final items = isPro ? _proItems : _clientItems;

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: items,
      ),
    );
  }
}
