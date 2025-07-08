package com.example.attendance_marker_application;

import android.accessibilityservice.AccessibilityService;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.accessibility.AccessibilityEvent;
import android.view.accessibility.AccessibilityNodeInfo;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.ArrayList;
import java.util.List;

public class MyAccessibilityService extends AccessibilityService {

    private boolean credentialsFilled = false;
    private boolean attendanceMarked = false;

    @Override
    public void onAccessibilityEvent(AccessibilityEvent event) {

    new Handler(Looper.getMainLooper()).postDelayed(() -> {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
        String lastMarked = prefs.getString("last_marked_date", "");
        String today = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(new Date());
        // Log.d("MyAccessibilityService", "🔁 Delayed read: last_marked_date = " + lastMarked);

        if (!today.equals(lastMarked) && !attendanceMarked) {
            credentialsFilled = false;
            attendanceMarked = false;
            // Log.d("AttendanceService", "🔄 New day detected. Flags reset (after delay).");
        }
    }, 5000);

        if ((event.getEventType() == AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED ||
             event.getEventType() == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED)
            && !credentialsFilled && !attendanceMarked) {
                

            AccessibilityNodeInfo rootNode = getRootInActiveWindow();
            if (rootNode != null) {
                // Log.d("MyAccessibilityService", "👀 Looking for input fields...");
                fillCredentialsAndTap(rootNode);
                logAllClickableNodes(rootNode);
            }
        }
    }

    private void fillCredentialsAndTap(final AccessibilityNodeInfo rootNode) {
        if (rootNode == null) return;

        String userId = MySharedStorage.get(this, "userId");
        String password = MySharedStorage.get(this, "password");
        // Log.w("MyAccessibilityService", "userId in MyAccessibilityService: " + userId);
        // Log.w("MyAccessibilityService", "password in MyAccessibilityService: " + password);

        if (userId == null || password == null) {
            // Log.w("MyAccessibilityService", "⚠️ Credentials not found.");
            return;
        }

        final List<AccessibilityNodeInfo> editTexts = new ArrayList<>();
        findNodesByClass(rootNode, "android.widget.EditText", editTexts);

        if (editTexts.size() >= 2) {
            // Log.d("MyAccessibilityService", "⌨️ Entering credentials...");

            fillField(editTexts.get(0), userId, 0);
            fillField(editTexts.get(1), password, 1000);

            credentialsFilled = true;

            new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
                @Override
                public void run() {
                    clickTimeInButton(rootNode);
                    attendanceMarked = true;
                }
            }, 2500);
        }
    }

    private void fillField(final AccessibilityNodeInfo field, final String text, int delayMillis) {
        if (field == null) return;

        new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
            @Override
            public void run() {
                field.performAction(AccessibilityNodeInfo.ACTION_CLICK);
                field.performAction(AccessibilityNodeInfo.ACTION_FOCUS);

                new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        Bundle arguments = new Bundle();
                        arguments.putCharSequence(AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE, text);
                        boolean success = field.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT, arguments);
                        // Log.d("MyAccessibilityService", "✅ Set text: " + text + " | success = " + success);
                    }
                }, 600);
            }
        }, delayMillis);
    }

    private void clickTimeInButton(AccessibilityNodeInfo rootNode) {
        List<AccessibilityNodeInfo> buttons = new ArrayList<>();
        findButtonNodesByClass(rootNode, "android.widget.Button", buttons);

        for (AccessibilityNodeInfo btn : buttons) {
            if (btn != null) {
                CharSequence text = btn.getContentDescription();
                // Log.d("MyAccessibilityService", "Checking button with contentDesc: " + text);

                if (text != null && "Time In".contentEquals(text)) {
    boolean clicked = btn.performAction(AccessibilityNodeInfo.ACTION_CLICK);
    // Log.d("MyAccessibilityService", "🟢 Clicked 'Time In': " + clicked);

    if (clicked) {
        String today = new SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(new Date());
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
        prefs.edit().putString("last_marked_date", today).apply();
        // Log.i("MyAccessibilityService", "📅 Updated last_marked_date to: " + today);

        attendanceMarked = true; // also update in memory if used
    }
    break;
}

            }
        }
    }

    private void findNodesByClass(AccessibilityNodeInfo node, String className, List<AccessibilityNodeInfo> list) {
        if (node == null) return;

        if (className.equals(node.getClassName())) list.add(node);

        for (int i = 0; i < node.getChildCount(); i++) {
            AccessibilityNodeInfo child = node.getChild(i);
            if (child != null) {
                findNodesByClass(child, className, list);
            }
        }
    }

    private void findButtonNodesByClass(AccessibilityNodeInfo node, String className, List<AccessibilityNodeInfo> list) {
        if (node == null) return;

        CharSequence desc = node.getContentDescription();
        if (desc != null && desc.toString().equals("Time In")) {
            list.add(node);
        }

        for (int i = 0; i < node.getChildCount(); i++) {
            AccessibilityNodeInfo child = node.getChild(i);
            if (child != null) {
                findButtonNodesByClass(child, className, list);
            }
        }
    }

    private void logAllClickableNodes(AccessibilityNodeInfo node) {
        if (node == null) return;

        // if (node.isClickable()) {
        //     Log.d("ClickableNode", "Node: " + node +
        //             "\nText: " + node.getText() +
        //             "\nContentDesc: " + node.getContentDescription() +
        //             "\nClass: " + node.getClassName() +
        //             "\nID: " + node.getViewIdResourceName());
        // }

        for (int i = 0; i < node.getChildCount(); i++) {
            AccessibilityNodeInfo child = node.getChild(i);
            logAllClickableNodes(child);
            if (child != null) child.recycle();
        }
    }

    @Override
    public void onInterrupt() {
        // Log.w("MyAccessibilityService", "🚨 Accessibility Service Interrupted");
    }

    @Override
    protected void onServiceConnected() {
        super.onServiceConnected();
        // Log.i("MyAccessibilityService", "✅ Accessibility Service connected");
    }
}
