import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Wraps [FlutterLocalNotificationsPlugin] to schedule a daily reminder.
///
/// Defensive by design: every platform call is wrapped so the rest of the app
/// keeps working even if notification permissions are denied or unavailable
/// (e.g. on the desktop preview).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _dailyId = 1001;
  static const _continueId = 1002;
  static const _retentionId = 1003;
  static const _channelId = 'lumina_reminders';

  Future<void> init() async {
    try {
      tz.initializeTimeZones();
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _plugin.initialize(
        settings: const InitializationSettings(android: android, iOS: ios),
      );
      _ready = true;
    } catch (e) {
      debugPrint('NotificationService.init failed: $e');
    }
  }

  Future<void> requestPermissions() async {
    if (!_ready) return;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('requestPermissions failed: $e');
    }
  }

  Future<void> scheduleDaily(int hour, int minute) async {
    if (!_ready) return;
    try {
      await cancel();
      await _plugin.zonedSchedule(
        id: _dailyId,
        title: 'Ton rendez-vous quotidien ✨',
        body: 'Quelques minutes suffisent pour avancer aujourd\'hui.',
        scheduledDate: _nextInstanceOf(hour, minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Rappels',
            channelDescription: 'Rappels quotidiens de pratique',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('scheduleDaily failed: $e');
    }
  }

  Future<void> cancel() async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: _dailyId);
    } catch (e) {
      debugPrint('cancel failed: $e');
    }
  }

  /// Automatic daily nudge fired while a program is still unfinished.
  Future<void> scheduleContinueReminder({int hour = 19, int minute = 0}) async {
    if (!_ready) return;
    try {
      await requestPermissions();
      await _plugin.cancel(id: _continueId);
      await _plugin.zonedSchedule(
        id: _continueId,
        title: 'Ton programme t\'attend 📚',
        body: 'Il te reste des chapitres à terminer. Avance un peu aujourd\'hui !',
        scheduledDate: _nextInstanceOf(hour, minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Rappels',
            channelDescription: 'Rappels quotidiens de pratique',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('scheduleContinueReminder failed: $e');
    }
  }

  Future<void> cancelContinueReminder() async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: _continueId);
    } catch (e) {
      debugPrint('cancelContinueReminder failed: $e');
    }
  }

  /// Surprise daily retention nudge ("did you remember?") at a varying hour.
  Future<void> scheduleRetention({int hour = 12}) async {
    if (!_ready) return;
    try {
      await requestPermissions();
      await _plugin.cancel(id: _retentionId);
      await _plugin.zonedSchedule(
        id: _retentionId,
        title: 'Quiz surprise 🧠',
        body: 'Vérifions ensemble ce que tu as retenu — ça prend 1 minute.',
        scheduledDate: _nextInstanceOf(hour, 0),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Rappels',
            channelDescription: 'Rappels quotidiens de pratique',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('scheduleRetention failed: $e');
    }
  }

  Future<void> cancelRetention() async {
    if (!_ready) return;
    try {
      await _plugin.cancel(id: _retentionId);
    } catch (e) {
      debugPrint('cancelRetention failed: $e');
    }
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
