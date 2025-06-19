import 'package:flutter/material.dart';

class WeeklyDatePicker extends StatefulWidget {
  const WeeklyDatePicker({super.key});

  @override
  State<WeeklyDatePicker> createState() => _WeeklyDatePickerState();
}

class _WeeklyDatePickerState extends State<WeeklyDatePicker> {
  late DateTime _currentWeekStart;
  late DateTime _selectedDay; // New state variable for the selected day

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _findStartOfWeek(DateTime.now());
    _selectedDay = DateTime.now(); // Initialize selected day to today
  }

  DateTime _findStartOfWeek(DateTime date) {
    // Assuming Monday is the first day of the week
    int daysToSubtract = date.weekday - 1; // 0 for Monday, 1 for Tuesday, etc.
    return DateTime(date.year, date.month, date.day - daysToSubtract);
  }

  void _goToPreviousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  void _goToNextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
  }

  void _onDayTapped(DateTime day) {
    setState(() {
      _selectedDay = day; // Update the selected day on tap
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> weekDays = List.generate(7, (index) {
      return _currentWeekStart.add(Duration(days: index));
    });

    List<String> weekDayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
              onPressed: _goToPreviousWeek,
            ),
            ...weekDayNames.map(
              (dayName) =>
                  Text(dayName, style: const TextStyle(color: Colors.white70)),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
              onPressed: _goToNextWeek,
            ),
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
                day.year == _selectedDay.year &&
                day.month == _selectedDay.month &&
                day.day == _selectedDay.day;

            return GestureDetector(
              onTap: () => _onDayTapped(day),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blueAccent
                      : (isToday
                            ? Colors.white
                            : null), // Highlight selected day, then today, otherwise no fill
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isToday ? Colors.black : Colors.white),
                    fontWeight: isSelected || isToday
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
