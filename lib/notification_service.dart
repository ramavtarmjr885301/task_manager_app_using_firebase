// Filename: notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    // 1. Initialize time zones
    tz.initializeTimeZones();
    // Set the device's current timezone as the local timezone
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // Adjust this to your required timezone or device default

    // 2. Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. iOS settings
    const DarwinInitializationSettings initializationSettingsIOS = 
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // 4. Combine settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Method to show an immediate test notification
  Future<void> showNotification(int id, String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_manager_channel_id', 
      'Task Reminders',
      channelDescription: 'Notifications for task due dates',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformDetails = 
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: 'item x', // Optional payload
    );
  }

  // Method to schedule a notification (Alarm System #6)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    // Cancel any existing notification with the same ID (useful for updates)
    await flutterLocalNotificationsPlugin.cancel(id);
    
    // Convert DateTime to TimeZone-aware ZonedTime
    final tz.TZDateTime scheduledTZTime = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );
    
    // Ensure the scheduled time is in the future
    if (scheduledTZTime.isBefore(tz.TZDateTime.now(tz.local))) {
        return; // Don't schedule past events
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_manager_alarm_id', 
      'Task Alarms',
      channelDescription: 'Critical alarms for task deadlines',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('alarm_sound'), // Custom sound (if configured)
      fullScreenIntent: true, // For waking the screen
    );

    const NotificationDetails platformDetails = 
        NotificationDetails(android: androidDetails);
    
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZTime,
      platformDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Critical alarms
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: payload,
    );
  }

  // Cancel a specific alarm
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}