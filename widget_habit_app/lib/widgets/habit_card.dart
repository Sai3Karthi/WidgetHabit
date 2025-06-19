import 'package:flutter/material.dart';
import 'package:widget_habit_app/screens/habit_detail_screen.dart';
import 'package:widget_habit_app/widgets/weekly_date_picker.dart';

class HabitCard extends StatelessWidget {
  final String title;
  final String time;
  final String progress;
  final Color? cardColor;
  final double? opacity;

  const HabitCard({
    super.key,
    required this.title,
    required this.time,
    required this.progress,
    this.cardColor,
    this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: (cardColor ?? Theme.of(context).cardColor).withOpacity(
        opacity ?? 1.0,
      ),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HabitDetailScreen(habitTitle: title),
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
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(), // Pushes time and progress to the right
                  const Icon(
                    Icons.access_time,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    progress,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.star_border,
                    color: Colors.white70,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const WeeklyDatePicker(),
            ],
          ),
        ),
      ),
    );
  }
}
