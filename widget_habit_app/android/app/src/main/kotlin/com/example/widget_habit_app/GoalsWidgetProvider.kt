package com.example.widget_habit_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.*

/**
 * Implementation of App Widget functionality.
 */
class GoalsWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        // No need to handle widget_list or notifyAppWidgetViewDataChanged
    }

    companion object {
        internal fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val views = RemoteViews(context.packageName, R.layout.goals_widget)

            // Update header date
            val dateFormat = SimpleDateFormat("E d MMM", Locale.getDefault())
            views.setTextViewText(R.id.widget_header_date, dateFormat.format(Date()).uppercase(Locale.getDefault()))
            
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
} 