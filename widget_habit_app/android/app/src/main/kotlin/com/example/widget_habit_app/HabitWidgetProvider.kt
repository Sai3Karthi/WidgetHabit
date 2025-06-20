package com.example.widget_habit_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import android.widget.RemoteViews
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

class HabitWidgetProvider : AppWidgetProvider() {

    companion object {
        private const val TAG = "HabitWidgetProvider"
        private const val WIDGET_DATA_KEY = "flutter.widget_habit_data"
        private const val ACTION_TOGGLE_COMPLETION = "com.example.widget_habit_app.TOGGLE_COMPLETION"
        private const val ACTION_OPEN_APP = "com.example.widget_habit_app.OPEN_APP"
        private const val EXTRA_HABIT_ID = "habit_id"
        private const val EXTRA_DAY_INDEX = "day_index"
        
        // Widget Colors (matching app theme)
        private const val COLOR_COMPLETED_GREEN = 0xFF4CAF50.toInt()
        private const val COLOR_INCOMPLETE_GREY = 0xFF424242.toInt()
        private const val COLOR_CURRENT_DAY_HIGHLIGHT = 0xFF4A90E2.toInt()
        private const val COLOR_PRIMARY_TEXT = 0xFFFFFFFF.toInt()
        private const val COLOR_SECONDARY_TEXT = 0xFFB3B3B3.toInt()
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d(TAG, "onUpdate called for ${appWidgetIds.size} widgets")
        
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        
        when (intent.action) {
            ACTION_TOGGLE_COMPLETION -> {
                handleToggleCompletion(context, intent)
            }
            ACTION_OPEN_APP -> {
                handleOpenApp(context)
            }
            "android.appwidget.action.APPWIDGET_UPDATE" -> {
                // Force update all widgets
                val appWidgetManager = AppWidgetManager.getInstance(context)
                val appWidgetIds = appWidgetManager.getAppWidgetIds(
                    android.content.ComponentName(context, HabitWidgetProvider::class.java)
                )
                onUpdate(context, appWidgetManager, appWidgetIds)
            }
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        Log.d(TAG, "Updating widget $appWidgetId")
        
        try {
            val views = RemoteViews(context.packageName, R.layout.habit_widget_medium)
            val habitData = loadHabitData(context)
            
            if (habitData != null) {
                populateWidgetWithData(context, views, habitData, appWidgetId)
            } else {
                showEmptyState(views)
            }
            
            // Set up click listeners
            setupClickListeners(context, views, appWidgetId)
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
            Log.d(TAG, "Widget $appWidgetId updated successfully")
            
        } catch (e: Exception) {
            Log.e(TAG, "Error updating widget $appWidgetId", e)
            val errorViews = RemoteViews(context.packageName, R.layout.habit_widget_medium)
            showErrorState(errorViews)
            appWidgetManager.updateAppWidget(appWidgetId, errorViews)
        }
    }

    private fun loadHabitData(context: Context): JSONObject? {
        return try {
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val dataJson = prefs.getString(WIDGET_DATA_KEY, null)
            
            if (dataJson != null) {
                JSONObject(dataJson)
            } else {
                Log.w(TAG, "No habit data found in SharedPreferences")
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error loading habit data", e)
            null
        }
    }

    private fun populateWidgetWithData(
        context: Context,
        views: RemoteViews,
        data: JSONObject,
        appWidgetId: Int
    ) {
        try {
            // Update header
            val currentDate = Date(data.optLong("currentDate", System.currentTimeMillis()))
            val dateFormat = SimpleDateFormat("MMM dd", Locale.getDefault())
            views.setTextViewText(R.id.widget_date, dateFormat.format(currentDate))
            
            // Update progress summary
            val totalHabits = data.optInt("totalHabits", 0)
            val totalCompleted = data.optInt("totalCompleted", 0)
            views.setTextViewText(R.id.widget_progress_summary, "$totalCompleted/$totalHabits")
            
            // Clear existing habit rows
            views.removeAllViews(R.id.widget_habits_container)
            
            // Add habit rows
            val habits = data.optJSONArray("habits")
            if (habits != null && habits.length() > 0) {
                for (i in 0 until minOf(habits.length(), 4)) { // Show max 4 habits
                    val habit = habits.getJSONObject(i)
                    addHabitRow(context, views, habit, i, appWidgetId)
                }
            }
            
        } catch (e: Exception) {
            Log.e(TAG, "Error populating widget with data", e)
        }
    }

    private fun addHabitRow(
        context: Context,
        parentViews: RemoteViews,
        habit: JSONObject,
        habitIndex: Int,
        appWidgetId: Int
    ) {
        try {
            val habitRowViews = RemoteViews(context.packageName, R.layout.habit_widget_row)

            // Extract data
            val habitId = habit.optString("id", UUID.randomUUID().toString())
            val habitTitle = habit.optString("title", "Unknown Habit")
            val habitTime = habit.optString("time", "00:00")
            val habitColor = habit.optInt("color", COLOR_INCOMPLETE_GREY)
            val isFavorite = habit.optBoolean("isFavorite", false)
            val weekCompletion = habit.optJSONArray("weekCompletion")

            // Populate views
            habitRowViews.setTextViewText(R.id.habit_title, habitTitle)
            habitRowViews.setTextViewText(R.id.habit_time, habitTime)
            habitRowViews.setInt(R.id.habit_color_indicator, "setBackgroundColor", habitColor)
            habitRowViews.setViewVisibility(
                R.id.habit_favorite_star, 
                if (isFavorite) android.view.View.VISIBLE else android.view.View.GONE
            )

            // Open app on habit info click
            val openAppIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("habitId", habitId)
            }
            val openAppPendingIntent = PendingIntent.getActivity(
                context,
                (appWidgetId * 100) + habitIndex, // Unique request code
                openAppIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            habitRowViews.setOnClickPendingIntent(R.id.habit_info_container, openAppPendingIntent)

            // Populate completion dots
            val completionDotIds = intArrayOf(
                R.id.completion_day_0, R.id.completion_day_1, R.id.completion_day_2,
                R.id.completion_day_3, R.id.completion_day_4, R.id.completion_day_5,
                R.id.completion_day_6
            )

            if (weekCompletion != null) {
                for (i in 0 until weekCompletion.length()) {
                    val status = weekCompletion.optInt(i, 0) // 0: none, 1: completed, 2: skipped
                    val drawableRes = when(status) {
                        1 -> R.drawable.widget_completion_dot_completed
                        2 -> R.drawable.widget_completion_dot_skipped
                        else -> R.drawable.widget_completion_dot_incomplete
                    }
                    habitRowViews.setImageViewResource(completionDotIds[i], drawableRes)

                    // Set click listener for each dot
                    val toggleIntent = Intent(context, HabitWidgetProvider::class.java).apply {
                        action = ACTION_TOGGLE_COMPLETION
                        putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                        putExtra(EXTRA_HABIT_ID, habitId)
                        putExtra(EXTRA_DAY_INDEX, i)
                    }
                    val togglePendingIntent = PendingIntent.getBroadcast(
                        context,
                        (appWidgetId * 1000) + (habitIndex * 10) + i, // Unique request code
                        toggleIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    habitRowViews.setOnClickPendingIntent(completionDotIds[i], togglePendingIntent)
                }
            }
            
            // Add the populated row to the main container
            parentViews.addView(R.id.widget_habits_container, habitRowViews)
            
        } catch (e: Exception) {
            Log.e(TAG, "Error adding habit row", e)
        }
    }

    private fun showEmptyState(views: RemoteViews) {
        views.setTextViewText(R.id.widget_title, "Goals")
        views.setTextViewText(R.id.widget_date, "No habits yet")
        views.setTextViewText(R.id.widget_progress_summary, "0/0")
        views.removeAllViews(R.id.widget_habits_container)
    }

    private fun showErrorState(views: RemoteViews) {
        views.setTextViewText(R.id.widget_title, "Goals")
        views.setTextViewText(R.id.widget_date, "Error loading")
        views.setTextViewText(R.id.widget_progress_summary, "?/?")
        views.removeAllViews(R.id.widget_habits_container)
    }

    private fun setupClickListeners(
        context: Context,
        views: RemoteViews,
        appWidgetId: Int
    ) {
        // Set up click listener for opening the app
        val openAppIntent = Intent(context, MainActivity::class.java)
        openAppIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        
        val openAppPendingIntent = PendingIntent.getActivity(
            context,
            appWidgetId,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        views.setOnClickPendingIntent(R.id.widget_title, openAppPendingIntent)
    }

    private fun handleToggleCompletion(context: Context, intent: Intent) {
        val habitId = intent.getStringExtra(EXTRA_HABIT_ID)
        val dayIndex = intent.getIntExtra(EXTRA_DAY_INDEX, -1)
        
        if (habitId != null && dayIndex >= 0) {
            Log.d(TAG, "Toggling completion for habit $habitId, day $dayIndex")
            
            // This requires the app to be running to handle the method call.
            // For a more robust solution, a background service would be needed.
            // However, for this implementation, we will notify the running app.
            
            val mainActivityIntent = Intent(context, MainActivity::class.java).apply {
                action = "TOGGLE_HABIT_COMPLETION"
                putExtra(EXTRA_HABIT_ID, habitId)
                putExtra(EXTRA_DAY_INDEX, dayIndex)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            context.startActivity(mainActivityIntent)

            // Force a widget update to show immediate feedback,
            // even if it will be updated again by Flutter.
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = intent.getIntArrayExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS) 
                ?: intArrayOf(intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID))

            if (appWidgetIds.first() != AppWidgetManager.INVALID_APPWIDGET_ID) {
                onUpdate(context, appWidgetManager, appWidgetIds)
            }
        }
    }

    private fun handleOpenApp(context: Context) {
        val intent = Intent(context, MainActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        context.startActivity(intent)
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        Log.d(TAG, "Widget enabled")
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        Log.d(TAG, "Widget disabled")
    }
} 