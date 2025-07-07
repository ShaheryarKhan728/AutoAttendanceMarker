import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';
import '../utils/logger.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HarmonyAutomationService {
  static const platform = MethodChannel('com.example.attendance_marker/intent');

  void openHarmonyApp() {
    final intent = AndroidIntent(
      action: 'android.intent.action.MAIN',
      package: 'com.sofcom.mark_attendance',
      componentName: 'com.sofcom.mark_attendance.MainActivity',
      flags: <int>[
        Flag.FLAG_ACTIVITY_NEW_TASK,
        Flag.FLAG_ACTIVITY_CLEAR_TOP,
        Flag.FLAG_ACTIVITY_SINGLE_TOP,
      ],
    );
    intent.launch();
  }

Future<void> markAttendance() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');
  final password = prefs.getString('password');
  // loginfo("userId in harmony service: " + userId.toString());
  // loginfo("password in harmony service: " + password.toString());

  if (userId == null || password == null) {
    // loginfo("⚠️ Credentials not found in SharedPreferences.");
    return;
  }

  try {
    // loginfo("⌨️ Sending credentials to Android");

    // 1️⃣ Save to Android native SharedPrefs
    await platform.invokeMethod('sendCredentials', {
      'userId': userId,
      'password': password,
    });

    // 2️⃣ Wait briefly to ensure Android saves
    await Future.delayed(Duration(milliseconds: 500));

    // 3️⃣ THEN launch Harmony app
    openHarmonyApp();

    // loginfo("harmony app launched!!!");

    // 4️⃣ Wait for app to load
    await Future.delayed(Duration(seconds: 8));

    // 5️⃣ Trigger Accessibility
    await platform.invokeMethod('tapTimeInButton');
  } catch (e) {
    // loginfo("❌ Failed to send credentials or trigger tap: $e");
  }
}



}
