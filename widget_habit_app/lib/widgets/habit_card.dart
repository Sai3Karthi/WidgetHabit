import 'package:flutter/material.dart';
import 'package:widget_habit_app/screens/habit_detail_screen.dart';
import 'package:widget_habit_app/widgets/daily_completion_box.dart';
import 'package:widget_habit_app/models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final Color? cardColor;
  final double? opacity;
  final DateTime currentWeekStart;
  final DateTime selectedDay;
  final Function(Map<String, dynamic>)? onDayToggled;

  const HabitCard({
    super.key,
    required this.habit,
    this.cardColor,
    this.opacity,
    required this.currentWeekStart,
    required this.selectedDay,
    this.onDayToggled,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveCardColor = cardColor ?? habit.color;
    final effectiveOpacity = opacity ?? 1.0;

    List<DateTime> weekDays = List.generate(7, (index) {
      return currentWeekStart.add(Duration(days: index));
    });

    int completedCount = 0;
    for (var date in habit.completionDates.keys) {
      if (habit.completionDates[date] == CompletionStatus.completed) {
        completedCount++;
      }
    }
    String displayProgress = '$completedCount/${habit.targetCount}';

    return Card(
      color: effectiveCardColor.withAlpha((255 * effectiveOpacity).toInt()),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HabitDetailScreen(habitTitle: habit.title),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      habit.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: habit.color,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.white70,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${habit.time.hour}:${habit.time.minute.toString().padLeft(2, '0')}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        displayProgress,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star, color: Colors.white70, size: 24),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: weekDays.map((day) {
                  final CompletionStatus currentStatus = habit
                      .getCompletionStatus(day);
                  final CompletionStatus nextStatus;

                  if (currentStatus == CompletionStatus.none) {
                    nextStatus = CompletionStatus.completed;
                  } else if (currentStatus == CompletionStatus.completed) {
                    nextStatus = CompletionStatus.skipped;
                  } else {
                    nextStatus = CompletionStatus.none;
                  }

                  return GestureDetector(
                    onTap: () => onDayToggled?.call({
                      'habitTitle': habit.title,
                      'date': day,
                      'status': nextStatus,
                    }),
                    child: DailyCompletionBox(
                      dayNumber: day.day,
                      status: currentStatus,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
