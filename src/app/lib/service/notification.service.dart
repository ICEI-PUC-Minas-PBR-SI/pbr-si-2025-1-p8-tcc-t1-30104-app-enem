import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    tz.initializeTimeZones();

    await _notificationsPlugin.initialize(settings);
  }

  static Future<void> scheduleDailyReminder() async {
    await _notificationsPlugin.periodicallyShow(
      0,
      'Hora de estudar!',
      'Não se esqueça do seu plano de estudo de hoje.',
      RepeatInterval.daily,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'study_channel',
          'Plano de Estudo',
          channelDescription: 'Lembrete diário do plano de estudo',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }


  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
