import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'bedtime_reminder';
  static const _channelName = 'Bedtime Reminder';
  static const _notificationId = 1;
  static const _prefKey = 'bedtime_hour';

  /// Initialize the notification service
  static Future<void> initialize() async {
    if (kIsWeb) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    // Request permissions on Android 13+
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    // Schedule default bedtime reminder if not set
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_prefKey)) {
      await scheduleBedtimeReminder(22); // Default 10 PM
    }
  }

  /// Schedule daily bedtime reminder at specified hour
  static Future<void> scheduleBedtimeReminder(int hour) async {
    if (kIsWeb) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, hour);

    await _notifications.cancelAll();

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      0,
    );

    // If time already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Daily reminder to check sleep habits',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      _notificationId,
      'Sleep Hygiene Check-in',
      'Time to review your bedtime habits',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Get currently scheduled hour
  static Future<int> getScheduledHour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefKey) ?? 22;
  }
}
