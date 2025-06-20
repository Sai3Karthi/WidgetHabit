package com.example.widget_habit_app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val WIDGET_METHOD_CHANNEL = "widget_habit_app/widget"
    private lateinit var channel: MethodChannel
    private val TAG = "MainActivity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WIDGET_METHOD_CHANNEL)
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "updateWidget" -> {
                    try {
                        updateAppWidgets()
                        result.success(true)
                    } catch (e: Exception) {
                        Log.e(TAG, "Error updating widgets", e)
                        result.error("UPDATE_FAILED", "Failed to update widgets", e.message)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.action == "TOGGLE_HABIT_COMPLETION") {
            val habitId = intent.getStringExtra("habit_id")
            val dayIndex = intent.getIntExtra("day_index", -1)
            if (habitId != null && dayIndex != -1) {
                channel.invokeMethod("toggleHabitCompletion", mapOf("habitId" to habitId, "dayIndex" to dayIndex))
            }
        }
    }

    private fun updateAppWidgets() {
        Log.d(TAG, "Updating app widgets")
        
        try {
            val appWidgetManager = AppWidgetManager.getInstance(this)
            val componentName = ComponentName(this, HabitWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            
            if (appWidgetIds.isNotEmpty()) {
                Log.d(TAG, "Found ${appWidgetIds.size} widgets to update")
                
                // Trigger widget update
                val updateIntent = Intent(this, HabitWidgetProvider::class.java)
                updateIntent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                updateIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds)
                sendBroadcast(updateIntent)
                
                Log.d(TAG, "Widget update broadcast sent")
            } else {
                Log.d(TAG, "No widgets found to update")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error in updateAppWidgets", e)
            throw e
        }
    }

    override fun onResume() {
        super.onResume()
        // Update widgets when app is resumed
        try {
            updateAppWidgets()
        } catch (e: Exception) {
            Log.e(TAG, "Error updating widgets on resume", e)
        }
    }
}
