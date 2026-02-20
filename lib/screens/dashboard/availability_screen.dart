import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/professional_service.dart';
import '../../theme/app_colors.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  final _service = ProfessionalService();

  static const _days = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
  ];

  // dayOfWeek (1=Mon…7=Sun) -> {isActive, start, end}
  final Map<int, _DayConfig> _config = {
    for (int i = 1; i <= 7; i++)
      i: _DayConfig(
        isActive: i <= 5,
        start: const TimeOfDay(hour: 9, minute: 0),
        end: const TimeOfDay(hour: 18, minute: 0),
      ),
  };

  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final proId = context.read<AuthProvider>().user?.professionalId ?? '';
      final body = _config.entries
          .where((e) => e.value.isActive)
          .map((e) => {
                // Flutter: 1=Lun…6=Sam, 7=Dim → C# DayOfWeek: 0=Sun, 1=Mon…6=Sat
                'dayOfWeek': e.key == 7 ? 0 : e.key,
                'startTime': _fmt(e.value.start),
                'endTime': _fmt(e.value.end),
              })
          .toList();
      await _service.setAvailabilities(proId, body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Disponibilités enregistrées')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(int day, bool isStart) async {
    final config = _config[day]!;
    final initial = isStart ? config.start : config.end;
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) {
      setState(() {
        _config[day] = isStart
            ? config.copyWith(start: picked)
            : config.copyWith(end: picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes disponibilités'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enregistrer'),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final day = i + 1;
          final config = _config[day]!;
          return Card(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Switch(
                        value: config.isActive,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(
                            () => _config[day] = config.copyWith(isActive: v)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _days[i],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: config.isActive
                              ? null
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (config.isActive) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _TimeButton(
                            label: 'Début',
                            time: config.start,
                            onTap: () => _pickTime(day, true),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('→',
                              style: TextStyle(color: AppColors.textSecondary)),
                        ),
                        Expanded(
                          child: _TimeButton(
                            label: 'Fin',
                            time: config.end,
                            onTap: () => _pickTime(day, false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DayConfig {
  final bool isActive;
  final TimeOfDay start;
  final TimeOfDay end;

  const _DayConfig(
      {required this.isActive, required this.start, required this.end});

  _DayConfig copyWith({bool? isActive, TimeOfDay? start, TimeOfDay? end}) =>
      _DayConfig(
        isActive: isActive ?? this.isActive,
        start: start ?? this.start,
        end: end ?? this.end,
      );
}

class _TimeButton extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  const _TimeButton(
      {required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 2),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
