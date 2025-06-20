package com.example.widget_habit_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import android.app.PendingIntent
import android.os.Build
import android.widget.Toast

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
        
        if (intent.action == "com.example.widget_habit_app.ACTION_REFRESH") {
            val appWidgetId = intent.getIntExtra(
                AppWidgetManager.EXTRA_APPWIDGET_ID,
                AppWidgetManager.INVALID_APPWIDGET_ID
            )
            
            if (appWidgetId != AppWidgetManager.INVALID_APPWIDGET_ID) {
                val appWidgetManager = AppWidgetManager.getInstance(context)
                updateAppWidget(context, appWidgetManager, appWidgetId)
                Toast.makeText(context, "Widget refreshed", Toast.LENGTH_SHORT).show()
            }
        }
    }

    companion object {
        fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            // Set up the intent that starts the GoalsWidgetService, which will
            // provide the views for this collection.
            val intent = Intent(context, GoalsWidgetService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                // When intents are compared, the extras are ignored, so we need to embed the extras
                // into the data so that the extras will not be ignored.
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }
            
            // Create refresh intent
            val refreshIntent = Intent(context, GoalsWidgetProvider::class.java).apply {
                action = "com.example.widget_habit_app.ACTION_REFRESH"
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            
            val refreshPendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                PendingIntent.getBroadcast(context, appWidgetId, refreshIntent, 
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)
            } else {
                PendingIntent.getBroadcast(context, appWidgetId, refreshIntent, 
                    PendingIntent.FLAG_UPDATE_CURRENT)
            }
            
            // Launch app intent
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            val launchPendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                PendingIntent.getActivity(context, 0, launchIntent, 
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE)
            } else {
                PendingIntent.getActivity(context, 0, launchIntent, 
                    PendingIntent.FLAG_UPDATE_CURRENT)
            }
            
            // Get the layout for the widget
            val views = RemoteViews(context.packageName, R.layout.goals_widget).apply {
                setRemoteAdapter(R.id.widget_list, intent)
                setEmptyView(R.id.widget_list, R.id.empty_view)
                setOnClickPendingIntent(R.id.widget_title, launchPendingIntent)
            }
            
            // Tell the AppWidgetManager to perform an update on the current app widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_list)
        }
    }
} 