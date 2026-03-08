import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    final timeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZone.identifier));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static NotificationDetails get _details => const NotificationDetails(
    android: AndroidNotificationDetails(
      'notebook_channel',
      'Notebook Notifications',
      channelDescription: 'Note reminders',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  static Future<void> scheduleNoteNotifications({
    required int noteId,
    required String title,
    required DateTime date,
  }) async {
    final offsets = [
      const Duration(hours: 3),
      const Duration(hours: 1),
      const Duration(minutes: 15),
      Duration.zero,
    ];

    final messages = [
      "3 hours left: $title",
      "1 hour left: $title",
      "15 minutes left: $title",
      "Time's up: $title",
    ];

    for (int i = 0; i < offsets.length; i++) {
      final scheduledDate = date.subtract(offsets[i]);
      if (scheduledDate.isBefore(DateTime.now())) continue;

      await _plugin.zonedSchedule(
        noteId * 10 + i,
        'Notebook',
        messages[i],
        tz.TZDateTime.from(scheduledDate, tz.local),
        _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> cancelNoteNotifications(int noteId) async {
    for (int i = 0; i < 4; i++) {
      await _plugin.cancel(noteId * 10 + i);
    }
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
