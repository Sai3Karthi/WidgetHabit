package com.example.widget_habit_app

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

class GoalsWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return GoalsRemoteViewsFactory(this.applicationContext, intent)
    }
}

class GoalsRemoteViewsFactory(
    private val context: Context,
    intent: Intent
) : RemoteViewsService.RemoteViewsFactory {

    private val appWidgetId: Int = intent.getIntExtra(
        android.appwidget.AppWidgetManager.EXTRA_APPWIDGET_ID,
        android.appwidget.AppWidgetManager.INVALID_APPWIDGET_ID
    )
    
    private val habits = mutableListOf<HabitItem>()

    override fun onCreate() {
        // In onCreate() you setup any connections / cursors to your data source.
        // Heavy lifting, for example downloading or creating content, should be deferred
        // to onDataSetChanged() or getViewAt().
    }

    override fun onDestroy() {
        habits.clear()
    }

    override fun getCount(): Int = habits.size

    override fun getViewAt(position: Int): RemoteViews {
        if (position == android.widget.AdapterView.INVALID_POSITION || habits.isEmpty()) {
            return RemoteViews(context.packageName, R.layout.goals_widget_item)
        }

        val habit = habits[position]
        
        return RemoteViews(context.packageName, R.layout.goals_widget_item).apply {
            setTextViewText(R.id.habit_title, habit.title)
            setTextViewText(R.id.habit_time, habit.time)
            
            // Set completion status indicator
            when (habit.status) {
                0 -> setImageViewResource(R.id.habit_status, android.R.drawable.presence_invisible)
                1 -> setImageViewResource(R.id.habit_status, android.R.drawable.presence_online)
                2 -> setImageViewResource(R.id.habit_status, android.R.drawable.presence_busy)
                else -> setImageViewResource(R.id.habit_status, android.R.drawable.presence_invisible)
            }
            
            // Fill in the click intent template
            val fillInIntent = Intent().apply {
                putExtras(Bundle().apply {
                    putString("habit_title", habit.title)
                })
            }
            setOnClickFillInIntent(R.id.widget_item_container, fillInIntent)
        }
    }

    override fun getLoadingView(): RemoteViews? = null

    override fun getViewTypeCount(): Int = 1

    override fun getItemId(position: Int): Long = position.toLong()

    override fun hasStableIds(): Boolean = true

    override fun onDataSetChanged() {
        // This is triggered when you call notifyAppWidgetViewDataChanged
        // on the AppWidgetManager
        habits.clear()
        loadHabitsFromSharedPreferences()
    }
    
    private fun loadHabitsFromSharedPreferences() {
        val sharedPreferences = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val habitsJson = sharedPreferences.getString("flutter.habits", null) ?: return
        
        try {
            val jsonArray = JSONArray(habitsJson)
            
            val today = Calendar.getInstance()
            val dateFormat = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault())
            val todayStr = dateFormat.format(today.time)
            
            for (i in 0 until jsonArray.length()) {
                val habitJson = jsonArray.getJSONObject(i)
                val title = habitJson.getString("title")
                val timeHour = habitJson.getInt("timeHour")
                val timeMinute = habitJson.getInt("timeMinute")
                
                // Format time
                val timeStr = String.format(Locale.getDefault(), "%02d:%02d", timeHour, timeMinute)
                
                // Get completion status for today
                var status = 0 // Default: none
                if (habitJson.has("completionDates")) {
                    val completionDates = habitJson.getJSONObject("completionDates")
                    val keys = completionDates.keys()
                    
                    while (keys.hasNext()) {
                        val dateKey = keys.next()
                        if (dateKey.startsWith(todayStr)) {
                            status = completionDates.getInt(dateKey)
                            break
                        }
                    }
                }
                
                habits.add(HabitItem(title, timeStr, status))
            }
        } catch (e: JSONException) {
            e.printStackTrace()
        }
    }
}

data class HabitItem(
    val title: String,
    val time: String,
    val status: Int // 0: none, 1: completed, 2: skipped
) 