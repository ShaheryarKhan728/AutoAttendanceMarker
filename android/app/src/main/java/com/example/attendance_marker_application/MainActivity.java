package com.example.attendance_marker_application;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterFragmentActivity {
    private static final String CHANNEL = "com.example.attendance_marker/intent";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {
                    switch (call.method) {
                        case "tapTimeInButton":
                            // Log.d("MainActivity", "tapTimeInButton event");
                            triggerAccessibilityService();
                            result.success("Accessibility service triggered");
                            break;

                        case "launchIntent":
                            // Log.d("MainActivity", "launchIntent event ");
                            String action = call.argument("action");
                            launchIntent(action);
                            result.success("Intent launched successfully");
                            break;

                        case "sendCredentials":
                            // Log.d("MainActivity", "sendCredentials event ");
                            String userId = call.argument("userId");
                            String password = call.argument("password");
                            // Log.d("MainActivity", "userId in mainactivity: " + userId);
                            // Log.d("MainActivity", "password in mainactivity: " + password);
                            MySharedStorage.set(this, "userId", userId);
                            MySharedStorage.set(this, "password", password);
                            result.success("Credentials saved");
                            break;

                        default:
                            result.notImplemented();
                            break;
                    }
                }
            );
    }

    private void triggerAccessibilityService() {
        // Log.d("MainActivity", "triggerAccessibilityClick() called.");
        // You can invoke Accessibility logic here
    }

    private void launchIntent(String action) {
        if (action != null && !action.isEmpty()) {
            Intent intent = new Intent(action);
            startActivity(intent);
        }
    }
}
