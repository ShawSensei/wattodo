import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static const _taskChannelId = 'wattodo_tasks';
  static const _taskChannelName = 'Task Reminders';
  static const _dailyChannelId = 'wattodo_daily';
  static const _dailyChannelName = 'Daily Briefing';

  static const _dailyNotifId = 0;
  static const _allDoneNotifId = 1;
  // Task reminder IDs start at 1000 to avoid clashing with reserved IDs above

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<void> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleTaskReminder({
    required String id,
    required String title,
    required DateTime dueDate,
  }) async {
    final reminderTime = dueDate.subtract(const Duration(hours: 1));
    if (reminderTime.isBefore(DateTime.now())) return;

    try {
      await _plugin.zonedSchedule(
        _taskNotifId(id),
        'Task Due Soon',
        '"$title" is due in 1 hour',
        tz.TZDateTime.from(reminderTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _taskChannelId,
            _taskChannelName,
            channelDescription: 'Reminders 1 hour before a task is due',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('NotificationService: failed to schedule reminder — $e');
    }
  }

  Future<void> cancelTaskReminder(String id) async {
    await _plugin.cancel(_taskNotifId(id));
  }

  Future<void> scheduleDailyBriefing(int pendingCount) async {
    await _plugin.cancel(_dailyNotifId);
    if (pendingCount == 0) return;

    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 8);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    try {
      await _plugin.zonedSchedule(
        _dailyNotifId,
        'Good morning!',
        'You have $pendingCount pending task${pendingCount == 1 ? '' : 's'} today.',
        scheduled,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _dailyChannelId,
            _dailyChannelName,
            channelDescription: 'Daily 8am task summary',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('NotificationService: failed to schedule daily briefing — $e');
    }
  }

  Future<void> showAllDoneNotification() async {
    await _plugin.show(
      _allDoneNotifId,
      'All done!',
      'You\'ve completed all your tasks. Great work!',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _taskChannelId,
          _taskChannelName,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }

  // Stable int ID derived from UUID string, safely above the reserved range [0, 1]
  int _taskNotifId(String taskId) =>
      (taskId.hashCode.abs() % (2000000000 - 1000)) + 1000;
}
