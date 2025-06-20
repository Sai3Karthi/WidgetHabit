import 'package:flutter/material.dart';

enum CompletionStatus { none, completed, skipped }

class Habit {
  String title;
  TimeOfDay time;
  Map<DateTime, CompletionStatus> completionDates;
  Color color;
  int targetCount;
  bool isFavorite;

  Habit({
    required this.title,
    required this.time,
    Map<DateTime, CompletionStatus>? completionDates,
    this.color = Colors.blue,
    this.targetCount = 1,
    this.isFavorite = false,
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

  // Get completion status for a week starting from a given date
  List<CompletionStatus> getWeekCompletionStatus(DateTime weekStartDate) {
    List<CompletionStatus> weekStatus = [];
    for (int i = 0; i < 7; i++) {
      DateTime date = weekStartDate.add(Duration(days: i));
      weekStatus.add(getCompletionStatus(date));
    }
    return weekStatus;
  }

  // Get completed count for current week
  int getWeekCompletedCount(DateTime weekStartDate) {
    int completed = 0;
    for (int i = 0; i < 7; i++) {
      DateTime date = weekStartDate.add(Duration(days: i));
      if (getCompletionStatus(date) == CompletionStatus.completed) {
        completed++;
      }
    }
    return completed;
  }

  // Get total possible completions for the week (7 * targetCount)
  int getWeekTotalCount() {
    return 7 * targetCount;
  }

  // Toggle favorite status
  void toggleFavorite() {
    isFavorite = !isFavorite;
  }

  // Convert Habit object to JSON for storage
  Map<String, dynamic> toJson() => {
    'title': title,
    'timeHour': time.hour,
    'timeMinute': time.minute,
    'completionDates': completionDates.map(
      (date, status) => MapEntry(date.toIso8601String(), status.index),
    ),
    'colorValue': color.value,
    'targetCount': targetCount,
    'isFavorite': isFavorite,
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
          int index = 0;
          if (statusIndex is int) {
            index = statusIndex;
          } else if (statusIndex is bool) {
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
    color: Color(json['colorValue'] as int),
    targetCount: json['targetCount'] as int? ?? 1,
    isFavorite: json['isFavorite'] as bool? ?? false,
  );
}
