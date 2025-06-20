import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_habit_app/models/habit.dart';

class HabitService {
  static const String _habitsKey = 'habits';

  Future<List<Habit>> loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? habitsJson = prefs.getString(_habitsKey);

    if (habitsJson == null) {
      return [];
    }

    final List<dynamic> decodedData = json.decode(habitsJson) as List<dynamic>;
    return decodedData.map((json) => Habit.fromJson(json)).toList();
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      habits.map((habit) => habit.toJson()).toList(),
    );
    await prefs.setString(_habitsKey, encodedData);
  }

  Future<void> addHabit(Habit newHabit) async {
    List<Habit> habits = await loadHabits();
    habits.add(newHabit);
    await saveHabits(habits);
    await _updateWidgetData(habits);
  }

  Future<void> updateHabitCompletion(
    String habitTitle,
    DateTime date,
    CompletionStatus status,
  ) async {
    List<Habit> habits = await loadHabits();
    final normalizedDate = DateTime(date.year, date.month, date.day);

    for (var habit in habits) {
      if (habit.title == habitTitle) {
        habit.setCompletionStatus(normalizedDate, status);
        break;
      }
    }
    await saveHabits(habits);
    await _updateWidgetData(habits);
  }

  // This method saves the habit data in a format that the Android widget can read
  Future<void> _updateWidgetData(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'flutter.habits',
      json.encode(habits.map((habit) => habit.toJson()).toList()),
    );
  }
}
