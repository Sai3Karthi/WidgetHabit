import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class WidgetService {
  static const _widgetChannel = MethodChannel('widget_habit_app/widget');
  static const _habitsKey = 'habits';

  static void initialize() {
    _widgetChannel.setMethodCallHandler(_handleMethod);
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'getHabits':
        final habits = await _getHabitsFromPrefs();
        return json.encode(habits);

      case 'toggleHabitCompletion':
        final String? habitId = call.arguments['habitId'];
        final int? dayIndex = call.arguments['dayIndex'];

        if (habitId != null && dayIndex != null) {
          await _toggleHabitCompletion(habitId, dayIndex);
          return true;
        } else {
          throw PlatformException(
            code: 'INVALID_ARGS',
            message: 'Missing habitId or dayIndex',
          );
        }

      default:
        throw PlatformException(
          code: 'Unimplemented',
          message: 'Method not implemented: ${call.method}',
        );
    }
  }

  static Future<void> updateWidget() async {
    try {
      await _widgetChannel.invokeMethod('updateWidget');
    } on PlatformException catch (e) {
      print("Failed to update widget: '${e.message}'.");
    }
  }

  static Future<void> _toggleHabitCompletion(
    String habitId,
    int dayIndex,
  ) async {
    final habits = await _getHabitsFromPrefs();
    final habitIndex = habits.indexWhere((h) => h['id'] == habitId);

    if (habitIndex != -1) {
      final habit = habits[habitIndex];
      // The weekCompletion array should be present if the widget is visible
      if (habit['weekCompletion'] is List) {
        final List<dynamic> weekCompletion = habit['weekCompletion'];
        // Cycle through states: 0 (incomplete) -> 1 (completed) -> 2 (skipped) -> 0
        if (dayIndex < weekCompletion.length) {
          weekCompletion[dayIndex] = (weekCompletion[dayIndex] + 1) % 3;
        }
      }

      habits[habitIndex] = habit;

      await _saveHabitsToPrefs(habits);
      await updateWidget(); // Notify native side to update the widget UI
    }
  }

  static Future<List<Map<String, dynamic>>> _getHabitsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? habitsJson = prefs.getString(_habitsKey);
    if (habitsJson != null) {
      // SharedPreferences stores it as String, need to decode it to List<dynamic>
      // then cast each item to Map<String, dynamic>
      final List<dynamic> decoded = json.decode(habitsJson);
      return decoded.map((item) => item as Map<String, dynamic>).toList();
    }
    return [];
  }

  static Future<void> _saveHabitsToPrefs(
    List<Map<String, dynamic>> habits,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_habitsKey, json.encode(habits));
  }
}
