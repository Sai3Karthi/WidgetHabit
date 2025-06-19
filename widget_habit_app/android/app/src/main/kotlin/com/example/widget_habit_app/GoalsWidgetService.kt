package com.example.widget_habit_app

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import android.net.Uri

class GoalsWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return GoalsRemoteViewsFactory(this.applicationContext, intent)
    }
}

class GoalsRemoteViewsFactory(private val context: Context, intent: Intent) : RemoteViewsService.RemoteViewsFactory {

    // Dummy data for now. This will eventually come from Flutter.
    private val habits = listOf(
        mapOf("title" to "Banana -3", "time" to "7:30 pm", "progress" to "3/43", "color" to "#FFFF0000", "opacity" to 0.7f),
        mapOf("title" to "Hostel booking for eggs and", "time" to "11:00 am", "progress" to "0/5", "color" to "#FF0000FF", "opacity" to 0.7f),
        mapOf("title" to "Egg -> 1 full egg + 2 whites", "time" to "11:00 am", "progress" to "5/43", "color" to "#FFFFA500", "opacity" to 0.7f),
        mapOf("title" to "Protien powder", "time" to "6:30 pm", "progress" to "4/43", "color" to "#FF00FF00", "opacity" to 0.7f),
        mapOf("title" to "Dry fruits -> cashews pistas", "time" to "11:00 am", "progress" to "5/43", "color" to "#FF800080", "opacity" to 0.7f)
    )

    override fun onCreate() {
        // In a real app, you'd load your data here. This runs once when the factory is first created.
    }

    override fun onDataSetChanged() {
        // This is called when notifyAppWidgetViewDataChanged() is called, indicating data has changed.
        // If data is passed via Intent extras, retrieve it here.
    }

    override fun onDestroy() {
        // Clean up any resources here.
    }

    override fun getCount(): Int {
        return habits.size
    }

    override fun getViewAt(position: Int): RemoteViews {
        val habit = habits[position]
        val views = RemoteViews(context.packageName, R.layout.widget_habit_item_layout)

        views.setTextViewText(R.id.habit_title_widget, habit["title"] as String)
        views.setTextViewText(R.id.habit_time_widget, habit["time"] as String)
        views.setTextViewText(R.id.habit_progress_widget, habit["progress"] as String)

        // Set fill-in Intent for each item (when clicked, it will open the app/specific detail)
        val fillInIntent = Intent()
        fillInIntent.putExtra("habitTitle", habit["title"] as String)
        views.setOnClickFillInIntent(R.id.habit_item_root, fillInIntent)

        // Set up click listener for the tick/cross off icon
        val tickOffIntent = Intent(context, GoalsWidgetProvider::class.java).apply {
            action = "com.example.widget_habit_app.ACTION_TICK_OFF_HABIT"
            putExtra("habitTitle", habit["title"] as String)
            // Use a unique data URI to make the PendingIntent unique for each item
            data = Uri.parse(this.toUri(Intent.URI_INTENT_SCHEME))
        }

        // Note: setOnClickPendingIntent is not supported directly on individual items in a ListView managed by RemoteViewsFactory.
        // Instead, we use setPendingIntentTemplate on the ListView itself in the AppWidgetProvider
        // and then setOnClickFillInIntent on the individual view within getViewAt.
        // For the icon, if we want a *different* action than the whole item, it's more complex.
        // For now, let's make the whole item clickable to open detail, and the tick icon a separate broadcast.
        // The commented out line below is how you'd normally do it if it were a direct button on the widget, not in a list.
        // views.setOnClickPendingIntent(R.id.tick_cross_icon, PendingIntent.getBroadcast(context, position, tickOffIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE))
        views.setOnClickFillInIntent(R.id.tick_cross_icon, tickOffIntent) // This will fill in the template set on the ListView

        return views
    }

    override fun getLoadingView(): RemoteViews? {
        return null
    }

    override fun getViewTypeCount(): Int {
        return 1
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun hasStableIds(): Boolean {
        return true
    }
} 