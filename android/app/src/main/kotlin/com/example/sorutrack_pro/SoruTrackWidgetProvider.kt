package com.example.sorutrack_pro

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class SoruTrackWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.sorutrack_widget).apply {
                val streak = widgetData.getInt("currentStreak", 0)
                setTextViewText(R.id.widget_streak_count, "$streak days")
                
                val remainingCalories = widgetData.getString("remainingCalories", "--")
                setTextViewText(R.id.widget_calories_remaining, "Calories: $remainingCalories left")
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
