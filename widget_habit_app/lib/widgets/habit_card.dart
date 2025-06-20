import 'package:flutter/material.dart';
import 'package:widget_habit_app/models/habit.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final Function(bool) onChanged;

  const HabitCard({super.key, required this.habit, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // Get current completion status safely
    CompletionStatus currentStatus;
    try {
      currentStatus = habit.getCompletionStatus(DateTime.now());
    } catch (e) {
      currentStatus = CompletionStatus.none;
    }

    return Card(
      color: Colors.grey[900]?.withAlpha(150), // Semi-transparent
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Checkbox
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                value: currentStatus == CompletionStatus.completed,
                onChanged: (bool? value) {
                  try {
                    onChanged(value ?? false);
                  } catch (e) {
                    // Handle errors silently to prevent crashes
                    debugPrint('Error changing habit completion: $e');
                  }
                },
                shape: const CircleBorder(),
                activeColor: habit.color,
                checkColor: Colors.black,
                side: BorderSide(color: habit.color, width: 2),
              ),
            ),
            const SizedBox(width: 16),
            // Habit Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${habit.time.format(context)} • Target: ${habit.targetCount}',
                    style: TextStyle(fontSize: 14.0, color: Colors.grey[400]),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
