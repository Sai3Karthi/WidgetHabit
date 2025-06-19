package com.example.widget_habit_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

/**
 * Implementation of App Widget functionality.
 */
class GoalsWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        super.onReceive(context, intent)
        if (context == null || intent == null) return

        if (intent.action == ACTION_TICK_OFF_HABIT) {
            val habitTitle = intent.getStringExtra("habitTitle")
            // In a real app, you would update your data source here (e.g., database, shared preferences)
            println("Habit ticked off from widget: $habitTitle")

            // Notify the AppWidgetManager that the data has changed, so the list view can be updated
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(intent.component)
            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetIds, R.id.habit_list)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }

    companion object {
        const val ACTION_TICK_OFF_HABIT = "com.example.widget_habit_app.ACTION_TICK_OFF_HABIT"
    }
}

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val views = RemoteViews(context.packageName, R.layout.app_widget_layout)

    // Set current date dynamically
    val calendar = Calendar.getInstance()
    val dayOfWeekFormat = SimpleDateFormat("EEE", Locale.getDefault())
    val dateFormat = SimpleDateFormat("dd MMM", Locale.getDefault())

    views.setTextViewText(R.id.current_date_thu, dayOfWeekFormat.format(calendar.time).uppercase(Locale.getDefault()))
    views.setTextViewText(R.id.current_date_jun, dateFormat.format(calendar.time))

    // Set up click listener for the header to open the app
    val appIntent = Intent(context, MainActivity::class.java)
    val pendingAppIntent: PendingIntent = PendingIntent.getActivity(
        context,
        0,
        appIntent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )
    views.setOnClickPendingIntent(R.id.goals_title, pendingAppIntent) // Make the title clickable
    views.setOnClickPendingIntent(R.id.calendar_icon, pendingAppIntent) // Make the calendar icon clickable

    // Set up the RemoteViewsService to populate the list view
    val serviceIntent = Intent(context, GoalsWidgetService::class.java).apply {
        putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
    }
    views.setRemoteAdapter(R.id.habit_list, serviceIntent)

    // Set up a pending intent template for the list items
    val clickIntent = Intent(context, MainActivity::class.java)
    val clickPendingIntent = PendingIntent.getActivity(
        context,
        0,
        clickIntent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )
    views.setPendingIntentTemplate(R.id.habit_list, clickPendingIntent)

    // Instruct the widget manager to update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
} 