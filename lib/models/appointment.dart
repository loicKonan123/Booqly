import 'professional.dart';
import 'service.dart';

class Appointment {
  final String id;
  final String clientId;
  final String clientName;
  final String clientPhone;
  final Professional professional;
  final Service service;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // pending | confirmed | completed | cancelled
  final String? notes;

  const Appointment({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.professional,
    required this.service,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
  });

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
  bool get canCancel => isPending || isConfirmed;

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'] as String,
        clientId: json['clientId'] as String,
        clientName: json['clientName'] as String,
        clientPhone: json['clientPhone'] as String,
        professional:
            Professional.fromJson(json['professional'] as Map<String, dynamic>),
        service: Service.fromJson(json['service'] as Map<String, dynamic>),
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        status: json['status'] as String,
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'clientName': clientName,
        'clientPhone': clientPhone,
        'professional': professional.toJson(),
        'service': service.toJson(),
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'status': status,
        'notes': notes,
      };
}
