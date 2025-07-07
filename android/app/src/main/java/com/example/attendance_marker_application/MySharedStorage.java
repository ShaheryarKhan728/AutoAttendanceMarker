package com.example.attendance_marker_application;

import android.content.Context;
import android.content.SharedPreferences;

public class MySharedStorage {
    private static final String PREFS_NAME = "HarmonyPrefs";

    public static void set(Context context, String key, String value) {
        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        prefs.edit().putString(key, value).apply();
    }

    public static String get(Context context, String key) {
        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        return prefs.getString(key, null);
    }
}
