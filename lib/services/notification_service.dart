import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<void> showAppointmentConfirmed({
    required String clientName,
    required DateTime dateTime,
    required String serviceName,
  }) async {
    await _plugin.show(
      dateTime.hashCode,
      'Rendez-vous confirmé',
      'Votre RDV $serviceName est confirmé pour le ${_fmt(dateTime)}',
      _details(),
    );
  }

  Future<void> scheduleReminder({
    required int id,
    required String clientName,
    required DateTime appointmentTime,
    required String serviceName,
  }) async {
    final reminderTime = appointmentTime.subtract(const Duration(hours: 24));
    if (reminderTime.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id,
      'Rappel de rendez-vous',
      'Votre RDV $serviceName est demain à ${_fmtTime(appointmentTime)}',
      tz.TZDateTime.from(reminderTime, tz.local),
      _details(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showAppointmentCancelled(String serviceName) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Rendez-vous annulé',
      'Votre rendez-vous $serviceName a été annulé.',
      _details(),
    );
  }

  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }

  NotificationDetails _details() => const NotificationDetails(
        android: AndroidNotificationDetails(
          'appointease_channel',
          'AppointEase',
          channelDescription: 'Notifications de rendez-vous',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} à ${_fmtTime(dt)}';

  String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
