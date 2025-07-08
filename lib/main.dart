import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';
import 'screens/home_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'services/harmony_automation_service.dart';
import 'services/location_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Notification permission
  final notificationStatus = await Permission.notification.request();
  // if (!notificationStatus.isGranted) {
  //   debugPrint("❌ Notification permission not granted");
  // } else {
  //   debugPrint("✅ Notification permission granted");
  // }

  // 2. Location permission
  LocationPermission locationPermission = await Geolocator.checkPermission();
  if (locationPermission == LocationPermission.denied ||
      locationPermission == LocationPermission.deniedForever) {
    locationPermission = await Geolocator.requestPermission();
  }

  // 3. NotificationService init
  final notificationService = NotificationService();
  final launchDetails =
      await NotificationService.notificationsPlugin.getNotificationAppLaunchDetails();

  final launchedFromNoti = launchDetails?.didNotificationLaunchApp ?? false;

  if (launchedFromNoti &&
      launchDetails?.notificationResponse?.payload == 'MARK_ATTENDANCE') {
    // 🔁 Handle tap on notification (cold start)
    await HarmonyAutomationService().markAttendance();
    final now = DateTime.now().toUtc().add(const Duration(hours: 5));
    await LocationService().setMarkedToday(now);
  }

  await notificationService.init();

  // Start background logic
  // initializeService();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Marker AI',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
