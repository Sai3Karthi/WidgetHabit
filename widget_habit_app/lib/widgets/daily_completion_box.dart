import 'package:flutter/material.dart';
import 'package:widget_habit_app/models/habit.dart'; // Import CompletionStatus

class DailyCompletionBox extends StatelessWidget {
  final int dayNumber;
  final CompletionStatus status; // Changed from isCompleted to status

  const DailyCompletionBox({
    super.key,
    required this.dayNumber,
    this.status = CompletionStatus.none,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Widget? content;

    switch (status) {
      case CompletionStatus.completed:
        backgroundColor = Colors.green[800]!; // Darker green for completed
        content = const Icon(
          Icons.check,
          color: Colors.white,
          size: 20,
        ); // Tick icon
        break;
      case CompletionStatus.skipped:
        backgroundColor = Colors.red[800]!; // Darker red for skipped
        content = const Icon(
          Icons.close,
          color: Colors.white,
          size: 20,
        ); // Cross icon
        break;
      case CompletionStatus.none:
        backgroundColor = Colors.grey[900]!; // Match app background for none
        content = Text(
          '$dayNumber',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
        );
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(child: content),
    );
  }
}
