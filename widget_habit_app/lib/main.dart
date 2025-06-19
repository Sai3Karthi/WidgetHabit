import 'package:flutter/material.dart';
import 'package:widget_habit_app/widgets/habit_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widget Habit',
      theme: ThemeData(
        // We will customize this later for themes, transparency, and individual colors.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const GoalsScreen(), // Our main screen will be GoalsScreen
    );
  }
}

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Goals',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text('THU', style: Theme.of(context).textTheme.titleLarge),
                Text(
                  ' 19 Jun',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Placeholder for the list of habit cards
            Expanded(
              child: ListView(
                children: const [
                  HabitCard(
                    title: 'Banana -3',
                    time: '7:30 pm',
                    progress: '3/43',
                    cardColor: Colors.red,
                    opacity: 0.7,
                  ),
                  HabitCard(
                    title: 'Hostel booking for eggs and',
                    time: '11:00 am',
                    progress: '0/5',
                    cardColor: Colors.blueAccent,
                    opacity: 0.7,
                  ),
                  HabitCard(
                    title: 'Egg -> 1 full egg + 2 whites',
                    time: '11:00 am',
                    progress: '5/43',
                    cardColor: Colors.orange,
                    opacity: 0.7,
                  ),
                  HabitCard(
                    title: 'Protien powder',
                    time: '6:30 pm',
                    progress: '4/43',
                    cardColor: Colors.green,
                    opacity: 0.7,
                  ),
                  HabitCard(
                    title: 'Dry fruits -> cashews pistas',
                    time: '11:00 am',
                    progress: '5/43',
                    cardColor: Colors.purple,
                    opacity: 0.7,
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
