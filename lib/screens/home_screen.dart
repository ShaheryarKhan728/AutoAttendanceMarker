import 'package:attendance_marker_application/services/background_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/harmony_automation_service.dart';
import '../services/location_service.dart';
import '../services/shared_prefs_service.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController latController = TextEditingController();
  final TextEditingController lngController = TextEditingController();
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool automationEnabled = false;
  bool configComplete = false;
  bool isMarkedToday = false;
  LocationService? locationService;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final officeLat = await SharedPrefsService.get("officeLat");
    final officeLng = await SharedPrefsService.get("officeLng");
    // loginfo("officeLat: $officeLat");
    // loginfo("officeLng: $officeLng");

    latController.text = officeLat?.toString() ?? "";
    lngController.text = officeLng?.toString() ?? "";
    userIdController.text = await SharedPrefsService.get("userId") ?? "";
    passwordController.text = await SharedPrefsService.get("password") ?? "";

    final isComplete = officeLat != null &&
        officeLng != null &&
        userIdController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;

    final marked = await LocationService()
        .hasMarkedToday(DateTime.now().toUtc().add(const Duration(hours: 5)));

    final enabledStr = await SharedPrefsService.get("automationEnabled");
  final wasAutomationEnabled = enabledStr == 'true';

    setState(() {
      configComplete = isComplete;
      isMarkedToday = marked;
      automationEnabled = wasAutomationEnabled;
    });
  }

  Future<void> _savePrefs() async {
    final lat = latController.text.trim();
    final lng = lngController.text.trim();

    if (lat.isEmpty || lng.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid coordinates.")),
      );
      return;
    }

    await SharedPrefsService.set("officeLat", lat);
    await SharedPrefsService.set("officeLng", lng);
    await SharedPrefsService.set("userId", userIdController.text.trim());
    await SharedPrefsService.set("password", passwordController.text.trim());

    setState(() {
      configComplete = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saved successfully.")),
    );
  }

  void toggleAutomation(bool value) async {
    setState(() => automationEnabled = value);
    await SharedPrefsService.set("automationEnabled", value.toString());

    if (value) {
      locationService = LocationService();

      final status = await Permission.locationAlways.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission required.')),
        );
        setState(() => automationEnabled = false);
        return;
      }
      initializeService();
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allFieldsFilled = latController.text.trim().isNotEmpty &&
        lngController.text.trim().isNotEmpty &&
        userIdController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
    "Auto Attendance Marker",
    style: TextStyle(color: Colors.white), // 👈 Set text color to white
  ),    centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: ListView(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: latController,
                      label: "Office Latitude",
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: lngController,
                      label: "Office Longitude",
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: userIdController,
                      label: "User ID",
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: passwordController,
                      label: "Password",
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: allFieldsFilled
                            ? () async {
                                await _savePrefs();
                                openAccessibilitySettings();
                              }
                            : null,
                        icon: const Icon(Icons.save),
                        label: const Text("Save Settings"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.deepPurple.shade100,
                          disabledForegroundColor: Colors.white70,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              title: const Text("Enable Auto-Attendance"),
              value: automationEnabled,
              onChanged: configComplete ? toggleAutomation : null,
              subtitle: !configComplete
                  ? const Text("Please save configuration first.")
                  : null,
              activeColor: Colors.deepPurple,
            ),
            const SizedBox(height: 30),
            const Divider(thickness: 1.2),
            const SizedBox(height: 20),
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Designed & Developed by',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Shaheryar Khan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Email: emailshaheryar@gmail.com',
                style: TextStyle(fontSize: 13),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () async {
                  final url = Uri.parse(
                      'https://www.linkedin.com/in/shaheryarkhan28/');
                  try {
                    await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                  } catch (e) {
                    // loginfo("❌ Failed to launch LinkedIn URL: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Could not open LinkedIn.")),
                    );
                  }
                },
                child: RichText(
                  text: const TextSpan(
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(Icons.link, size: 16, color: Colors.blue),
                      ),
                      TextSpan(
                        text: '  LinkedIn: shaheryarkhan28',
                        style: TextStyle(fontSize: 13, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void openAccessibilitySettings() {
    const platform = MethodChannel('com.example.attendance_marker/intent');
    platform.invokeMethod('launchIntent', {
      'action': 'android.settings.ACCESSIBILITY_SETTINGS',
    });
  }
}
