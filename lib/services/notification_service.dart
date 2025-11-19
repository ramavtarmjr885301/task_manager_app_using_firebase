// Filename: notification_service.dart (Fixed Typo and Custom Sound Enabled)

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
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); 

    // 2. Android settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. iOS settings
    const DarwinInitializationSettings initializationSettingsIOS = 
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          // You may also specify the sound file here for iOS if needed:
          // sound: 'my_alarm.mp3', 
        );

    // 4. Combine settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // FIX APPLIED: Corrected 'initializationsSettings' to 'initializationSettings'
    await flutterLocalNotificationsPlugin.initialize(initializationSettings); 
  }

  // Method to show an immediate test notification
  Future<void> showNotification(int id, String title, String body) async {
    // This channel ('task_manager_channel_id') is for immediate notifications
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_manager_channel_id', 
      'Task Reminders',
      channelDescription: 'Notifications for general task reminders',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      // Using the custom sound for immediate notifications as well
      sound: RawResourceAndroidNotificationSound('my_alarm'), 
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

  // Method to schedule a notification (Alarm System #6) - CUSTOM SOUND IMPLEMENTED
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    
    final tz.TZDateTime scheduledTZTime = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );
    
    if (scheduledTZTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    // This channel ('task_manager_alarm_id') is for the critical alarms
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_manager_alarm_id', 
      'Task Alarms',
      channelDescription: 'Critical alarms for task deadlines',
      importance: Importance.max,
      priority: Priority.high,
      // CUSTOM SOUND REFERENCE: uses 'my_alarm' from res/raw/my_alarm.mp3
      sound: RawResourceAndroidNotificationSound('my_alarm'), 
      fullScreenIntent: true,
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
      // Using inexact mode to avoid permission issues
      androidScheduleMode: AndroidScheduleMode.inexact, 
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: payload,
    );
  }

  // Cancel a specific alarm (Unchanged)
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}