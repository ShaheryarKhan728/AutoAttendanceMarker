# 📲 Harmony Auto Attendance Marker

An automation tool designed **exclusively for employees using Harmony by Softcom**. This app on tapping notification, auto-fills configured credentials and marks attendance (Time In) between hours 7am to 12pm using Accessibility Services and background location tracking.

---

## ⚙️ Features

- 🔒 Securely stores user credentials locally on the device
- 📍 Marks attendance automatically on notification tap when within office range (lat/lng based)
- 🕐 Operates only during working hours (07:00 AM – 12:00 PM, Mon–Fri)
- 📅 Ensures attendance is marked only once per day
- 🛰️ No internet communication — all logic and storage is offline
- 📱 Works silently in the background

---

## 🔐 Security

- ✅ **User data is stored only in the phone’s local memory**
- ✅ **No internet access is used**, which means **no user data leaves the device**
- ✅ Office location, user ID, and password are used only for automation
- ✅ **Accessibility Service** is limited to your configured app only
- 🔐 Designed with local-only logic for maximum privacy

---

## 🔋 Battery Usage

- ✅ **Low battery usage**:
  - Limited background activity
  - Location fetched **only during office hours** and **only if attendance not yet marked**
  - No continuous GPS tracking or unnecessary polling
  - ⚙️ Background service is lightweight and efficient

**📲 Required Permissions**

To function correctly, this app requires the following permissions:

📍 Location (Always) – Used to detect if the user is within the office range during office hours
♿ Accessibility Service – Automates interaction with the Harmony app to mark attendance
🔔 Notification Access – Required to trigger attendance marking via notification tap
⚙️ Background Execution – Needed for location checks and showing the notification silently
💡 The app will prompt the user to enable each permission as needed during the setup process.

---

## 🚧 Disclaimer

This app is intended only for use by Harmony (Softcom) employees and works specifically with the Harmony attendance app. It is not intended or guaranteed to work with other systems.
📌 Note: Make sure biometric authentication is reset/disabled in the Harmony app before using this automation tool for smooth functioning.

---

## 👨‍💻 Developed By

**Shaheryar Khan**  
📧 emailshaheryar@gmail.com  
🔗 [LinkedIn](https://www.linkedin.com/in/shaheryarkhan28/)
