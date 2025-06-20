package com.example.widget_habit_app

import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.*

class GoalsWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return GoalsRemoteViewsFactory(this.applicationContext)
    }
}

class GoalsRemoteViewsFactory(
    private val context: Context,
) : RemoteViewsService.RemoteViewsFactory {

    private val habits = mutableListOf<HabitData>()

    override fun onCreate() {}
    override fun onDestroy() {}
    override fun getLoadingView(): RemoteViews? = null
    override fun getViewTypeCount(): Int = 1
    override fun hasStableIds(): Boolean = true
    override fun getCount(): Int = 1 // Only one root view
    override fun getItemId(position: Int): Long = position.toLong()

    override fun onDataSetChanged() {
        habits.clear()
        loadHabitsFromSharedPreferences()
    }

    override fun getViewAt(position: Int): RemoteViews {
        val root = RemoteViews(context.packageName, R.layout.goals_widget)
        val containerId = R.id.habits_container

        if (habits.isEmpty()) {
            root.setViewVisibility(R.id.empty_view, android.view.View.VISIBLE)
            root.removeAllViews(containerId)
            return root
        } else {
            root.setViewVisibility(R.id.empty_view, android.view.View.GONE)
            root.removeAllViews(containerId)
        }

        for (habit in habits) {
            val card = RemoteViews(context.packageName, R.layout.widget_habit_row)
            card.setTextViewText(R.id.habit_title, habit.title)
            card.setTextViewText(R.id.habit_time, habit.time)
            card.setTextViewText(R.id.habit_progress, habit.progress)
            card.setTextColor(R.id.habit_title, Color.parseColor("#F0F0F0"))

            // Populate week grid
            val calendar = Calendar.getInstance()
            val today = calendar.get(Calendar.DAY_OF_YEAR)
            calendar.set(Calendar.DAY_OF_WEEK, calendar.firstDayOfWeek)
            val dayCellIds = intArrayOf(
                R.id.day_cell_1, R.id.day_cell_2, R.id.day_cell_3, R.id.day_cell_4,
                R.id.day_cell_5, R.id.day_cell_6, R.id.day_cell_7
            )
            for (i in 0..6) {
                val dateStr = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(calendar.time)
                val dayOfMonth = calendar.get(Calendar.DAY_OF_MONTH).toString()
                val status = habit.completionStatus[dateStr] ?: 0
                val cellId = dayCellIds[i]
                card.setTextViewText(cellId, dayOfMonth)
                if (calendar.get(Calendar.DAY_OF_YEAR) == today) {
                    card.setInt(cellId, "setBackgroundResource", R.drawable.widget_day_highlight)
                } else {
                    card.setInt(cellId, "setBackgroundColor", Color.TRANSPARENT)
                }
                calendar.add(Calendar.DATE, 1)
            }
            root.addView(containerId, card)
        }
        return root
    }

    private fun loadHabitsFromSharedPreferences() {
        val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val habitsJson = prefs.getString("flutter.habits", null) ?: return
        try {
            val jsonArray = JSONArray(habitsJson)
            for (i in 0 until jsonArray.length()) {
                val habitJson = jsonArray.getJSONObject(i)
                val title = habitJson.getString("title")
                val timeHour = habitJson.getInt("timeHour")
                val timeMinute = habitJson.getInt("timeMinute")
                val color = habitJson.getInt("colorValue")
                val targetCount = habitJson.getInt("targetCount")
                val timeStr = String.format(Locale.getDefault(), "%02d:%02d", timeHour, timeMinute)
                val completionDates = habitJson.optJSONObject("completionDates") ?: JSONObject()
                val statusMap = mutableMapOf<String, Int>()
                var completedCount = 0
                completionDates.keys().forEach { dateKey ->
                    val status = completionDates.getInt(dateKey)
                    statusMap[dateKey.substring(0, 10)] = status
                    if(status == 1) completedCount++ // 1 is completed
                }
                habits.add(HabitData(title, timeStr, "$completedCount/$targetCount", color, statusMap))
            }
        } catch (e: JSONException) {
            e.printStackTrace()
        }
    }
}

data class HabitData(
    val title: String,
    val time: String,
    val progress: String,
    val color: Int,
    val completionStatus: Map<String, Int>
) 