import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'app.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');

  // Hive — fonctionne sur toutes les plateformes (IndexedDB sur web)
  await Hive.initFlutter();
  await Hive.openBox('auth');
  await Hive.openBox('cache');

  // Notifications locales — non disponibles sur web
  if (!kIsWeb) {
    tz.initializeTimeZones();
    await NotificationService.instance.init();
  }

  runApp(const AppointEaseApp());
}
