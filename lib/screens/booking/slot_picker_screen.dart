import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/utils/date_utils.dart';
import '../../providers/professional_provider.dart';
import '../../theme/app_colors.dart';

class SlotPickerScreen extends StatefulWidget {
  final String proId;
  final String serviceId;
  const SlotPickerScreen(
      {super.key, required this.proId, required this.serviceId});

  @override
  State<SlotPickerScreen> createState() => _SlotPickerScreenState();
}

class _SlotPickerScreenState extends State<SlotPickerScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSlots(_selectedDay);
  }

  void _loadSlots(DateTime day) {
    context.read<ProfessionalProvider>().loadSlots(
          proId: widget.proId,
          serviceId: widget.serviceId,
          date: day,
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfessionalProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Choisir un créneau')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now(),
            lastDay: DateTime.now().add(const Duration(days: 90)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
              _loadSlots(selected);
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(formatButtonVisible: false),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              AppDateUtils.formatRelative(_selectedDay),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          Expanded(
            child: provider.loading
                ? const Center(child: CircularProgressIndicator())
                : provider.slots.isEmpty
                    ? const Center(
                        child: Text('Aucun créneau disponible ce jour'))
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.2,
                        ),
                        itemCount: provider.slots.length,
                        itemBuilder: (_, i) {
                          final slot = provider.slots[i];
                          final available = slot.isAvailable;
                          return GestureDetector(
                            onTap: available
                                ? () => context.push(
                                      '/booking/${widget.proId}/confirm'
                                      '?serviceId=${widget.serviceId}'
                                      '&slotId=${slot.id}',
                                    )
                                : null,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: available
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : AppColors.border,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: available
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(
                                AppDateUtils.formatTime(slot.startTime),
                                style: TextStyle(
                                  color: available
                                      ? AppColors.primary
                                      : AppColors.textHint,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
