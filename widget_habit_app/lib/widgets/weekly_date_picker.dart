import 'package:flutter/material.dart';

class WeeklyDatePicker extends StatelessWidget {
  const WeeklyDatePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            Text('M', style: TextStyle(color: Colors.white70)),
            Text('T', style: TextStyle(color: Colors.white70)),
            Text('W', style: TextStyle(color: Colors.white70)),
            Text('T', style: TextStyle(color: Colors.white70)),
            Text('F', style: TextStyle(color: Colors.white70)),
            Text('S', style: TextStyle(color: Colors.white70)),
            Text('S', style: TextStyle(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            final int day =
                16 + index; // Example dates, will make dynamic later
            final bool isToday =
                (day == 19); // Example for today, will make dynamic
            return Container(
              padding: const EdgeInsets.all(6),
              decoration: isToday
                  ? BoxDecoration(
                      color: Colors.white, // Highlight color for today
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: Text(
                '$day',
                style: TextStyle(
                  color: isToday ? Colors.black : Colors.white,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
