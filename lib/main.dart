import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';
import 'screens/home_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Notification permission
  final notificationStatus = await Permission.notification.request();
  if (!notificationStatus.isGranted) {
    // debugPrint("❌ Notification permission not granted");
  } else {
    // debugPrint("✅ Notification permission granted");
  }

  // 2. Location permission
  LocationPermission locationPermission = await Geolocator.checkPermission();
  if (locationPermission == LocationPermission.denied ||
      locationPermission == LocationPermission.deniedForever) {
    locationPermission = await Geolocator.requestPermission();
  }

  if (locationPermission == LocationPermission.denied) {
    // debugPrint("❌ Location permission not granted");
  } else {
    // debugPrint("✅ Location permission granted");
  }

  // // 3. Check and Redirect to Accessibility Settings
  // const platform = MethodChannel('com.attendance.marker/accessibility');
  // bool isAccessibilityEnabled = false;
  // try {
  //   isAccessibilityEnabled =
  //       await platform.invokeMethod('isAccessibilityEnabled');
  // } on PlatformException catch (e) {
  //   debugPrint("❌ Failed to check accessibility status: ${e.message}");
  // }

  // if (!isAccessibilityEnabled) {
  //   debugPrint("🔁 Redirecting to accessibility settings...");
  //   await openAppSettings(); // This opens the general settings screen
  // } else {
  //   debugPrint("✅ Accessibility already enabled");
  // }

  // Initialize Notification Service
  final notificationService = NotificationService();
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
