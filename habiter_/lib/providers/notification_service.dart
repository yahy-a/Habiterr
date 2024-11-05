import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notificationsPlugin.initialize(initializationSettings);
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'Habit_reminder', // id
    'Habit Reminder', // title
    description: 'Reminder for your habits',
    importance: Importance.high,
  );

  // Create the channel on the Android platform
  await notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  Future<void> scheduleNotification(
      {required int id,
      required String title,
      required String body,
      required TimeOfDay scheduledTime}) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
        now.year, now.month, now.day, scheduledTime.hour, scheduledTime.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'Habit_reminder',
          'Habit Reminder',
          channelDescription: 'Reminder for your habits',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }

  // Future<void> updateNotificationTime({
  //   required int id,
  //   required String title,
  //   required String body,
  //   required TimeOfDay newScheduledTime,
  // }) async {
  //   // Fetch the existing notification details (title and body)
  //   // You may need to store these details when scheduling the notification
  //   String existingTitle = title; 
  //   String existingBody = body; 

  //   // Convert TimeOfDay to DateTime for today
  //   final now = DateTime.now();
  //   var scheduledDate = DateTime(
  //     now.year,
  //     now.month,
  //     now.day,
  //     newScheduledTime.hour,
  //     newScheduledTime.minute,
  //   );

  //   // If the time has already passed today, schedule for tomorrow
  //   if (scheduledDate.isBefore(now)) {
  //     scheduledDate = scheduledDate.add(const Duration(days: 1));
  //   }

  //   // Update the notification with the new scheduled time
  //   await notificationsPlugin.zonedSchedule(
  //     id,
  //     existingTitle, // Use the existing title
  //     existingBody, // Use the existing body
  //     tz.TZDateTime.from(scheduledDate, tz.local),
  //     NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'habit_reminders', // Use the same channel ID
  //         'Habit Reminders',
  //         importance: Importance.max,
  //         priority: Priority.high,
  //       ),
  //       iOS: DarwinNotificationDetails(),
  //     ),
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //     uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //     matchDateTimeComponents: DateTimeComponents.time,
  //   );
  // }
}
