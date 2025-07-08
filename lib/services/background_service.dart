import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location_service.dart';
import 'notification_service.dart';
import '../utils/logger.dart';

void initializeService() {
  FlutterBackgroundService().configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      autoStartOnBoot: true,
      notificationChannelId: 'attendance_channel',
      initialNotificationTitle: 'Attendance Service Running',
      initialNotificationContent: 'Monitoring location...',
    ),
    iosConfiguration: IosConfiguration(),
  );

  FlutterBackgroundService().startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService();
  }
  final prefs = await SharedPreferences.getInstance();
  

  final notificationService = NotificationService();
  await notificationService.init();

  final locationService = LocationService();

  Timer.periodic(const Duration(minutes: 10), (timer) async {
    try {
      final pkTime = DateTime.now().toUtc().add(Duration(hours: 5));
if (pkTime.weekday < 6 && pkTime.hour >= 7 && pkTime.hour < 12) {
      final latStr = prefs.getString('officeLat');
final lngStr = prefs.getString('officeLng');
final lat = double.tryParse(latStr ?? '');
final lng = double.tryParse(lngStr ?? '');

  final userId = prefs.getString('userId');
  final password = prefs.getString('password');

  if (lat == null || lng == null || userId == null || password == null) {
    // Do not proceed if info missing
    // loginfo("values null in bg service");
    return;
  }
      final now = DateTime.now().toUtc().add(Duration(hours: 5));
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      await prefs.reload();
      final lastMarked = prefs.getString('last_marked_date');
      // loginfo("todayStr: " + todayStr);
      // loginfo("lastMarked: $lastMarked");

      if (lastMarked == todayStr) {
        // loginfo("✅ Already marked attendance today.");
        return; // Already marked today
      }

      final isAtOffice = await locationService.isAtOffice();
      // loginfo("isAtOffice: " + isAtOffice.toString());
      if (isAtOffice) {
        await notificationService.showNotification();
        // await prefs.setString('last_marked_date', todayStr);
      }
}else {
          // loginfo("🕒 Outside allowed time or weekend.");
        }
    } catch (_) {
      // silently fail
    }
  });
}
