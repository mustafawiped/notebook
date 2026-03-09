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
    print("Timezone: ${timeZone.identifier}"); // ne yazıyor bak

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
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
        tz.TZDateTime.local(
          scheduledDate.year,
          scheduledDate.month,
          scheduledDate.day,
          scheduledDate.hour,
          scheduledDate.minute,
        ),
        _details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      print("Şu an: ${tz.TZDateTime.now(tz.local)}");
      print("Planlanacak: ${tz.TZDateTime.from(scheduledDate, tz.local)}");
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
