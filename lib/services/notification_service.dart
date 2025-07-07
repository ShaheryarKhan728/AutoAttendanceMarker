import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/harmony_automation_service.dart';
import '../services/location_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) async {
        if (response.payload == 'MARK_ATTENDANCE') {
          // print("✅ Notification tapped, marking attendance...");
          HarmonyAutomationService().markAttendance();

// print("✅ going to set marked today");
          // Mark attendance date
        final now = DateTime.now().toUtc().add(Duration(hours: 5));
        await LocationService().setMarkedToday(now);
        }
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'attendance_channel',
      'Office Attendance',
      description: 'Notify when user is at office',
      importance: Importance.high,
    );

    final androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
  }

  Future<void> showNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'attendance_channel',
      'Office Attendance',
      channelDescription: 'Notify when user is at office',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const platformDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0,
      '📍 You\'re at the office!',
      'Tap to mark your attendance',
      platformDetails,
      payload: 'MARK_ATTENDANCE',
    );
  }
}
