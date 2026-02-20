import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime date) =>
      DateFormat('dd MMMM yyyy', 'fr_FR').format(date);

  static String formatDateTime(DateTime date) =>
      DateFormat('dd MMM yyyy à HH:mm', 'fr_FR').format(date);

  static String formatTime(DateTime date) =>
      DateFormat('HH:mm').format(date);

  static String formatDayOfWeek(DateTime date) =>
      DateFormat('EEEE', 'fr_FR').format(date);

  static String formatShortDate(DateTime date) =>
      DateFormat('dd/MM/yyyy').format(date);

  /// Returns "Aujourd'hui", "Demain", or the formatted date
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return "Aujourd'hui";
    if (diff == 1) return 'Demain';
    if (diff == -1) return 'Hier';
    return formatDate(date);
  }

  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59);

  /// Parse ISO 8601 string safely
  static DateTime? tryParse(String? value) {
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  static String toIso(DateTime date) => date.toUtc().toIso8601String();
}
