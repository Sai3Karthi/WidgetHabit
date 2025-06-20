package com.example.widget_habit_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.Drawable
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
        Log.d(TAG, "App Name: ${context.getString(R.string.app_name)}") // Debugging app_name
        
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
                handleOpenApp(context, intent)
            }
            AppWidgetManager.ACTION_APPWIDGET_UPDATE -> {
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
        val views = RemoteViews(context.packageName, R.layout.habit_widget_medium)
        try {
            val habitData = loadHabitData(context)
            if (habitData != null) {
                populateWidgetWithData(context, views, habitData, appWidgetId)
            } else {
                showEmptyState(views, context)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        } catch (e: Exception) {
            Log.e(TAG, "Error updating widget", e)
            showErrorState(views, context)
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun loadHabitData(context: Context): JSONObject? {
        return try {
            val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            val dataJson = prefs.getString(WIDGET_DATA_KEY, null)
            if (dataJson.isNullOrBlank()) {
                Log.w(TAG, "Habit data JSON is null or blank")
                null
            } else {
                try {
                    JSONObject(dataJson)
                } catch (e: Exception) {
                    Log.e(TAG, "Habit data JSON is corrupt", e)
                    null
                }
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
            // Header
            val currentDate = Date(data.optLong("currentDate", System.currentTimeMillis()))
            val dateFormat = SimpleDateFormat("MMM dd", Locale.getDefault())
            views.setTextViewText(R.id.widget_date, dateFormat.format(currentDate))
            val totalHabits = data.optInt("totalHabits", 0)
            val totalCompleted = data.optInt("totalCompleted", 0)
            views.setTextViewText(R.id.widget_progress_summary, "$totalCompleted/$totalHabits")
            // Clear rows
            views.removeAllViews(R.id.widget_habits_container)
            // Add habit rows
            val habits = data.optJSONArray("habits")
            if (habits != null && habits.length() > 0) {
                for (i in 0 until minOf(habits.length(), 4)) {
                    val habit = habits.optJSONObject(i)
                    if (habit != null) {
                        try {
                            addHabitRow(context, views, habit, i, appWidgetId)
                        } catch (e: Exception) {
                            Log.e(TAG, "Error adding habit row $i", e)
                        }
                    } else {
                        Log.w(TAG, "Habit at index $i is null or not a JSONObject")
                    }
                }
            } else {
                Log.w(TAG, "No habits array or empty habits array in data")
                showEmptyState(views, context)
            }
            // Hide error/empty state
            views.setViewVisibility(R.id.no_habits_message, android.view.View.GONE)
        } catch (e: Exception) {
            Log.e(TAG, "Error in populateWidgetWithData", e)
            showErrorState(views, context)
        }
    }

    private fun addHabitRow(context: Context, parentViews: RemoteViews, habit: JSONObject, habitIndex: Int, appWidgetId: Int) {
        val habitRowViews = RemoteViews(context.packageName, R.layout.habit_widget_row)
        val habitId = habit.optString("id", habitIndex.toString())
        val habitTitle = habit.optString("title", "Unknown Habit")
        val habitTime = habit.optString("time", "00:00")
        val habitColor = habit.optInt("color", 0xFF424242.toInt())
        val isFavorite = habit.optBoolean("isFavorite", false)
        val weekCompletion = habit.optJSONArray("weekCompletion")
        habitRowViews.setTextViewText(R.id.habit_title, habitTitle)
        habitRowViews.setTextViewText(R.id.habit_time, habitTime)
        habitRowViews.setInt(R.id.habit_color_indicator, "setColorFilter", habitColor)
        habitRowViews.setViewVisibility(R.id.habit_favorite_star, if (isFavorite) android.view.View.VISIBLE else android.view.View.GONE)
        // Open app on habit info click
        val openAppIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            putExtra("habitId", habitId)
        }
        val openAppPendingIntent = PendingIntent.getActivity(
            context,
            (appWidgetId * 100) + habitIndex,
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        habitRowViews.setOnClickPendingIntent(R.id.habit_info_container, openAppPendingIntent)
        // Completion dots
        val completionDotIds = intArrayOf(
            R.id.completion_day_0, R.id.completion_day_1, R.id.completion_day_2,
            R.id.completion_day_3, R.id.completion_day_4, R.id.completion_day_5,
            R.id.completion_day_6
        )
        if (weekCompletion != null) {
            val dotSizePx = context.resources.getDimensionPixelSize(R.dimen.widget_completion_dot_small)
            for (i in 0 until weekCompletion.length()) {
                val status = weekCompletion.optInt(i, 0)
                val drawableRes = when (status) {
                    1 -> R.drawable.widget_completion_dot_completed
                    2 -> R.drawable.widget_completion_dot_skipped
                    else -> R.drawable.widget_completion_dot_incomplete
                }
                val drawable = context.resources.getDrawable(drawableRes, null)
                val bitmap = Bitmap.createBitmap(dotSizePx, dotSizePx, Bitmap.Config.ARGB_8888)
                val canvas = Canvas(bitmap)
                drawable.setBounds(0, 0, dotSizePx, dotSizePx)
                drawable.draw(canvas)
                habitRowViews.setImageViewBitmap(completionDotIds[i], bitmap)
                // Toggle completion
                val toggleIntent = Intent(context, HabitWidgetProvider::class.java).apply {
                    action = ACTION_TOGGLE_COMPLETION
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                    putExtra(EXTRA_HABIT_ID, habitId)
                    putExtra(EXTRA_DAY_INDEX, i)
                }
                val togglePendingIntent = PendingIntent.getBroadcast(
                    context,
                    (appWidgetId * 1000) + (habitIndex * 10) + i,
                    toggleIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                habitRowViews.setOnClickPendingIntent(completionDotIds[i], togglePendingIntent)
            }
        }
        parentViews.addView(R.id.widget_habits_container, habitRowViews)
    }

    private fun setupClickListeners(context: Context, views: RemoteViews, appWidgetId: Int) {
        // Open app when header is clicked
        val openAppIntent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val openAppPendingIntent = PendingIntent.getActivity(
            context,
            appWidgetId, // Use appWidgetId as request code for uniqueness per widget
            openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_header_container, openAppPendingIntent)
    }

    private fun showEmptyState(views: RemoteViews, context: Context) {
        views.setTextViewText(R.id.widget_title, context.getString(R.string.widget_title))
        views.setTextViewText(R.id.widget_date, context.getString(R.string.widget_no_habits))
        views.setTextViewText(R.id.widget_progress_summary, context.getString(R.string.widget_progress_initial_zero))
        views.removeAllViews(R.id.widget_habits_container)
        views.setViewVisibility(R.id.widget_progress_summary, android.view.View.GONE) // Hide progress summary
        views.setViewVisibility(R.id.no_habits_message, android.view.View.VISIBLE)
    }

    private fun showErrorState(views: RemoteViews, context: Context) {
        views.setTextViewText(R.id.widget_title, context.getString(R.string.widget_title))
        views.setTextViewText(R.id.widget_date, context.getString(R.string.widget_error_state))
        views.setTextViewText(R.id.widget_progress_summary, "") // Clear progress summary
        views.removeAllViews(R.id.widget_habits_container)
        views.setViewVisibility(R.id.widget_progress_summary, android.view.View.GONE) // Hide progress summary
        views.setViewVisibility(R.id.no_habits_message, android.view.View.VISIBLE) // Show a generic message
        views.setTextViewText(R.id.no_habits_message, context.getString(R.string.widget_error_state_long))
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

    private fun handleOpenApp(context: Context, intent: Intent) {
        val openIntent = Intent(context, MainActivity::class.java)
        openIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        context.startActivity(openIntent)
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