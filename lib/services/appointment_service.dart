import '../core/constants/api_constants.dart';
import '../core/network/dio_client.dart';
import '../models/appointment.dart';

class AppointmentService {
  final _client = DioClient.instance;

  Future<Appointment> createAppointment({
    required String professionalId,
    required String serviceId,
    required String slotId,
    String? notes,
  }) async {
    final data = await _client.post(ApiConstants.appointments, data: {
      'professionalId': professionalId,
      'serviceId': serviceId,
      'slotId': slotId,
      if (notes != null) 'notes': notes,
    });
    return Appointment.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Appointment>> getMyAppointments() async {
    final data = await _client.get(ApiConstants.myAppointments);
    return (data as List)
        .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Appointment> updateStatus(String id, String status) async {
    final data = await _client.patch(
      ApiConstants.appointmentStatus(id),
      data: {'status': status},
    );
    return Appointment.fromJson(data as Map<String, dynamic>);
  }

  Future<Appointment> cancelAppointment(String id) =>
      updateStatus(id, 'cancelled');

  Future<Appointment> confirmAppointment(String id) =>
      updateStatus(id, 'confirmed');

  Future<Appointment> completeAppointment(String id) =>
      updateStatus(id, 'completed');
}
