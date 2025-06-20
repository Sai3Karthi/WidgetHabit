import 'package:flutter/material.dart';

enum CompletionStatus { none, completed, skipped }

class Habit {
  String title;
  TimeOfDay time;
  Map<DateTime, CompletionStatus>
  completionDates; // Changed to CompletionStatus
  Color color; // New property for habit color
  int targetCount; // New property for total target count

  Habit({
    required this.title,
    required this.time,
    Map<DateTime, CompletionStatus>? completionDates,
    this.color = Colors.blue,
    this.targetCount = 1,
  }) : completionDates = completionDates ?? {};

  // Method to mark a day with a specific status
  void setCompletionStatus(DateTime date, CompletionStatus status) {
    DateTime normalizedDate = DateTime(date.year, date.month, date.day);
    completionDates[normalizedDate] = status;
  }

  // Method to get the completion status of a day
  CompletionStatus getCompletionStatus(DateTime date) {
    DateTime normalizedDate = DateTime(date.year, date.month, date.day);
    return completionDates[normalizedDate] ?? CompletionStatus.none;
  }

  // Convert Habit object to JSON for storage (e.g., in shared_preferences)
  Map<String, dynamic> toJson() => {
    'title': title,
    'timeHour': time.hour,
    'timeMinute': time.minute,
    'completionDates': completionDates.map(
      (date, status) =>
          MapEntry(date.toIso8601String(), status.index), // Store enum index
    ),
    'colorValue': color.toARGB32(), // Store color as int value
    'targetCount': targetCount, // Store target count
  };

  // Create Habit object from JSON
  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    title: json['title'] as String,
    time: TimeOfDay(
      hour: json['timeHour'] as int,
      minute: json['timeMinute'] as int,
    ),
    completionDates:
        (json['completionDates'] as Map<String, dynamic>?)?.map((
          dateString,
          statusIndex,
        ) {
          // Handle both int and bool values for backward compatibility
          int index = 0;
          if (statusIndex is int) {
            index = statusIndex;
          } else if (statusIndex is bool) {
            // Convert old boolean format to CompletionStatus
            index = statusIndex
                ? CompletionStatus.completed.index
                : CompletionStatus.none.index;
          }

          return MapEntry(
            DateTime.parse(dateString),
            CompletionStatus.values[index],
          );
        }) ??
        {},
    color: Color(json['colorValue'] as int), // Retrieve color from int value
    targetCount:
        json['targetCount'] as int? ?? 1, // Retrieve target count with default
  );
}
