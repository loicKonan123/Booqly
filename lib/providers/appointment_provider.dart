import 'package:flutter/foundation.dart';

import '../core/mock/mock_data.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';
import '../services/notification_service.dart';

class AppointmentProvider extends ChangeNotifier {
  final _service = AppointmentService();
  final _notifications = NotificationService.instance;

  List<Appointment> _appointments = [];
  bool _loading = false;
  String? _error;

  List<Appointment> get appointments => _appointments;
  List<Appointment> get all => _appointments;
  bool get loading => _loading;
  String? get error => _error;

  Appointment? findById(String id) {
    try {
      return _appointments.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Appointment> get upcoming => _appointments
      .where((a) => !a.isCancelled && !a.isCompleted)
      .toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));

  List<Appointment> get past => _appointments
      .where((a) => a.isCancelled || a.isCompleted)
      .toList()
    ..sort((a, b) => b.startTime.compareTo(a.startTime));

  Future<void> loadMyAppointments() async {
    _setLoading(true);
    try {
      if (kMockMode) {
        await Future.delayed(const Duration(milliseconds: 300));
        _appointments = List.from(MockData.appointments);
        _error = null;
        return;
      }
      _appointments = await _service.getMyAppointments();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<Appointment?> book({
    required String professionalId,
    required String serviceId,
    required String slotId,
    String? notes,
  }) async {
    _setLoading(true);
    try {
      if (kMockMode) {
        await Future.delayed(const Duration(milliseconds: 400));
        final pro = MockData.professionals.firstWhere(
          (p) => p.id == professionalId,
          orElse: () => MockData.professionals.first,
        );
        final svc = MockData.services.firstWhere(
          (s) => s.id == serviceId,
          orElse: () => MockData.services.first,
        );
        final slot = MockData.timeSlots.firstWhere(
          (t) => t.id == slotId,
          orElse: () => MockData.timeSlots.first,
        );
        final appointment = Appointment(
          id: 'rdv-new-${DateTime.now().millisecondsSinceEpoch}',
          clientId: MockData.clientUser.id,
          clientName: '${MockData.clientUser.firstName} ${MockData.clientUser.lastName}',
          clientPhone: MockData.clientUser.phone ?? '',
          professional: pro,
          service: svc,
          startTime: slot.startTime,
          endTime: slot.endTime,
          status: 'confirmed',
          notes: notes,
        );
        _appointments.insert(0, appointment);
        _error = null;
        notifyListeners();
        return appointment;
      }
      final appointment = await _service.createAppointment(
        professionalId: professionalId,
        serviceId: serviceId,
        slotId: slotId,
        notes: notes,
      );
      _appointments.insert(0, appointment);

      // Local notification — erreur ignorée pour ne pas bloquer le succès
      try {
        await _notifications.showAppointmentConfirmed(
          clientName: appointment.clientName,
          dateTime: appointment.startTime,
          serviceName: appointment.service.name,
        );
        await _notifications.scheduleReminder(
          id: appointment.id.hashCode,
          clientName: appointment.clientName,
          appointmentTime: appointment.startTime,
          serviceName: appointment.service.name,
        );
      } catch (_) {
        // notification non critique
      }

      _error = null;
      notifyListeners();
      return appointment;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> cancel(String id) async {
    try {
      if (kMockMode) {
        _replaceStatus(id, 'cancelled');
        return true;
      }
      final updated = await _service.cancelAppointment(id);
      _replace(updated);
      await _notifications.cancelReminder(id.hashCode);
      await _notifications.showAppointmentCancelled(updated.service.name);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirm(String id) async {
    try {
      if (kMockMode) {
        _replaceStatus(id, 'confirmed');
        return true;
      }
      final updated = await _service.confirmAppointment(id);
      _replace(updated);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> complete(String id) async {
    try {
      if (kMockMode) {
        _replaceStatus(id, 'completed');
        return true;
      }
      final updated = await _service.completeAppointment(id);
      _replace(updated);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _replaceStatus(String id, String status) {
    final idx = _appointments.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final old = _appointments[idx];
      _appointments[idx] = Appointment(
        id: old.id,
        clientId: old.clientId,
        clientName: old.clientName,
        clientPhone: old.clientPhone,
        professional: old.professional,
        service: old.service,
        startTime: old.startTime,
        endTime: old.endTime,
        status: status,
        notes: old.notes,
      );
      notifyListeners();
    }
  }

  void _replace(Appointment updated) {
    final idx = _appointments.indexWhere((a) => a.id == updated.id);
    if (idx != -1) _appointments[idx] = updated;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
