import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:widget_habit_app/models/habit.dart'; // Import Habit model and CompletionStatus

class WeeklyDatePicker extends StatelessWidget {
  final DateTime currentWeekStart;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onWeekChanged;
  final ValueChanged<DateTime> onDaySelected;
  final List<Habit> habits; // New: List of habits to check completion

  const WeeklyDatePicker({
    super.key,
    required this.currentWeekStart,
    required this.selectedDay,
    required this.onWeekChanged,
    required this.onDaySelected,
    required this.habits, // New: Require habits
  });

  @override
  Widget build(BuildContext context) {
    List<DateTime> weekDays = List.generate(7, (index) {
      return currentWeekStart.add(Duration(days: index));
    });

    List<String> weekDayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    String monthYear = DateFormat(
      'MMMM yyyy',
    ).format(currentWeekStart); // Format month and year

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
          ), // Add padding to match image
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
                onPressed: () => onWeekChanged(
                  currentWeekStart.subtract(const Duration(days: 7)),
                ),
              ),
              Text(
                monthYear,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ), // Style month/year
              ),
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                ),
                onPressed: () => onWeekChanged(
                  currentWeekStart.add(const Duration(days: 7)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12), // Adjust spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Removed IconButton for navigation from here
            ...weekDayNames.map(
              (dayName) => Text(
                dayName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold, // Make it bolder
                ),
              ),
            ),
            // Removed IconButton for navigation from here
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            DateTime day = weekDays[index];
            final bool isToday =
                day.year == DateTime.now().year &&
                day.month == DateTime.now().month &&
                day.day == DateTime.now().day;
            final bool isSelected =
                day.year == selectedDay.year &&
                day.month == selectedDay.month &&
                day.day == selectedDay.day;

            final bool hasCompletedHabitForDay = _hasCompletedHabitForDay(day);

            return GestureDetector(
              onTap: () => onDaySelected(day),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors
                            .blueAccent // Selected day has blue circular background
                      : (isToday
                            ? Colors.grey[700]
                            : null), // Today (if not selected) has a subtle grey background, otherwise transparent
                  borderRadius: isSelected
                      ? BorderRadius.circular(15)
                      : BorderRadius.circular(
                          8,
                        ), // Circle for selected, slight rounding for others
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isToday
                                  ? Colors.white
                                  : Colors
                                        .white70), // White for selected/today, light grey for others
                        fontWeight: isSelected || isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (hasCompletedHabitForDay)
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // New method to check if any habit is completed for a given day
  bool _hasCompletedHabitForDay(DateTime day) {
    for (var habit in habits) {
      if (habit.getCompletionStatus(day) == CompletionStatus.completed) {
        return true;
      }
    }
    return false;
  }
}
