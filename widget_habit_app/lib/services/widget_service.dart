import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_habit_app/models/habit.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class WidgetService {
  static const MethodChannel _channel = MethodChannel(
    'widget_habit_app/widget',
  );
  static const String _widgetDataKey = 'flutter.widget_habit_data';

  /// Prepares and sends data to the native widget.
  static Future<void> updateWidgetData(List<Habit> habits) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final widgetData = _prepareWidgetData(habits);
      await prefs.setString(_widgetDataKey, json.encode(widgetData));
      await _channel.invokeMethod('updateWidget');
    } catch (e) {
      debugPrint('Error updating widget data: $e');
    }
  }

  /// Initializes the service and sets up the method channel handler.
  static void initialize() {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'toggleHabitCompletion':
          final args = call.arguments as Map;
          final habitId = args['habitId'] as String?;
          final dayIndex = args['dayIndex'] as int?;

          if (habitId != null && dayIndex != null) {
            await _handleToggleCompletionFromNative(habitId, dayIndex);
          }
          break;
        default:
          debugPrint('Unknown method call from native: ${call.method}');
      }
    });
  }

  /// Handles completion toggle event coming from the native widget.
  static Future<void> _handleToggleCompletionFromNative(
    String habitId,
    int dayIndex,
  ) async {
    try {
      // 1. Load habits
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = prefs.getString('habits');
      if (habitsJson == null) return;
      final List<dynamic> habitsList = json.decode(habitsJson);
      final habits = habitsList.map((json) => Habit.fromJson(json)).toList();

      // 2. Find and update habit
      // The habitId from the widget is `habit.title.hashCode.toString()`
      final habitIndex = habits.indexWhere(
        (h) => h.title.hashCode.toString() == habitId,
      );
      if (habitIndex == -1) return;

      final habit = habits[habitIndex];
      final weekStart = _getWeekStart(DateTime.now());
      final targetDate = weekStart.add(Duration(days: dayIndex));

      // Toggle completion status
      final currentStatus = habit.getCompletionStatus(targetDate);
      final newStatus = currentStatus == CompletionStatus.completed
          ? CompletionStatus.none
          : CompletionStatus.completed;

      habit.setCompletionStatus(targetDate, newStatus);
      habits[habitIndex] = habit;

      // 3. Save updated habits
      final updatedHabitsJson = json.encode(
        habits.map((h) => h.toJson()).toList(),
      );
      await prefs.setString('habits', updatedHabitsJson);

      // 4. Update widget with the fresh data
      await updateWidgetData(habits);
    } catch (e) {
      debugPrint('Error handling toggle from native: $e');
    }
  }

  /// Converts a list of Habit objects into a Map suitable for the widget.
  static Map<String, dynamic> _prepareWidgetData(List<Habit> habits) {
    final now = DateTime.now();
    final weekStart = _getWeekStart(now);

    final sortedHabits = List<Habit>.from(habits)
      ..sort((a, b) {
        if (a.isFavorite && !b.isFavorite) return -1;
        if (!a.isFavorite && b.isFavorite) return 1;
        return 0;
      });

    return {
      'habits': sortedHabits
          .map(
            (habit) => {
              'id': habit.title.hashCode
                  .toString(), // Must match ID logic in native code
              'title': habit.title,
              'time':
                  '${habit.time.hour.toString().padLeft(2, '0')}:${habit.time.minute.toString().padLeft(2, '0')}',
              // ignore: deprecated_member_use
              'color': habit.color.value,
              'isFavorite': habit.isFavorite,
              'weekCompletion': _getWeekCompletionData(habit, weekStart),
            },
          )
          .toList(),
      'currentDate': now.millisecondsSinceEpoch,
      'totalHabits': habits.length,
      'totalCompleted': habits
          .where(
            (h) => h.getCompletionStatus(now) == CompletionStatus.completed,
          )
          .length,
    };
  }

  static List<int> _getWeekCompletionData(Habit habit, DateTime weekStart) {
    return List.generate(7, (i) {
      final date = weekStart.add(Duration(days: i));
      return habit.getCompletionStatus(date).index;
    });
  }

  static DateTime _getWeekStart(DateTime date) {
    int weekday = date.weekday;
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: weekday - 1));
  }
}
