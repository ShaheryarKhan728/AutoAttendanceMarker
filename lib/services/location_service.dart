// IMPORTS
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'notification_service.dart';
import 'harmony_automation_service.dart';
import '../utils/logger.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class LocationService {
  Future<bool> isAtOffice() async {
    try {
      // loginfo("📍 Checking user position...");

      final prefs = await SharedPreferences.getInstance();
      final lat = double.tryParse(prefs.getString('officeLat') ?? '');
      final lng = double.tryParse(prefs.getString('officeLng') ?? '');


      if (lat == null || lng == null) {
        // loginfo("⚠️ Office coordinates not set. Skipping location check.");
        return false;
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        // loginfo("❌ Location permission denied.");
        return false;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        lat,
        lng,
      );

      // loginfo("User is ${distance.toStringAsFixed(2)} meters from the office.");
      return distance < 50;
    } catch (e) {
      // loginfo("❌ Error getting location: $e");
      return false;
    }
  }

  Future<void> requestLocationPermission() async {
    final status = await Permission.locationAlways.request();
    if (!status.isGranted) {
      // loginfo("❌ Location permission not granted.");
      return;
    }

    // startLocationTracking();
  }

  // void startLocationTracking() {
  //   // loginfo("📡 Starting background location check...");

  //   Timer.periodic(Duration(seconds: 30), (timer) async {
  //     try {
  //       final now = DateTime.now();
  //       final pkTime = now.toUtc().add(Duration(hours: 5)); // PKT

  //       if (pkTime.weekday >= 1 && pkTime.weekday <= 5 && pkTime.hour >= 0 && pkTime.hour < 12) {
  //         var isMarked = await hasMarkedToday(pkTime); 
  //         // loginfo("is attendance marked: " + isMarked.toString());
  //         if (isMarked) {
  //           // loginfo("✅ Already marked attendance today.");
  //           return;
  //         }


  //         final prefs = await SharedPreferences.getInstance();
  //         final userId = prefs.getString('userId');
  //         final password = prefs.getString('password');
  //         final latStr = prefs.getString('officeLat');
  //         final lngStr = prefs.getString('officeLng');
  //         final lat = double.tryParse(latStr ?? '');
  //         final lng = double.tryParse(lngStr ?? '');

  //         if (userId == null || password == null || lat == null || lng == null) {
  //           // loginfo("⚠️ Required info missing. Skipping.");
  //           return;
  //         }

  //         final isAtOfficeNow = await isAtOffice();
  //         if (isAtOfficeNow) {
  //           await NotificationService().showNotification();
  //           // await Future.delayed(Duration(seconds: 10));
  //           // await HarmonyAutomationService().markAttendance();
  //           // await _setMarkedToday(pkTime);
  //         } else {
  //           // loginfo("🚶 Not at office yet.");
  //         }
  //       } else {
  //         // loginfo("🕒 Outside allowed time or weekend.");
  //       }
  //     } catch (e) {
  //       // loginfo("❌ Error in location loop: $e");
  //     }
  //   });
  // }

  Future<bool> hasMarkedToday(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final markedDate = prefs.getString('last_marked_date');
    // loginfo("markedDate: " + markedDate.toString());
    return markedDate == today;
  }

  Future<void> setMarkedToday(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(now);
    await prefs.setString('last_marked_date', today);
    // loginfo("✅ Marked attendance for: $today");
  }
}
